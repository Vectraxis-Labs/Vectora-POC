# Vectora

> A research platform for scientists and academics — powered by AI, built for deep work.

Vectora is a Progressive Web App (PWA) that helps researchers discover papers, manage research projects, collaborate with peers, and get guided support from an AI agent (also called Vectora) — from the first idea to the finished paper.

This repository contains the **Proof of Concept (PoC)** — a simplified but fully functional version of the platform, built to validate the core product experience before scaling to production.

---

## What is Vectora?

Think of Vectora as three things in one:

- **A smart research paper feed** — like YouTube, but for academic papers. Organized by your interests, personalized by your activity.
- **An AI research workspace** — a version-controlled file system with an AI agent that writes code, creates files, and guides your research from start to finish.
- **A collaboration layer** — connect with peers, form teams, share research, chat, and schedule meetings.

---

## PoC Scope

The PoC is intentionally lean. It demonstrates the full product experience without production-grade complexity.

| What's in the PoC | What's skipped (for now) |
|---|---|
| Auth (Google, GitHub, Email) | Microservices architecture |
| User profiles & onboarding | Multi-region AWS deployment |
| Paper feed (YouTube-style) | Kafka event streaming |
| Semantic search | Full Gitea Git server |
| Vectora AI (Q&A, summarize, translate, TTS) | Code execution (agent writes code, user runs it locally) |
| Research workspace with real file system & editor | In-app PDF viewer |
| Database-backed Git model (branches, commits, diffs, merge) | Voice & video calls |
| Task tracker (Kanban board) | Payment integration |
| Peer connections & chat | Email notifications |
| Teams & shared collections | LLM routing across multiple providers |
| Calendar | Dataset storage (Layer 2) |
| Basic admin panel | Real identity verification |

---

## Tech Stack

| Layer | Technology |
|---|---|
| Frontend | Next.js · React · TypeScript · Tailwind CSS · Zustand |
| Backend | FastAPI (Python) — single monolith |
| Database | PostgreSQL + pgvector extension |
| AI | Claude Haiku 4.5 (routine tasks) · Claude Sonnet 4.6 (research agent & complex reasoning) |
| Embeddings | Sentence Transformers (`all-MiniLM-L6-v2`) |
| Vector search | pgvector (runs inside PostgreSQL) |
| File editor | Monaco Editor (`@monaco-editor/react` — the VS Code editor) |
| Auth | NextAuth.js (Google, GitHub, Email) |
| Chat | Stream Chat (free tier) |
| File storage | DigitalOcean Spaces (S3-compatible) |
| TTS | Browser SpeechSynthesis API |
| Infrastructure | DigitalOcean (Terraform-managed) |
| CI/CD | GitHub Actions → DOCR → Droplet |
| Monitoring | Sentry (free tier) |

### Why Claude Haiku 4.5 + Sonnet 4.6?

The PoC uses two Claude models from the Anthropic API, each assigned to the right type of task:

- **Claude Haiku 4.5** — used for high-frequency, routine tasks: summarizing papers, translating abstracts, answering simple Q&A. Extremely cost-efficient at $1/$5 per million tokens. A typical summarization call on a paper abstract costs less than $0.01.
- **Claude Sonnet 4.6** — used for the research agent and complex reasoning: guiding research strategy, writing research paper drafts, generating multi-file code. More capable where it counts.
- **Prompt caching** — when the same paper context is reused across multiple queries in a session, Anthropic's prompt caching gives a 90% discount on the cached portion, keeping costs low during long research sessions.

> **Note:** Your Claude Pro subscription ($20/month at claude.ai) is separate from the Anthropic API. The API is billed pay-as-you-go and used by Vectora's backend independently.

---

## Repository Structure

```
vectora/
├── client/          # Next.js frontend (PWA)
├── server/          # FastAPI backend (monolith)
│   ├── auth/
│   ├── users/
│   ├── papers/
│   ├── research/
│   ├── collections/
│   ├── peers/
│   └── ai/
├── infra/           # Terraform — all infrastructure as code
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── droplet.tf
│   ├── database.tf
│   ├── spaces.tf
│   ├── dns.tf
│   ├── firewall.tf
│   └── scripts/
│       ├── cloud-init.yml
│       └── deploy.sh
├── scripts/         # Seed data, utilities
│   └── seed_papers.py
├── docker-compose.yml
└── README.md
```

---

## Getting Started (Local Development)

### Prerequisites

Make sure you have these installed on your machine:

- [Docker](https://docs.docker.com/get-docker/) and Docker Compose
- [Node.js](https://nodejs.org/) (v20+)
- [Python](https://www.python.org/) (v3.11+)
- [Git](https://git-scm.com/)

### 1. Clone the repository

```bash
git clone https://github.com/vectraxis-labs/vectora.git
cd vectora
```

### 2. Set up environment variables

```bash
cp .env.example .env
```

Open `.env` and fill in the required values:

```env
# LLM (Anthropic API — separate from your Claude Pro subscription)
ANTHROPIC_API_KEY=your_key_here

# Auth
GOOGLE_CLIENT_ID=your_key_here
GOOGLE_CLIENT_SECRET=your_key_here
GITHUB_CLIENT_ID=your_key_here
GITHUB_CLIENT_SECRET=your_key_here
NEXTAUTH_SECRET=generate_a_random_string

# Stream Chat
STREAM_API_KEY=your_key_here
STREAM_API_SECRET=your_key_here

# Database (auto-configured in Docker)
DATABASE_URL=postgresql://vectora:vectora@db:5432/vectora
```

### 3. Start everything with one command

```bash
docker-compose up
```

This starts:

- **Frontend** at `http://localhost:3000`
- **Backend** at `http://localhost:8000`
- **PostgreSQL** (with pgvector) at `localhost:5432`
- **Redis** at `localhost:6379`

### 4. Seed the paper corpus

In a separate terminal, after the containers are up:

```bash
cd scripts
python seed_papers.py
```

This pulls ~2,000–5,000 CS papers from arXiv and Semantic Scholar, generates embeddings, and populates the database. Takes about 10–15 minutes on first run.

### 5. Open the app

Go to `http://localhost:3000` — sign up, complete onboarding, and explore.

---

## Infrastructure (DigitalOcean + Terraform)

The entire PoC infrastructure is managed as code. You can spin it up or tear it down with a single command.

### Spin up

```bash
cd infra
terraform init
terraform apply
```

Everything is provisioned in ~3 minutes: Droplet, managed PostgreSQL, Spaces storage, DNS, and firewall.

### Tear down

```bash
terraform destroy
```

Everything is removed. Monthly cost drops to $0.

### Estimated monthly cost (while running)

| Resource | Cost |
|---|---|
| DigitalOcean Droplet (2 vCPU / 4 GB) | $24 |
| Managed PostgreSQL (1 vCPU / 1 GB) | $15 |
| Spaces storage (250 GB + CDN) | $5 |
| Anthropic API — Claude Haiku 4.5 + Sonnet 4.6 (light demo usage) | $5–20 |
| Domain + DNS | $1–2 |
| Stream Chat, Auth, Embeddings, Registry | $0 |
| **Total** | **~$50–76 / month** |

---

## Build Phases

The PoC is built across 7 phases, each building on the last:

| Phase | Focus | Duration |
|---|---|---|
| Phase 0 | Project setup, Terraform infrastructure, CI/CD | 4–5 days |
| Phase 1 | Auth, user profiles, onboarding flow | 5–7 days |
| Phase 2 | Paper corpus ingestion, home feed, semantic search | 10–14 days |
| Phase 3 | Vectora AI (Q&A, summarize, translate, TTS), collections | 10–14 days |
| Phase 4 | Research workspace — file system, Monaco editor, database-backed Git, AI agent | 18–24 days |
| Phase 5 | Peer connections, discovery, real-time chat | 7–10 days |
| Phase 6 | Teams, calendar, notifications, polish | 10–14 days |

**Total estimated: 64–90 days for a solo developer working full-time.**

---

## The Research Workspace (Phase 4) — How It Works

Phase 4 is the most complex part of the PoC and Vectora's biggest differentiator. Here's what it actually builds:

### File System

Every research workspace has a file system backed by PostgreSQL. The UI looks and feels like VS Code's explorer panel — you can create files and folders, rename them, delete them, and navigate the tree. The editor is Monaco Editor (literally the VS Code editor, embedded as a React component), with full syntax highlighting for Python, LaTeX, Markdown, JavaScript, JSON, and more.

### Database-Backed Git Model

Instead of running a real Git server (Gitea), the entire version control system is modeled in PostgreSQL:

- **Branches** — every research starts with `main`. Users can create, switch, rename, and delete branches.
- **Commits** — every file save creates a commit with an author, message, and timestamp. Agent-created changes are committed under "Vectora AI".
- **File snapshots** — each commit stores the full content of changed files. Unchanged files reference the previous snapshot (copy-on-write).
- **Commit history** — a log view showing all commits on the current branch, with diffs for each changed file. Users can revert to any commit.
- **Merging** — if a file was only changed on one branch, that version wins. If both branches changed the same file, the user sees both versions side-by-side and resolves the conflict manually.

### AI Agent + File System in Sync

The Vectora AI agent operates directly on the file system. When you ask it to create a Python data analysis script, it writes the file — it appears in your file tree immediately, committed as "Vectora AI". The agent always knows what branch you're on and sees the current state of all files. Switching branches also switches the agent's context.

---

## From PoC to Production

Once the PoC is validated, the production path is:

1. **Decompose** the FastAPI monolith into 14 microservices (FastAPI + Spring Boot)
2. **Migrate** to AWS (ECS Fargate, Aurora Global DB, S3, Cognito)
3. **Add Kafka** for event-driven async workflows
4. **Replace** the database-backed Git model with a real Gitea server + DVC for dataset storage
5. **Implement** the 10-stage data quality pipeline
6. **Deploy multi-region** — Mumbai (ap-south-1) + N. Virginia (us-east-1), Active-Active
7. **Add** in-app PDF viewer, voice/video calls, code execution, payments, and email notifications

The PoC module structure (`auth/`, `users/`, `papers/`, etc.) maps directly to the 14 production microservices — the migration is a split, not a rewrite.

---

## Key Concepts

**Vectora AI** — The AI agent embedded throughout the platform. At the paper level, it answers questions, summarizes, translates, and reads papers aloud. Inside a research workspace, it acts as a project guide — creating files, writing code, drafting research papers, and suggesting next steps. Routine tasks use Claude Haiku 4.5. Complex reasoning uses Claude Sonnet 4.6.

**Research Workspace** — A private, version-controlled space for a research project. Contains research papers, a real file system with a code editor, a Git-like branching model, and a Kanban task tracker. Peers collaborate asynchronously via branches and merges.

**Peer Network** — A mutual connection system (like LinkedIn). Peers can text each other and be added to research projects and teams.

**Badges** — Awarded based on the number of papers a user has uploaded: R5 (1 paper) → R4 (2) → R3 (5) → R2 (10) → R1 (20+).

---

## Contributing

This is a solo founder project at the PoC stage. Contributions are not open at this time, but issues and feedback are welcome.

---

## License

Private — all rights reserved. © 2026 Vectraxis-Labs.

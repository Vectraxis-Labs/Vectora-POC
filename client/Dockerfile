# ── Stage 1: Base image ──────────────────────────────────────
# Official Node.js 20 image (slim version)
FROM node:20-slim

# ── Stage 2: Set the working directory ───────────────────────
WORKDIR /app

# ── Stage 3: Install dependencies ────────────────────────────
# Copy package files first (same caching trick as the backend)
COPY package.json package-lock.json ./
RUN npm install

# ── Stage 4: Copy the rest of the frontend code ──────────────
COPY . .

# ── Stage 5: Expose the port ─────────────────────────────────
EXPOSE 3000

# ── Stage 6: Start the Next.js development server ────────────
CMD ["npm", "run", "dev"]
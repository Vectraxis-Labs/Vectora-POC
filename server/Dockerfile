# ── Stage 1: Base image ──────────────────────────────────────
# We start from an official Python 3.12 image
# "slim" means a smaller version — no unnecessary tools pre-installed
FROM python:3.12-slim

# ── Stage 2: Set the working directory ───────────────────────
# All commands from here on run inside /app inside the container
# Think of this like cd /app
WORKDIR /app

# ── Stage 3: Install system dependencies ─────────────────────
# psycopg2 (our PostgreSQL driver) needs these system libraries
# We install them before our Python packages
RUN apt-get update && apt-get install -y \
    gcc \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# ── Stage 4: Install Python dependencies ─────────────────────
# We copy requirements.txt FIRST (before our code)
# This is a performance trick — Docker caches each step
# If requirements.txt hasn't changed, Docker skips this step
# and uses the cached layer, making rebuilds much faster
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# ── Stage 5: Copy our code into the container ────────────────
# Now we copy the rest of the backend code
COPY . .

# ── Stage 6: Tell Docker what port this container uses ───────
# This is documentation — it doesn't actually open the port
# Docker Compose handles the actual port binding
EXPOSE 8000

# ── Stage 7: The command to start the server ─────────────────
# This runs when the container starts
# host 0.0.0.0 means "accept connections from anywhere"
# (not just localhost — important inside Docker)
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]
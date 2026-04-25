# Tell Packer which plugins we need
packer {
  required_plugins {
    digitalocean = {
      version = ">= 1.0.0"
      source  = "github.com/digitalocean/digitalocean"
    }
  }
}

# Variables
variable "do_token" {
  type      = string
  sensitive = true
}

variable "github_repo" {
  type    = string
  default = "https://github.com/Vectraxis-Labs/Vectora-POC.git"
}

# The source block — defines the temporary server Packer uses to build the snapshot
source "digitalocean" "vectora" {
  api_token     = var.do_token

  # The base image to start from — blank Ubuntu
  image         = "ubuntu-24-04-x64"

  # Temporary server spec — only exists during the build
  size          = "s-2vcpu-4gb"
  region        = "nyc3"

  # Name of the snapshot Packer will create
  snapshot_name = "vectora-snapshot"

  # SSH into the temporary server to run our setup
  ssh_username  = "root"
}

# The build block — what to do on the temporary server
build {
  sources = ["source.digitalocean.vectora"]

  # ── Runs on YOUR machine BEFORE the build starts ──────────────
  # Deletes all old snapshots named vectora-snapshot
  provisioner "shell-local" {
    environment_vars = [
      "DIGITALOCEAN_TOKEN=${var.do_token}"
    ]
    inline = [
      "python3 ${path.root}/cleanup_snapshots.py"
    ]
  }

  # Step 1 — Wait for the server to be fully booted
  provisioner "shell" {
    inline = ["cloud-init status --wait"]
  }

  # Step 2 — Install system dependencies
  provisioner "shell" {
    inline = [
      "apt-get update -y",
      "apt-get upgrade -y",
      "apt-get install -y docker.io docker-compose-v2 git nginx",
      "systemctl enable docker",
      "systemctl start docker",
    ]
  }

  # Step 3 — Clone your repo
  provisioner "shell" {
    inline = [
      "git clone ${var.github_repo} /app",
    ]
  }

  # Step 4 — Create a placeholder .env (real values injected at runtime)
  provisioner "shell" {
    inline = [
      "touch /app/.env",
    ]
  }

  # Step 5 — Pre-build Docker images (the slow part — done once here)
  provisioner "shell" {
    inline = [
      "cd /app && docker compose build",
    ]
  }

  # Step 6 — Configure Nginx
  provisioner "shell" {
    inline = [
      "cat > /etc/nginx/sites-available/vectora << 'EOF'\nserver {\n    listen 80;\n    server_name _;\n    location /api {\n        rewrite ^/api(.*) $1 break;\n        proxy_pass http://localhost:8000;\n        proxy_set_header Host $host;\n        proxy_set_header X-Real-IP $remote_addr;\n    }\n    location / {\n        proxy_pass http://localhost:3000;\n        proxy_set_header Host $host;\n        proxy_set_header X-Real-IP $remote_addr;\n    }\n}\nEOF",
      "ln -sf /etc/nginx/sites-available/vectora /etc/nginx/sites-enabled/vectora",
      "rm -f /etc/nginx/sites-enabled/default",
      "nginx -t",
    ]
  }

  # Step 7 — Create systemd service to start containers on every boot
  provisioner "shell" {
    inline = [
      "cat > /etc/systemd/system/vectora.service << 'EOF'\n[Unit]\nDescription=Vectora Docker Compose\nRequires=docker.service\nAfter=docker.service network-online.target\n\n[Service]\nWorkingDirectory=/app\nExecStartPre=/bin/sleep 10\nExecStart=/usr/bin/docker compose up -d\nRemainAfterExit=yes\nRestart=on-failure\nRestartSec=10\n\n[Install]\nWantedBy=multi-user.target\nEOF",
      "systemctl enable vectora",
    ]
  }

  # ── Runs on YOUR machine AFTER snapshot is created ────────────
  post-processor "shell-local" {
    inline = [
      "echo '✅ Snapshot built successfully!'",
      "echo '👉 Run: cd .. && ./up.sh to deploy'",
    ]
  }
}
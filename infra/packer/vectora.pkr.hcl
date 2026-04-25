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
    script = "${path.root}/scripts/setup_nginx.sh"
  }

  # Step 7 — Create systemd service for auto-start on boot
  provisioner "shell" {
    script = "${path.root}/scripts/setup_systemd.sh"
  }

  # ── Runs on YOUR machine AFTER snapshot is created ────────────
  post-processor "shell-local" {
    inline = [
      "echo 'Snapshot built successfully!'",
      "echo 'Run: cd .. && ./up.sh to deploy'",
    ]
  }
}
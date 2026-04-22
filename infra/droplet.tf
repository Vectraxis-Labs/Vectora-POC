# Look up the SSH key we added to DigitalOcean by name
data "digitalocean_ssh_key" "vectora" {
  name = var.ssh_key_name
}

# Create the Droplet (virtual server)
resource "digitalocean_droplet" "vectora" {
  name     = "vectora-poc"
  image    = "ubuntu-24-04-x64"   # Ubuntu 24.04 LTS operating system
  size     = var.droplet_size     # s-2vcpu-4gb
  region   = var.region           # blr1 (Bangalore)

  # Add our SSH key so we can connect to the server
  ssh_keys = [data.digitalocean_ssh_key.vectora.id]

  # cloud-init script runs automatically when the server first boots
  # It installs Docker and starts our application
  user_data = templatefile("scripts/cloud-init.yml", {
    anthropic_api_key = var.anthropic_api_key
    domain            = "localhost"
  })

  # Add the Droplet to our VPC (private network)
  vpc_uuid = digitalocean_vpc.vectora.id

  tags = ["vectora", "poc"]
}

# Create a private network for our resources to communicate securely
resource "digitalocean_vpc" "vectora" {
  name   = "vectora-vpc"
  region = var.region
}
# Look up the SSH key we added to DigitalOcean by name
data "digitalocean_ssh_key" "vectora" {
  name = var.ssh_key_name
}

# Create the Droplet (virtual server)
resource "digitalocean_droplet" "vectora" {
  name     = "vectora-poc"
  image    = data.digitalocean_image.vectora_snapshot.id
  size     = var.droplet_size     # s-2vcpu-4gb
  region   = var.region           # blr1 (Bangalore)

  # Add our SSH key so we can connect to the server
  ssh_keys = [data.digitalocean_ssh_key.vectora.id]

  # Add the Droplet to our VPC (private network)
  vpc_uuid = digitalocean_vpc.vectora.id

  tags = ["vectora", "poc"]
}

# Create a private network for our resources to communicate securely
resource "digitalocean_vpc" "vectora" {
  name   = "vectora-vpc"
  region = var.region
}

# Create a Reserved IP — this IP is yours permanently
resource "digitalocean_reserved_ip" "vectora" {
  region = var.region
  lifecycle {
    prevent_destroy = true
  }
}

# Assign the Reserved IP to the Droplet
resource "digitalocean_reserved_ip_assignment" "vectora" {
  ip_address = digitalocean_reserved_ip.vectora.ip_address
  droplet_id = digitalocean_droplet.vectora.id
}

# Look up our snapshot by name
data "digitalocean_image" "vectora_snapshot" {
  name   = "vectora-snapshot"
  source = "user"
}
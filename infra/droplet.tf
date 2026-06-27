# Look up the SSH key we added to DigitalOcean by name
data "digitalocean_ssh_key" "vectora" {
  name = var.ssh_key_name
}

# Private network so the droplet and database talk over private IPs
resource "digitalocean_vpc" "vectora" {
  name   = "vectora-vpc"
  region = var.region
}

# The droplet -- now a stock Ubuntu box that configures itself via cloud-init
resource "digitalocean_droplet" "vectora" {
  name   = "vectora-poc"
  image  = "ubuntu-24-04-x64"      # stock image; cloud-init does all setup
  size   = var.droplet_size
  region = var.region

  ssh_keys = [data.digitalocean_ssh_key.vectora.id]
  vpc_uuid = digitalocean_vpc.vectora.id

  tags = ["vectora", "poc"]

  # cloud-init runs on first boot. templatefile() lets us inject config and
  # secrets (the DO token for certbot's DNS-01, the domain, the repo URL, the
  # .env values) into the script.
  user_data = templatefile("${path.module}/cloud-init.yml.tftpl", {
    domain            = var.domain
    letsencrypt_email = var.letsencrypt_email
    github_repo       = var.github_repo
    do_token          = var.do_token
    anthropic_api_key = var.anthropic_api_key
  })
}
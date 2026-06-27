# Register the zone in DigitalOcean's DNS. DO becomes authoritative once you
# point GoDaddy's nameservers at it (the one manual step -- see below).
resource "digitalocean_domain" "vectora" {
  name = var.domain
}

# Apex: vectraxis-labs.com -> droplet
resource "digitalocean_record" "apex" {
  domain = digitalocean_domain.vectora.id
  type   = "A"
  name   = "@"
  value  = digitalocean_droplet.vectora.ipv4_address
  ttl    = 300
}

# www.vectraxis-labs.com -> droplet
resource "digitalocean_record" "www" {
  domain = digitalocean_domain.vectora.id
  type   = "A"
  name   = "www"
  value  = digitalocean_droplet.vectora.ipv4_address
  ttl    = 300
}
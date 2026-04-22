resource "digitalocean_firewall" "vectora" {
  name = "vectora-firewall"

  # Apply this firewall to our Droplet
  droplet_ids = [digitalocean_droplet.vectora.id]

  # INBOUND RULES — what traffic is allowed IN

  # Allow HTTP (port 80) from anywhere
  inbound_rule {
    protocol         = "tcp"
    port_range       = "80"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  # Allow HTTPS (port 443) from anywhere
  inbound_rule {
    protocol         = "tcp"
    port_range       = "443"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  # Allow SSH (port 22) — for connecting to the server terminal
  # In production you'd restrict this to your IP only
  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  # OUTBOUND RULES — what traffic is allowed OUT
  # Allow all outbound traffic (the server can reach the internet)

  outbound_rule {
    protocol              = "tcp"
    port_range            = "all"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "all"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}
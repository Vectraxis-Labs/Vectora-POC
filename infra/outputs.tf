output "droplet_ip" {
  description = "Public IPv4 of the droplet"
  value       = digitalocean_droplet.vectora.ipv4_address
}

output "app_url" {
  description = "URL of the application"
  value       = "https://${var.domain}"
}

output "database_host" {
  value     = digitalocean_database_cluster.vectora.private_host
  sensitive = true
}

output "database_port" {
  value = digitalocean_database_cluster.vectora.port
}

output "spaces_bucket_name" {
  value = digitalocean_spaces_bucket.vectora.name
}
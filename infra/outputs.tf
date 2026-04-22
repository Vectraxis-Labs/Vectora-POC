output "droplet_ip" {
  description = "Public IP address of the Droplet"
  value       = digitalocean_droplet.vectora.ipv4_address
}

output "app_url" {
  description = "URL of the application"
  value       = "http://${digitalocean_droplet.vectora.ipv4_address}"
}

output "database_host" {
  description = "Database host (private network)"
  value       = digitalocean_database_cluster.vectora.private_host
  sensitive   = true
}

output "database_port" {
  description = "Database port"
  value       = digitalocean_database_cluster.vectora.port
}

output "spaces_bucket_name" {
  description = "Name of the Spaces storage bucket"
  value       = digitalocean_spaces_bucket.vectora.name
}

output "spaces_cdn_endpoint" {
  description = "CDN endpoint for the Spaces bucket"
  value       = digitalocean_cdn.vectora.endpoint
}
variable "do_token" {
  description = "DigitalOcean API token"
  type        = string
  sensitive   = true   # won't be shown in terminal output
}

variable "region" {
  description = "DigitalOcean region to deploy in"
  type        = string
  default     = "nyc3"  # prefers us-east so nyc3
}

variable "droplet_size" {
  description = "Size of the Droplet"
  type        = string
  default     = "s-2vcpu-4gb"  # 2 CPUs, 4GB RAM — $24/month
}

variable "db_size" {
  description = "Size of the managed database"
  type        = string
  default     = "db-s-1vcpu-1gb"  # 1 CPU, 1GB RAM — $15/month
}

variable "ssh_key_name" {
  description = "Name of the SSH key added to DigitalOcean"
  type        = string
  default     = "vectora-key"
}

variable "anthropic_api_key" {
  description = "Anthropic API key for Claude"
  type        = string
  sensitive   = true
}

variable "spaces_access_key" {
  description = "DigitalOcean Spaces access key"
  type        = string
  sensitive   = true
}

variable "spaces_secret_key" {
  description = "DigitalOcean Spaces secret key"
  type        = string
  sensitive   = true
}


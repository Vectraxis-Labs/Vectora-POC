# Tell Terraform which providers we need
terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }

  # Store Terraform's state file in DigitalOcean Spaces
  # State file tracks what resources Terraform has created
  # Storing it remotely means it's not lost if your laptop breaks
  backend "s3" {
    endpoints = {
      s3 = "https://nyc3.digitaloceanspaces.com"
    }
    region                      = "us-east-1"   # required field, not actually used by DO, DO ignores it
    bucket                      = "vectora-terraform-state"
    key                         = "terraform.tfstate"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    use_path_style              = true
    skip_requesting_account_id  = true
  }
}

# Configure the DigitalOcean provider with our API token
provider "digitalocean" {
  token = var.do_token
  spaces_access_id  = var.spaces_access_key
  spaces_secret_key = var.spaces_secret_key
}
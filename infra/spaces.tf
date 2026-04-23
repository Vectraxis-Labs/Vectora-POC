# Create a Spaces bucket (like an S3 bucket)
resource "digitalocean_spaces_bucket" "vectora" {
  name   = "vectora-storage"
  region = var.region
  acl    = "private"   # not publicly accessible by default
}


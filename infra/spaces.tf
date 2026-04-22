# Create a Spaces bucket (like an S3 bucket)
resource "digitalocean_spaces_bucket" "vectora" {
  name   = "vectora-storage"
  region = var.region
  acl    = "private"   # not publicly accessible by default
}

# Enable CDN for the bucket
# CDN serves files from a location close to the user
# so files load faster anywhere in the world
resource "digitalocean_cdn" "vectora" {
  origin = digitalocean_spaces_bucket.vectora.bucket_domain_name
}
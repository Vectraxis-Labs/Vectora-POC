# Create a managed PostgreSQL database cluster
resource "digitalocean_database_cluster" "vectora" {
  name       = "vectora-db"
  engine     = "pg"           # PostgreSQL
  version    = "16"
  size       = var.db_size    # db-s-1vcpu-1gb
  region     = var.region
  node_count = 1              # 1 node is enough for PoC

  # Put the database in our private VPC
  private_network_uuid = digitalocean_vpc.vectora.id
}

# Create a specific database inside the cluster
resource "digitalocean_database_db" "vectora" {
  cluster_id = digitalocean_database_cluster.vectora.id
  name       = "vectora"
}

# Create a database user
resource "digitalocean_database_user" "vectora" {
  cluster_id = digitalocean_database_cluster.vectora.id
  name       = "vectora"
}

# Only allow the Droplet to connect to the database
# (not the whole internet)
resource "digitalocean_database_firewall" "vectora" {
  cluster_id = digitalocean_database_cluster.vectora.id

  rule {
    type  = "droplet"
    value = digitalocean_droplet.vectora.id
  }
}
#!/bin/bash

echo "Destroying all resources except the Reserved IP..."

terraform destroy \
  -target=digitalocean_reserved_ip_assignment.vectora \
  -target=digitalocean_droplet.vectora \
  -target=digitalocean_database_firewall.vectora \
  -target=digitalocean_database_db.vectora \
  -target=digitalocean_database_user.vectora \
  -target=digitalocean_database_cluster.vectora \
  -target=digitalocean_firewall.vectora \
  -target=digitalocean_vpc.vectora \
  -target=digitalocean_spaces_bucket.vectora

echo "Done! Reserved IP 134.199.248.14 is preserved."
echo "Monthly cost is now ~$5/month (reserved IP only)"
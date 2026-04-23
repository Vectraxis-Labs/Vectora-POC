#!/bin/bash

echo "Spinning up Vectora infrastructure..."
terraform apply -auto-approve
echo "Done! Your app is live at http://134.199.248.14"
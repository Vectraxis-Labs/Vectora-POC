#!/bin/bash
set -e  # stop immediately if any command fails

echo "Configuring Nginx..."

# Write the Nginx config file
cat > /etc/nginx/sites-available/vectora << 'EOF'
server {
    listen 80;
    server_name _;

    location /api {
        rewrite ^/api(.*) $1 break;
        proxy_pass http://localhost:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
EOF

# Enable our config
ln -sf /etc/nginx/sites-available/vectora /etc/nginx/sites-enabled/vectora

# Remove the default Nginx page
rm -f /etc/nginx/sites-enabled/default

# Test the config is valid
nginx -t

echo "Nginx configured successfully"
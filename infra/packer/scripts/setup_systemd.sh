#!/bin/bash
set -e  # stop immediately if any command fails

echo "Configuring systemd service..."

# Write the systemd service file
cat > /etc/systemd/system/vectora.service << 'EOF'
[Unit]
Description=Vectora Docker Compose
Requires=docker.service
After=docker.service network-online.target

[Service]
WorkingDirectory=/app
ExecStartPre=/bin/sleep 10
ExecStart=/usr/bin/docker compose up -d
RemainAfterExit=yes
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Enable the service so it starts automatically on every boot
systemctl enable vectora

echo "Systemd service configured successfully"
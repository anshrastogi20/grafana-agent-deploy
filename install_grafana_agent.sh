#!/bin/bash
# Exit on any error
set -e

# Install unzip (needed to extract Grafana Agent)
sudo apt-get update
sudo apt-get install -y unzip

# Download and install Grafana Agent
curl -LO https://github.com/grafana/agent/releases/latest/download/grafana-agent-linux-amd64.zip
unzip grafana-agent-linux-amd64.zip
chmod +x grafana-agent-linux-amd64
sudo mv grafana-agent-linux-amd64 /usr/local/bin/grafana-agent

# Create minimal Grafana Agent config file
sudo tee /etc/grafana-agent.yaml > /dev/null <<EOF
server:
  http_listen_port: 12345
EOF

# Create Grafana Agent systemd service file
sudo tee /etc/systemd/system/grafana-agent.service > /dev/null <<EOF
[Unit]
Description=Grafana Agent
After=network.target

[Service]
ExecStart=/usr/local/bin/grafana-agent --config.file=/etc/grafana-agent.yaml
Restart=on-failure
User=root
Group=root

[Install]
WantedBy=multi-user.target
EOF


echo "Grafana Agent installed, config created, and service started successfully."

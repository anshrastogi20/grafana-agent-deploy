#!/bin/bash
# Exit on any error
set -e

# Install unzip (needed to extract Grafana Agent)
apt-get update
apt-get install -y unzip

# Download and install Grafana Agent
curl -LO https://github.com/grafana/agent/releases/latest/download/grafana-agent-linux-amd64.zip
unzip grafana-agent-linux-amd64.zip
chmod +x grafana-agent-linux-amd64
mv grafana-agent-linux-amd64 /usr/local/bin/grafana-agent

echo "Grafana Agent installed successfully."

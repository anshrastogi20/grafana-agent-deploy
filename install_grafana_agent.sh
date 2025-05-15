curl -LO https://github.com/grafana/agent/releases/download/v0.40.2/grafana-agent-linux-amd64.zip
unzip grafana-agent-linux-amd64.zip
chmod +x grafana-agent

sudo mv grafana-agent /usr/local/bin/

echo "Grafana Agent installed successfully."
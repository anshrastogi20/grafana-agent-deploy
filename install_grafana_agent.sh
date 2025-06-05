set -e

echo "Installing required packages..."
sudo apt-get update
sudo apt-get install -y curl unzip

echo "Setting environment variables..."
export GCLOUD_HOSTED_METRICS_ID="2248501"
export GCLOUD_HOSTED_METRICS_URL="https://prometheus-prod-32-prod-ca-east-0.grafana.net/api/prom/push"
export GCLOUD_HOSTED_LOGS_ID="1119928"
export GCLOUD_HOSTED_LOGS_URL="https://logs-prod-018.grafana.net/loki/api/v1/push"
export GCLOUD_FM_URL="https://fleet-management-prod-012.grafana.net"
export GCLOUD_FM_POLL_FREQUENCY="60s"
export GCLOUD_FM_HOSTED_ID="1162129"
export ARCH="amd64"
export GCLOUD_RW_API_KEY="glc_eyJvIjoiMjIyMzc4IiwbiI6InN0YWNrLTExNjIxMjktYWxsb3ktdGVycmFmb3JtLWNvbm5lY3QiLCJrIjoiV0o2YTExNTF1eGdlMTVXMUUyMWpLaEdxIiwibSI6eyJyIjoicHJvZC1jYS1lYXN0LTAifX0="

echo "Downloading and installing Grafana Alloy..."
/bin/sh -c "$(curl -fsSL https://storage.googleapis.com/cloud-onboarding/alloy/scripts/install-linux.sh)"

echo "Writing custom config.alloy..."
sudo tee /root/alloy/config.alloy > /dev/null <<'EOF'
discovery.relabel "integrations_node_exporter" {
  targets = prometheus.exporter.unix.integrations_node_exporter.targets
 
  rule {
    target_label = "instance"
    replacement  = constants.hostname
  }
 
  rule {
    target_label = "job"
    replacement = "integrations/node_exporter"
  }
}
 
prometheus.exporter.unix "integrations_node_exporter" {
  disable_collectors = ["ipvs", "btrfs", "infiniband", "xfs", "zfs"]
 
  filesystem {
    fs_types_exclude     = "^(autofs|binfmt_misc|bpf|cgroup2?|configfs|debugfs|devpts|devtmpfs|tmpfs|fusectl|hugetlbfs|iso9660|mqueue|nsfs|overlay|proc|procfs|pstore|rpc_pipefs|securityfs|selinuxfs|squashfs|sysfs|tracefs)$"
    mount_points_exclude = "^/(dev|proc|run/credentials/.+|sys|var/lib/docker/.+)($|/)"
    mount_timeout        = "5s"
  }
 
  netclass {
    ignored_devices = "^(veth.*|cali.*|[a-f0-9]{15})$"
  }
 
  netdev {
    device_exclude = "^(veth.*|cali.*|[a-f0-9]{15})$"
  }
}
 
prometheus.scrape "integrations_node_exporter" {
  targets    = discovery.relabel.integrations_node_exporter.output
  forward_to = [prometheus.relabel.integrations_node_exporter.receiver]
}
 
prometheus.relabel "integrations_node_exporter" {
  forward_to = [prometheus.remote_write.metrics_service.receiver]
 
  rule {
    source_labels = ["__name__"]
    regex         = "up|node_arp_entries|node_boot_time_seconds|node_context_switches_total|node_cpu_seconds_total|node_disk_io_time_seconds_total|node_disk_io_time_weighted_seconds_total|node_disk_read_bytes_total|node_disk_read_time_seconds_total|node_disk_reads_completed_total|node_disk_write_time_seconds_total|node_disk_writes_completed_total|node_disk_written_bytes_total|node_filefd_allocated|node_filefd_maximum|node_filesystem_avail_bytes|node_filesystem_device_error|node_filesystem_files|node_filesystem_files_free|node_filesystem_readonly|node_filesystem_size_bytes|node_intr_total|node_load1|node_load15|node_load5|node_md_disks|node_md_disks_required|node_memory_Active_anon_bytes|node_memory_Active_bytes|node_memory_Active_file_bytes|node_memory_AnonHugePages_bytes|node_memory_AnonPages_bytes|node_memory_Bounce_bytes|node_memory_Buffers_bytes|node_memory_Cached_bytes|node_memory_CommitLimit_bytes|node_memory_Committed_AS_bytes|node_memory_DirectMap1G_bytes|node_memory_DirectMap2M_bytes|node_memory_DirectMap4k_bytes|node_memory_Dirty_bytes|node_memory_HugePages_Free|node_memory_HugePages_Rsvd|node_memory_HugePages_Surp|node_memory_HugePages_Total|node_memory_Hugepagesize_bytes|node_memory_Inactive_anon_bytes|node_memory_Inactive_bytes|node_memory_Inactive_file_bytes|node_memory_Mapped_bytes|node_memory_MemAvailable_bytes|node_memory_MemFree_bytes|node_memory_MemTotal_bytes|node_memory_SReclaimable_bytes|node_memory_SUnreclaim_bytes|node_memory_ShmemHugePages_bytes|node_memory_ShmemPmdMapped_bytes|node_memory_Shmem_bytes|node_memory_Slab_bytes|node_memory_SwapTotal_bytes|node_memory_VmallocChunk_bytes|node_memory_VmallocTotal_bytes|node_memory_VmallocUsed_bytes|node_memory_WritebackTmp_bytes|node_memory_Writeback_bytes|node_netstat_Icmp6_InErrors|node_netstat_Icmp6_InMsgs|node_netstat_Icmp6_OutMsgs|node_netstat_Icmp_InErrors|node_netstat_Icmp_InMsgs|node_netstat_Icmp_OutMsgs|node_netstat_IpExt_InOctets|node_netstat_IpExt_OutOctets|node_netstat_TcpExt_ListenDrops|node_netstat_TcpExt_ListenOverflows|node_netstat_TcpExt_TCPSynRetrans|node_netstat_Tcp_InErrs|node_netstat_Tcp_InSegs|node_netstat_Tcp_OutRsts|node_netstat_Tcp_OutSegs|node_netstat_Tcp_RetransSegs|node_netstat_Udp6_InDatagrams|node_netstat_Udp6_InErrors|node_netstat_Udp6_NoPorts|node_netstat_Udp6_OutDatagrams|node_netstat_Udp6_RcvbufErrors|node_netstat_Udp6_SndbufErrors|node_netstat_UdpLite_InErrors|node_netstat_Udp_InDatagrams|node_netstat_Udp_InErrors|node_netstat_Udp_NoPorts|node_netstat_Udp_OutDatagrams|node_netstat_Udp_RcvbufErrors|node_netstat_Udp_SndbufErrors|node_network_carrier|node_network_info|node_network_mtu_bytes|node_network_receive_bytes_total|node_network_receive_compressed_total|node_network_receive_drop_total|node_network_receive_errs_total|node_network_receive_fifo_total|node_network_receive_multicast_total|node_network_receive_packets_total|node_network_speed_bytes|node_network_transmit_bytes_total|node_network_transmit_compressed_total|node_network_transmit_drop_total|node_network_transmit_errs_total|node_network_transmit_fifo_total|node_network_transmit_multicast_total|node_network_transmit_packets_total|node_network_transmit_queue_length|node_network_up|node_nf_conntrack_entries|node_nf_conntrack_entries_limit|node_os_info|node_sockstat_FRAG6_inuse|node_sockstat_FRAG_inuse|node_sockstat_RAW6_inuse|node_sockstat_RAW_inuse|node_sockstat_TCP6_inuse|node_sockstat_TCP_alloc|node_sockstat_TCP_inuse|node_sockstat_TCP_mem|node_sockstat_TCP_mem_bytes|node_sockstat_TCP_orphan|node_sockstat_TCP_tw|node_sockstat_UDP6_inuse|node_sockstat_UDPLITE6_inuse|node_sockstat_UDPLITE_inuse|node_sockstat_UDP_inuse|node_sockstat_UDP_mem|node_sockstat_UDP_mem_bytes|node_sockstat_sockets_used|node_softnet_dropped_total|node_softnet_processed_total|node_softnet_times_squeezed_total|node_systemd_unit_state|node_textfile_scrape_error|node_time_zone_offset_seconds|node_timex_estimated_error_seconds|node_timex_maxerror_seconds|node_timex_offset_seconds|node_timex_sync_status|node_uname_info|node_vmstat_oom_kill|node_vmstat_pgfault|node_vmstat_pgmajfault|node_vmstat_pgpgin|node_vmstat_pgpgout|node_vmstat_pswpin|node_vmstat_pswpout|process_max_fds|process_open_fds"
    action        = "keep"
  }
}
prometheus.remote_write "metrics_service" {
        endpoint {
                name = "hosted-prometheus"
                url  = "https://prometheus-prod-32-prod-ca-east-0.grafana.net/api/prom/push"
 
                basic_auth {
                        username = "2248501"
                        password = "glc_eyJvIjoiMjIyMzc4IiwibiI6InN0YWNrLTExNjIxMjktYWxsb3ktd3JpdGUiLCJrIjoiM1B6eTlkRjkyTDAycUgwSU42M000R2R2IiwibSI6eyJyIjoicHJvZC1jYS1lYXN0LTAifX0="
                }
              }
}
 
loki.source.journal "logs_integrations_system_journal" {
  max_age       = "24h0m0s"
  relabel_rules = discovery.relabel.logs_integrations_system_journal.rules
  forward_to    = [loki.write.grafana_cloud_loki.receiver]
}
 
local.file_match "logs_integrations_syslog" {
  path_targets = [{
    __address__ = "localhost",
    __path__    = "/var/log/{syslog,messages,*.log}",
    instance    = constants.hostname,
    job         = "syslog",
  }]
}
 
discovery.relabel "logs_integrations_system_journal" {
  targets = []
 
  rule {
    source_labels = ["__journal__systemd_unit"]
    target_label  = "unit"
  }
 
  rule {
    source_labels = ["__journal__boot_id"]
    target_label  = "boot_id"
  }
 
  rule {
    source_labels = ["__journal__transport"]
    target_label  = "transport"
  }
 
  rule {
    source_labels = ["__journal_priority_keyword"]
    target_label  = "level"
  }
}
 
loki.source.file "logs_integrations_syslog" {
  targets    = local.file_match.logs_integrations_syslog.targets
  forward_to = [loki.write.grafana_cloud_loki.receiver]
}
 
 
loki.write "grafana_cloud_loki" {
  endpoint {
    name = "hosted-loki"
    url = "https://logs-prod-018.grafana.net/loki/api/v1/push"
 
    basic_auth {
      username = "1119928"
      password = "glc_eyJvIjoiMjIyMzc4IiwibiI6InN0YWNrLTExNjIxMjktYWxsb3ktb3QtbGFiLWhvc3RzIiwiayI6Ik5wUmdoeTYxODhZMTZmeWRxMExZMHcxOSIsIm0iOnsiciI6InByb2QtY2EtZWFzdC0wIn19"
    }
  }
 
 
}
EOF

echo "Starting Alloy..."
sudo systemctl restart alloy.service

echo "Alloy installed, configured, and started successfully."

# #!/bin/bash
# # Exit on any error
# set -e

# # Install unzip (needed to extract Grafana Agent)
# sudo apt-get update
# sudo apt-get install -y unzip

# # Download and install Grafana Agent
# curl -LO https://github.com/grafana/agent/releases/latest/download/grafana-agent-linux-amd64.zip
# unzip grafana-agent-linux-amd64.zip
# chmod +x grafana-agent-linux-amd64
# sudo mv grafana-agent-linux-amd64 /usr/local/bin/grafana-agent

# # Create minimal Grafana Agent config file
# sudo tee /etc/grafana-agent.yaml > /dev/null <<EOF
# metrics:
#   global:
#     scrape_interval: 15s

#   wal_directory: /tmp/grafana-agent-wal

#   configs:
#     - name: agent
#       scrape_configs:
#         - job_name: 'agent-self'
#           static_configs:
#             - targets: ['localhost:12345']

# EOF

# # Create Grafana Agent systemd service file
# sudo tee /etc/systemd/system/grafana-agent.service > /dev/null <<EOF
# [Unit]
# Description=Grafana Agent
# After=network.target

# [Service]
# ExecStart=/usr/local/bin/grafana-agent \
#   --config.file=/etc/grafana-agent.yaml \
#   --server.http.listen-addr=127.0.0.1:12345

# Restart=on-failure
# User=root
# Group=root

# [Install]
# WantedBy=multi-user.target
# EOF

# # Reload systemd, enable and start Grafana Agent service
# sudo systemctl daemon-reload
# sudo systemctl enable grafana-agent
# sudo systemctl start grafana-agent

# echo "Grafana Agent installed, config created, and service started successfully."

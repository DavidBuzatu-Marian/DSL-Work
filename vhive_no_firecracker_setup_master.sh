#!/bin/bash
wget https://github.com/containerd/stargz-snapshotter/releases/download/v0.13.0/stargz-snapshotter-v0.13.0-linux-amd64.tar.gz
git clone --depth=1 https://github.com/vhive-serverless/vhive.git
cd vhive
mkdir -p /tmp/vhive-logs
./scripts/cloudlab/setup_node.sh stock-only > >(tee -a /tmp/vhive-logs/setup_node.stdout) 2> >(tee -a /tmp/vhive-logs/setup_node.stderr >&2)
sudo cat << EOT | sudo tee /etc/containerd/config.toml
version = 2

# Enable stargz snapshotter for CRI
[plugins."io.containerd.grpc.v1.cri".containerd]
  snapshotter = "stargz"
  disable_snapshot_annotations = false

# Plug stargz snapshotter into containerd
[proxy_plugins]
  [proxy_plugins.stargz]
    type = "snapshot"
    address = "/run/containerd-stargz-grpc/containerd-stargz-grpc.sock"
EOT
sudo tar -C /usr/local/bin -xvf ../stargz-snapshotter-v0.13.0-linux-amd64.tar.gz containerd-stargz-grpc ctr-remote
sudo wget -O /etc/systemd/system/stargz-snapshotter.service https://raw.githubusercontent.com/containerd/stargz-snapshotter/main/script/config/etc/systemd/system/stargz-snapshotter.service
sudo systemctl enable --now stargz-snapshotter
sudo screen -dmS containerd bash -c "containerd > >(tee -a /tmp/vhive-logs/containerd.stdout) 2> >(tee -a /tmp/vhive-logs/containerd.stderr >&2)"
./scripts/cluster/create_multinode_cluster.sh > >(tee -a /tmp/vhive-logs/create_multinode_cluster.stdout) 2> >(tee -a /tmp/vhive-logs/create_multinode_cluster.stderr >&2)
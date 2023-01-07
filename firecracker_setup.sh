#!/bin/bash
curl -fsSL -o hello-vmlinux.bin https://s3.amazonaws.com/spec.ccfc.min/img/quickstart_guide/x86_64/kernels/vmlinux.bin

# Install Docker
DOCKER_INSTALL="sudo apt-get update &&
sudo apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release &&
sudo mkdir -p /etc/apt/keyrings &&
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg &&
echo \
  \"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null &&
sudo apt-get update &&
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin"
eval ${DOCKER_INSTALL} || exit 1

GO_INSTALL="
    wget https://go.dev/dl/go1.18.8.linux-amd64.tar.gz &&
    sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.18.8.linux-amd64.tar.gz &&
    export PATH=$PATH:/usr/local/go/bin
"
eval ${GO_INSTALL} || exit 1

git clone --recurse-submodules https://github.com/firecracker-microvm/firecracker-containerd
cd firecracker-containerd
GO111MODULE=on make all
GO111MODULE=on make install
GO111MODULE=on make firecracker
GO111MODULE=on make install-firecracker
GO111MODULE=on make image
sudo mkdir -p /var/lib/firecracker-containerd/runtime
sudo cp tools/image-builder/rootfs.img /var/lib/firecracker-containerd/runtime/default-rootfs.img
sudo cp ../hello-vmlinux.bin /var/lib/firecracker-containerd/runtime/hello-vmlinux.bin
sudo mkdir -p /etc/firecracker-containerd
sudo cat << EOT | sudo tee /etc/firecracker-containerd/config.toml
version = 2
disabled_plugins = ["io.containerd.grpc.v1.cri"]
root = "/var/lib/firecracker-containerd/containerd"
state = "/run/firecracker-containerd"
[grpc]
  address = "/run/firecracker-containerd/containerd.sock"
[plugins]
  [plugins."io.containerd.snapshotter.v1.devmapper"]
    pool_name = "fc-dev-thinpool"
    base_image_size = "10GB"
    root_path = "/var/lib/firecracker-containerd/snapshotter/devmapper"
[proxy_plugins]
  [proxy_plugins.proxy]
    type = "snapshot"
    address = "/var/lib/demux-snapshotter/snapshotter.sock"
[debug]
  level = "debug"
EOT

## Run devmapper script separately as it might fail on first run

sudo mkdir -p /etc/containerd
sudo cat << EOT | sudo tee /etc/containerd/firecracker-runtime.json
{
  "firecracker_binary_path": "/usr/local/bin/firecracker",
  "kernel_image_path": "/var/lib/firecracker-containerd/runtime/default-vmlinux.bin",
  "kernel_args": "console=ttyS0 pnp.debug=1 noapic reboot=k panic=1 pci=off nomodules ro systemd.unified_cgroup_hierarchy=0 systemd.journald.forward_to_console systemd.unit=firecracker.target init=sbin/overlay-init",
  "root_drive": "/var/lib/firecracker-containerd/runtime/rootfs-stargz.img",
  "log_fifo": "fc-logs.fifo",
  "log_levels": ["debug"],
  "metrics_fifo": "fc-metrics.fifo",
  "default_network_interfaces": [
  {
    "AllowMMDS": true,
    "CNIConfig": {
      "NetworkName": "fcnet",
      "InterfaceName": "veth0"
    }
  }
]
}
EOT
sudo mkdir -p /var/lib/firecracker-containerd

# Stargz setup
GO111MODULE=on make kernel
sudo GO111MODULE=on make install-kernel

GO111MODULE=on make image-stargz
sudo GO111MODULE=on make install-stargz-rootfs

sudo GO111MODULE=on make demo-network
sudo mkdir -p /etc/demux-snapshotter/
sudo mkdir -p /var/lib/demux-snapshotter
sudo cat << EOT | sudo tee /etc/demux-snapshotter/config.toml
[snapshotter.listener]
  type = "unix"
  address = "/var/lib/demux-snapshotter/snapshotter.sock"

[snapshotter.proxy.address.resolver]
  type = "http"
  address = "http://127.0.0.1:10001"

[snapshotter.metrics]
  enable = false

[debug]
  logLevel = "debug"
EOT

## Start all 3 processes in 3 separate terminals
# sudo firecracker-containerd --config /etc/firecracker-containerd/config.toml
# sudo snapshotter/demux-snapshotter
# sudo snapshotter/http-address-resolver
# https://github.com/firecracker-microvm/firecracker-containerd/blob/main/docs/remote-snapshotter-getting-started.md#start-all-of-the-host-daemons

# Run remote snapshotter
# https://github.com/firecracker-microvm/firecracker-containerd/tree/main/examples/cmd/remote-snapshotter#usage
#!/bin/bash
git clone https://github.com/vhive-serverless/vhive.git

cd vhive

git checkout stock-only-stargz-support

mkdir -p /tmp/vhive-logs

sudo ./scripts/cloudlab/setup_node.sh stock-only use-stargz > >(tee -a /tmp/vhive-logs/setup_node.stdout) 2> >(tee -a /tmp/vhive-logs/setup_node.stderr >&2)

sudo screen -dmS containerd containerd; sleep 5;

sudo ./scripts/cluster/create_one_node_cluster.sh stock-only
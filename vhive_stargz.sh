#!/bin/bash
git clone https://github.com/vhive-serverless/vhive.git

cd vhive

git checkout stock-only-stargz-support

mkdir -p /tmp/vhive-logs

sudo ./scripts/cloudlab/setup_node.sh stock-only use-stargz > >(tee -a /tmp/vhive-logs/setup_node.stdout) 2> >(tee -a /tmp/vhive-logs/setup_node.stderr >&2)

sudo screen -dmS containerd containerd; sleep 5;

sudo ./scripts/cluster/create_one_node_cluster.sh stock-only

wget https://go.dev/dl/go1.19.5.linux-amd64.tar.gz

sudo rm -rf /usr/local/go

sudo tar -C /usr/local -xzf go1.19.5.linux-amd64.tar.gz

export PATH=$PATH:/usr/local/go/bin

sleep 30

cd ..

git clone https://github.com/DavidBuzatu-Marian/DSL-Work.git

mkdir experiment

mv DSL-Work/experiments experiment/

cd experiment/experiments/script

sudo /usr/local/go/bin/go mod init main

sudo /usr/local/go/bin/go build main.go

sudo apt-get install wondershaper
	
sudo apt install vnstat

./main base-ghost-test base-golang-test base-mongo-test base-nginx-test base-nodejs-test base-postgres-test base-python-test && ./main estargz-ghost-test estargz-golang-test estargz-mongo-test estargz-nginx-test estargz-nodejs-test estargz-postgres-test estargz-python-test
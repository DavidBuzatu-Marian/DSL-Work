# Setup details

## System

```bash
$ uname -a
Linux node-1.dbuzatu-138770.faas-sched-pg0.cloudlab.umass.edu 5.4.0-100-generic
#113-Ubuntu SMP Thu Feb 3 18:43:29 UTC 2022 x86_64 x86_64 x86_64 GNU/Linux
```

```bash
$ cat /etc/os-release
NAME="Ubuntu"
VERSION="20.04 LTS (Focal Fossa)"
ID=ubuntu
ID_LIKE=debian
PRETTY_NAME="Ubuntu 20.04 LTS"
VERSION_ID="20.04"
HOME_URL="https://www.ubuntu.com/"
SUPPORT_URL="https://help.ubuntu.com/"
BUG_REPORT_URL="https://bugs.launchpad.net/ubuntu/"
PRIVACY_POLICY_URL="https://www.ubuntu.com/legal/terms-and-policies/privacy-policy"
VERSION_CODENAME=focal
UBUNTU_CODENAME=focal
```

## Installation

Installed `main` version of `firecracker-containerd` by following the steps from [quickstart](https://github.com/firecracker-microvm/firecracker-containerd/blob/main/docs/getting-started.md).

- Docker has been installed by following [repository installation](https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository) steps.
- Golang has been installed following GoLang's installation page for [Linux](https://go.dev/doc/install)

Using firecracker-containerd to start a Docker based container using the following script works as expected:

```bash
sudo firecracker-ctr --address /run/firecracker-containerd/containerd.sock \
  run \
  --snapshotter devmapper \
  --runtime aws.firecracker \
  --rm --tty --net-host \
  docker.io/library/busybox:latest busybox-test
```

# Issue

After following the [remote snapshotter](https://github.com/firecracker-microvm/firecracker-containerd/blob/main/docs/remote-snapshotter-getting-started.md) setup guide, running the command:

```bash
./remote-snapshotter ghcr.io/firecracker-microvm/firecracker-containerd/amazonlinux:latest-esgz
```

results in the following output:

```bash
Creating VM
Setting docker credential metadata
Pulling the image
failed to extract layer sha256:d2742e2df4a4530fada3b8dbea2b65c4b6fc03fc89f250e8077ecd0425e1ab6c: failed to mount /var/lib/firecracker-containerd/containerd/tmpmounts/containerd-mount527725939: no such file or directory: unknown
```

# Other logs

## Snapshotter/http-address-resolver

```
ERRO[23898] unable to retrieve VM Info                    VMID=vm1 error="rpc error: code = Unknown desc = failed to connect: dial unix:///run/containerd/s/100199d6c5724f473536a1fad4daf5c92708bd0bc8f33d9bcee8882a74d0bf52-fccontrol: timeout"
```

## Snapshotter/demux-snapshotter

```
ERRO[0013] Function called without namespaced context    error="namespace is required: failed precondition" function=Walk
DEBU[0013] no namespace found, proxying walk function to all cached snapshotters  function=Walk
ERRO[0013] Function called without namespaced context    error="namespace is required: failed precondition" function=Remove
ERRO[0013] Function called without namespaced context    error="namespace is required: failed precondition" function=Cleanup
DEBU[0013]                                               attempt=1 error="temporary vsock dial failure: vsock ack message failure: failed to read \"OK <port>\" within 2s: EOF"
DEBU[0014]                                               attempt=2 error="temporary vsock dial failure: vsock ack message failure: failed to read \"OK <port>\" within 2s: EOF"
DEBU[0014]                                               attempt=3 error="temporary vsock dial failure: vsock ack message failure: failed to read \"OK <port>\" within 2s: read unix @->firecracker.vsock: read: connection reset by peer"
ERRO[0014]                                               attempt=4 error="non-temporary vsock dial failure: failed to dial \"/var/lib/firecracker-containerd/shim-base/vm1#vm1/firecracker.vsock\" within 100ms: dial unix /var/lib/firecracker-containerd/shim-base/vm1#vm1/firecracker.vsock: connect: connection refused"
ERRO[0015]                                               attempt=1 error="non-temporary vsock dial failure: failed to dial \"/var/lib/firecracker-containerd/shim-base/vm1#vm1/firecracker.vsock\" within 100ms: dial unix /var/lib/firecracker-containerd/shim-base/vm1#vm1/firecracker.vsock: connect: no such file or directory"
ERRO[0016]                                               attempt=1 error="non-temporary vsock dial failure: failed to dial \"/var/lib/firecracker-containerd/shim-base/vm1#vm1/firecracker.vsock\" within 100ms: dial unix /var/lib/firecracker-containerd/shim-base/vm1#vm1/firecracker.vsock: connect: no such file or directory"
ERRO[0019]                                               attempt=1 error="non-temporary vsock dial failure: failed to dial \"/var/lib/firecracker-containerd/shim-base/vm1#vm1/firecracker.vsock\" within 100ms: dial unix /var/lib/firecracker-containerd/shim-base/vm1#vm1/firecracker.vsock: connect: no such file or directory"
ERRO[0023]                                               attempt=1 error="non-temporary vsock dial failure: failed to dial \"/var/lib/firecracker-containerd/shim-base/vm1#vm1/firecracker.vsock\" within 100ms: dial unix /var/lib/firecracker-containerd/shim-base/vm1#vm1/firecracker.vsock: connect: no such file or directory"
ERRO[0031]                                               attempt=1 error="non-temporary vsock dial failure: failed to dial \"/var/lib/firecracker-containerd/shim-base/vm1#vm1/firecracker.vsock\" within 100ms: dial unix /var/lib/firecracker-containerd/shim-base/vm1#vm1/firecracker.vsock: connect: no such file or directory"
ERRO[0043]                                               attempt=1 error="non-temporary vsock dial failure: failed to dial \"/var/lib/firecracker-containerd/shim-base/vm1#vm1/firecracker.vsock\" within 100ms: dial unix /var/lib/firecracker-containerd/shim-base/vm1#vm1/firecracker.vsock: connect: no such file or directory"
ERRO[0060]                                               attempt=1 error="non-temporary vsock dial failure: failed to dial \"/var/lib/firecracker-containerd/shim-base/vm1#vm1/firecracker.vsock\" within 100ms: dial unix /var/lib/firecracker-containerd/shim-base/vm1#vm1/firecracker.vsock: connect: no such file or directory"
ERRO[0088]                                               attempt=1 error="non-temporary vsock dial failure: failed to dial \"/var/lib/firecracker-containerd/shim-base/vm1#vm1/firecracker.vsock\" within 100ms: dial unix /var/lib/firecracker-containerd/shim-base/vm1#vm1/firecracker.vsock: connect: no such file or directory"
ERRO[0136]                                               attempt=1 error="non-temporary vsock dial failure: failed to dial \"/var/lib/firecracker-containerd/shim-base/vm1#vm1/firecracker.vsock\" within 100ms: dial unix /var/lib/firecracker-containerd/shim-base/vm1#vm1/firecracker.vsock: connect: no such file or directory"
ERRO[0198]                                               attempt=1 error="non-temporary vsock dial failure: failed to dial \"/var/lib/firecracker-containerd/shim-base/vm1#vm1/firecracker.vsock\" within 100ms: dial unix /var/lib/firecracker-containerd/shim-base/vm1#vm1/firecracker.vsock: connect: no such file or directory"
ERRO[0289]                                               attempt=1 error="non-temporary vsock dial failure: failed to dial \"/var/lib/firecracker-containerd/shim-base/vm1#vm1/firecracker.vsock\" within 100ms: dial unix /var/lib/firecracker-containerd/shim-base/vm1#vm1/firecracker.vsock: connect: no such file or directory"
```

[firecracker_output.txt](https://github.com/firecracker-microvm/firecracker-containerd/files/9992113/firecracker_output.txt)

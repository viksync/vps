#!/usr/bin/env bash
set -euo pipefail
# Installs Docker CE from the official apt repository.
# Requires: VPS_USER env var, must run as root.

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$REPO_DIR/utils.sh"

: "${VPS_USER:?VPS_USER not set}"

if command -v docker &>/dev/null; then
  ok "docker already installed"
  exit 0
fi

spin "Adding Docker apt repo" bash -c '
  apt-get install -y -qq ca-certificates curl
  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  chmod a+r /etc/apt/keyrings/docker.asc
  . /etc/os-release
  tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: ${UBUNTU_CODENAME:-$VERSION_CODENAME}
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF
  apt-get update -qq
'

spin "Installing Docker" \
  apt-get install -y -qq docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

spin "Configuring Docker logging driver" bash -c '
  mkdir -p /etc/docker
  cat > /etc/docker/daemon.json <<EOF
{
  "log-driver": "local",
  "log-opts": {
    "max-size": "10m"
  }
}
EOF
'

spin "Enabling Docker service" sudo systemctl enable --now docker.service
spin "Enablind containerd" sudo systemctl enable --now containerd.service

usermod -aG docker "$VPS_USER"
newgrp docker
ok "Added $VPS_USER to docker group"

#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

source "$PROJECT_ROOT/config/versions.env"

echo "======================================"
echo " Installing Docker Engine"
echo "======================================"

# Check if Docker is already installed
if command -v docker >/dev/null 2>&1; then
    echo "Docker is already installed."
    docker --version
    exit 0
fi

echo "Updating package index..."
sudo apt-get update

echo "Installing required packages..."
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg

echo "Creating Docker keyring directory..."
sudo install -m 0755 -d /etc/apt/keyrings

if [ ! -f /etc/apt/keyrings/docker.gpg ]; then
    echo "Adding Docker GPG key..."
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
        sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
fi

sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo "Adding Docker repository..."
echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

echo "Updating package index..."
sudo apt-get update

echo "Installing Docker Engine..."
sudo apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

echo "Enabling Docker service..."
sudo systemctl enable docker || true
sudo systemctl start docker || true

echo "Adding current user to docker group..."
sudo usermod -aG docker "$USER"

echo
echo "======================================"
echo " Docker Installation Completed"
echo "======================================"

echo "Docker Version:"
docker --version

echo
echo "Docker Buildx Version:"
docker buildx version

echo
echo "Docker Compose Version:"
docker compose version

echo
echo "Verifying Docker..."

if docker info >/dev/null 2>&1; then
    echo "Docker is ready to use without sudo."
else
    echo "Docker installed successfully."
    echo "Please restart your terminal or log in again before using Docker without sudo."
fi

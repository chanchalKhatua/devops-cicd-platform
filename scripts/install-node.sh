#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

source "$PROJECT_ROOT/config/versions.env"

echo "======================================"
echo " Installing Node.js"
echo "======================================"

# Check if Node.js is installed
if command -v node >/dev/null 2>&1 && command -v npm >/dev/null 2>&1; then
    INSTALLED_MAJOR=$(node -v | cut -d'.' -f1 | tr -d 'v')

    if [ "$INSTALLED_MAJOR" -eq "$NODE_VERSION" ]; then
        echo "Node.js ${NODE_VERSION} is already installed."
        echo "Node Version : $(node -v)"
        echo "NPM Version  : $(npm -v)"
        exit 0
    fi

    echo "Detected Node.js $(node -v)"
    echo "Upgrading to Node.js ${NODE_VERSION}..."
fi

echo "Updating package index..."
sudo apt update

echo "Installing required packages..."
sudo apt install -y curl ca-certificates

echo "Adding NodeSource repository..."
curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | sudo -E bash -

echo "Installing Node.js..."
sudo apt install -y nodejs

echo
echo "======================================"
echo " Installation Successful"
echo "======================================"
echo "Node Version : $(node -v)"
echo "NPM Version  : $(npm -v)"

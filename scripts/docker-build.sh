#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

source "$PROJECT_ROOT/config/versions.env"

# Read project version
VERSION=$(tr -d '[:space:]' < "$PROJECT_ROOT/VERSION")

IMAGE_NAME="$DOCKER_LOCAL_IMAGE"

echo "======================================"
echo " Building Docker Image"
echo "======================================"

# Check Docker installation
if ! command -v docker >/dev/null 2>&1; then
    echo "Error: Docker is not installed."
    exit 1
fi

# Check Docker daemon
if ! docker info >/dev/null 2>&1; then
    echo "Error: Docker daemon is not running."
    exit 1
fi

# Move to project root
cd "$PROJECT_ROOT"

echo "Building image: ${IMAGE_NAME}:${VERSION}"

docker build \
    -f docker/Dockerfile \
    -t "${IMAGE_NAME}:${VERSION}" \
    .

echo
echo "======================================"
echo " Docker Image Built Successfully"
echo "======================================"

docker images "${IMAGE_NAME}"

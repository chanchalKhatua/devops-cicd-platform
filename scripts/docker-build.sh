#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

source "$PROJECT_ROOT/config/versions.env"

IMAGE_NAME="react-app"
IMAGE_TAG="v1"

echo "======================================"
echo " Building Docker Image"
echo "======================================"

# Check Docker installation
if ! command -v docker >/dev/null 2>&1; then
    echo "Error: Docker is not installed."
    exit 1
fi

# Move to project root
cd "$PROJECT_ROOT"

echo "Building image: ${IMAGE_NAME}:${IMAGE_TAG}"

docker build \
    -f docker/Dockerfile \
    -t "${IMAGE_NAME}:${IMAGE_TAG}" \
    .

echo
echo "======================================"
echo " Docker Image Built Successfully"
echo "======================================"

docker images "${IMAGE_NAME}"

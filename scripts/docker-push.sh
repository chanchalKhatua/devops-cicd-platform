#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

source "$PROJECT_ROOT/config/versions.env"

AUTO_CONFIRM=false

# --------------------------------------
# Parse Arguments
# --------------------------------------

while [[ $# -gt 0 ]]; do
    case "$1" in
        -y|--yes)
            AUTO_CONFIRM=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [-y|--yes]"
            exit 1
            ;;
    esac
done

# --------------------------------------
# Read Version
# --------------------------------------

VERSION_FILE="$PROJECT_ROOT/VERSION"

if [ ! -f "$VERSION_FILE" ]; then
    echo "Error: VERSION file not found."
    exit 1
fi

VERSION=$(tr -d '[:space:]' < "$VERSION_FILE")

LOCAL_IMAGE="${DOCKER_LOCAL_IMAGE}:${VERSION}"
REMOTE_IMAGE="${DOCKERHUB_USERNAME}/${DOCKER_REPOSITORY}:${VERSION}"
LATEST_IMAGE="${DOCKERHUB_USERNAME}/${DOCKER_REPOSITORY}:latest"

echo "======================================"
echo " Docker Hub Push"
echo "======================================"

# --------------------------------------
# Check Docker Installation
# --------------------------------------

if ! command -v docker >/dev/null 2>&1; then
    echo "Error: Docker is not installed."
    exit 1
fi

# --------------------------------------
# Check Docker Daemon
# --------------------------------------

if ! docker info >/dev/null 2>&1; then
    echo "Error: Docker daemon is not running."
    exit 1
fi

# --------------------------------------
# Verify Local Image
# --------------------------------------

if ! docker image inspect "$LOCAL_IMAGE" >/dev/null 2>&1; then
    echo
    echo "Local image not found:"
    echo "  $LOCAL_IMAGE"
    echo
    echo "Run ./scripts/docker-build.sh first."
    exit 1
fi

# --------------------------------------
# Summary
# --------------------------------------

echo
echo "Version       : $VERSION"
echo "Local Image   : $LOCAL_IMAGE"
echo "Repository    : $DOCKERHUB_USERNAME/$DOCKER_REPOSITORY"
echo "Version Tag   : $REMOTE_IMAGE"
echo "Latest Tag    : $LATEST_IMAGE"

if [ "$AUTO_CONFIRM" = false ]; then
    echo
    read -rp "Push image to Docker Hub? (y/n): " CONFIRM

    if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
        echo "Operation cancelled."
        exit 0
    fi
fi

# --------------------------------------
# Docker Login
# --------------------------------------

echo
echo "Checking Docker Hub login..."

if ! docker info 2>/dev/null | grep -q "Username"; then
    echo "Docker Hub login required."
    docker login
fi

# --------------------------------------
# Tag Images
# --------------------------------------

echo
echo "Tagging images..."

docker tag "$LOCAL_IMAGE" "$REMOTE_IMAGE"
docker tag "$LOCAL_IMAGE" "$LATEST_IMAGE"

# --------------------------------------
# Push Images
# --------------------------------------

echo
echo "Pushing version image..."
docker push "$REMOTE_IMAGE"

echo
echo "Updating latest tag..."
docker push "$LATEST_IMAGE"

# --------------------------------------
# Success
# --------------------------------------

echo
echo "======================================"
echo " Docker Hub Push Completed"
echo "======================================"

echo
echo "Published Images:"
echo "  $REMOTE_IMAGE"
echo "  $LATEST_IMAGE"

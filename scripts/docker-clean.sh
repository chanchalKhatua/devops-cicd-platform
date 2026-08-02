#!/bin/bash
set -e

echo "======================================"
echo " Docker Cleanup"
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

echo
echo "Docker disk usage (Before Cleanup)"
docker system df

echo
echo "Removing stopped containers..."
docker container prune -f

echo
echo "Removing dangling images..."
docker image prune -f

echo
echo "Removing build cache..."
docker builder prune -f

echo
echo "Removing unused networks..."
docker network prune -f

echo
echo "Docker disk usage (After Cleanup)"
docker system df

echo
echo "======================================"
echo " Docker Cleanup Completed"
echo "======================================"

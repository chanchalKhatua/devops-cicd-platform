#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Check Node.js
if ! command -v node >/dev/null 2>&1 || ! command -v npm >/dev/null 2>&1; then
    echo "Node.js/npm not found."
    echo "Run: ./scripts/install-node.sh"
    exit 1
fi

# Check frontend directory
if [ ! -d "$PROJECT_ROOT/frontend" ]; then
    echo "Error: frontend directory not found."
    exit 1
fi

cd "$PROJECT_ROOT/frontend"

echo "Installing project dependencies..."
npm install

echo "Building React application..."
npm run build

# Verify build output
if [ ! -d "dist" ]; then
    echo "Error: React build failed. 'dist' directory not found."
    exit 1
fi

echo "======================================"
echo "React build completed successfully."
echo "Build output: $(pwd)/dist"
echo "======================================"

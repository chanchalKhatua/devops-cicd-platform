#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_ROOT"

echo "======================================"
echo " Git Status"
echo "======================================"
git status

echo
echo "======================================"
echo " Files to be Committed"
echo "======================================"

git status --short

# Check for any tracked or untracked changes
if [ -z "$(git status --porcelain)" ]; then
    echo
    echo "No changes detected."
    exit 0
fi

echo
read -rp "Continue with commit? (y/n): " CONFIRM

if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo "Operation cancelled."
    exit 0
fi

echo
read -rp "Commit message: " COMMIT_MESSAGE

if [ -z "$COMMIT_MESSAGE" ]; then
    echo "Commit message cannot be empty."
    exit 1
fi

echo
echo "======================================"
echo " Staging Files"
echo "======================================"

git add .

echo
echo "======================================"
echo " Creating Commit"
echo "======================================"

git commit -m "$COMMIT_MESSAGE"

echo
echo "======================================"
echo " Syncing with Remote"
echo "======================================"

git pull --rebase origin main

echo
echo "======================================"
echo " Pushing to GitHub"
echo "======================================"

git push origin main

echo
echo "======================================"
echo " Push Completed Successfully"
echo "======================================"

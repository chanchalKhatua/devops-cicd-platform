#!/bin/bash

echo "Pulling latest changes..."
git pull origin main

echo "Adding changes..."
git add .

# Commit only if there are changes
git diff --cached --quiet
if [ $? -eq 0 ]; then
    echo "No changes to commit."
    exit 0
fi

echo "Committing..."
git commit -m "Auto-sync: $(date '+%Y-%m-%d %H:%M:%S')"

echo "Pushing..."
git push origin main

echo "Done!"
#!/bin/sh

REPO_DIR="$(dirname "$0")"

echo "Updating iSH Ping Tools..."
echo "Repository: $REPO_DIR"
echo ""

cd "$REPO_DIR" || {
    echo "Error: Cannot enter repository directory."
    exit 1
}

# Check if this is a git repo
if [ ! -d ".git" ]; then
    echo "Error: This folder is not a Git repository."
    echo "Clone it again using: git clone <repo>"
    exit 1
fi

# Handle local changes
if ! git diff --quiet; then
    echo "Local changes detected."
    echo "Stashing changes..."
    git stash --quiet
fi

echo "Pulling latest version..."
git pull --rebase

if [ $? -eq 0 ]; then
    echo ""
    echo "Applying executable permissions..."
    chmod +x *.sh

    echo ""
    echo "✔ Update complete!"
else
    echo ""
    echo "❌ Update failed."
fi

echo ""
echo "Done."

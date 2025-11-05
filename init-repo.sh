#!/bin/bash
# Initialize SkorionOS Bootc repository

set -e

echo "==> Initializing SkorionOS Bootc repository..."

# Initialize git if not already done
if [ ! -d .git ]; then
    echo "==> Initializing Git repository..."
    git init
    git add .
    git commit -m "initial: SkorionOS Bootc project foundation"
else
    echo "==> Git repository already initialized"
fi

# Create output directories
echo "==> Creating output directories..."
mkdir -p output
mkdir -p packages/built
mkdir -p packages/aur
mkdir -p packages/local

# Make scripts executable
echo "==> Setting executable permissions..."
chmod +x scripts/*.sh
chmod +x rootfs/usr/local/bin/*

echo ""
echo "==> Repository initialized successfully!"
echo ""
echo "Next steps:"
echo "  1. Review README.md for project overview"
echo "  2. Read QUICK_START.md to build your first image"
echo "  3. Check ARCHITECTURE.md for technical details"
echo ""
echo "Quick commands:"
echo "  just                 # List all available commands"
echo "  just build-base      # Build base system"
echo "  just build-kde       # Build KDE variant"
echo "  just run-vm          # Test in virtual machine"
echo ""
echo "Happy hacking! 🚀"


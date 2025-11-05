#!/bin/bash
# Build AUR and local packages for SkorionOS Bootc
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
PACKAGES_DIR="$PROJECT_ROOT/packages"
OUTPUT_DIR="$PACKAGES_DIR/built"

echo "==> Building packages for SkorionOS Bootc"

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Function to build a package
build_package() {
    local pkg_dir="$1"
    local pkg_name=$(basename "$pkg_dir")
    
    echo "==> Building $pkg_name..."
    
    cd "$pkg_dir"
    
    # Check if PKGBUILD exists
    if [ ! -f "PKGBUILD" ]; then
        echo "ERROR: No PKGBUILD found in $pkg_dir"
        return 1
    fi
    
    # Build package
    makepkg -sf --noconfirm || {
        echo "ERROR: Failed to build $pkg_name"
        return 1
    }
    
    # Copy built packages to output directory
    cp *.pkg.tar.zst "$OUTPUT_DIR/" 2>/dev/null || echo "No packages found for $pkg_name"
    
    # Clean up
    rm -f *.pkg.tar.zst
    
    echo "==> Built $pkg_name successfully"
}

# Build AUR packages
if [ -d "$PACKAGES_DIR/aur" ]; then
    echo "==> Building AUR packages..."
    for pkg_dir in "$PACKAGES_DIR/aur"/*; do
        if [ -d "$pkg_dir" ]; then
            build_package "$pkg_dir"
        fi
    done
fi

# Build local packages
if [ -d "$PACKAGES_DIR/local" ]; then
    echo "==> Building local packages..."
    for pkg_dir in "$PACKAGES_DIR/local"/*; do
        if [ -d "$pkg_dir" ]; then
            build_package "$pkg_dir"
        fi
    done
fi

echo ""
echo "==> Package build complete!"
echo "==> Built packages are in: $OUTPUT_DIR"
ls -lh "$OUTPUT_DIR"


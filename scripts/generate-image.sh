#!/bin/bash
# Generate bootable disk image from bootc container
set -e

VARIANT="${1:-kde}"
OUTPUT_DIR="${2:-output}"
IMAGE_NAME="skorionos:${VARIANT}-latest"
OUTPUT_FILE="$OUTPUT_DIR/skorionos-${VARIANT}.img"

echo "==> Generating bootable image for $VARIANT variant"
echo "==> Image: $IMAGE_NAME"
echo "==> Output: $OUTPUT_FILE"

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Check if podman image exists
if ! podman image exists "$IMAGE_NAME"; then
    echo "ERROR: Image $IMAGE_NAME not found!"
    echo "Run 'just build-$VARIANT' first"
    exit 1
fi

# Method 1: Using bootc-image-builder (if available)
if command -v bootc-image-builder &> /dev/null; then
    echo "==> Using bootc-image-builder..."
    
    bootc-image-builder \
        --type qcow2 \
        --output "$OUTPUT_FILE" \
        "$IMAGE_NAME"
    
    echo "==> Image generated successfully!"
    exit 0
fi

# Method 2: Using bootc-image-builder container
echo "==> Using bootc-image-builder container..."
echo "NOTE: This requires privileges to create disk images"

# Pull bootc-image-builder if not available
BUILDER_IMAGE="quay.io/centos-bootc/bootc-image-builder:latest"

sudo podman run \
    --rm \
    -it \
    --privileged \
    --pull=newer \
    -v "$OUTPUT_DIR:/output" \
    -v /var/lib/containers/storage:/var/lib/containers/storage \
    "$BUILDER_IMAGE" \
    --type raw \
    --output /output \
    --local \
    "$IMAGE_NAME"

# Rename output file
if [ -f "$OUTPUT_DIR/disk.raw" ]; then
    mv "$OUTPUT_DIR/disk.raw" "$OUTPUT_FILE"
elif [ -f "$OUTPUT_DIR/image.raw" ]; then
    mv "$OUTPUT_DIR/image.raw" "$OUTPUT_FILE"
fi

echo ""
echo "==> Image generation complete!"
echo "==> Output: $OUTPUT_FILE"
echo ""
echo "==> To test in QEMU:"
echo "    just run-vm $OUTPUT_FILE"
echo ""
echo "==> To write to USB drive (DANGEROUS!):"
echo "    sudo dd if=$OUTPUT_FILE of=/dev/sdX bs=4M status=progress"


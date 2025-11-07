# SkorionOS Bootc Build Automation
# Use 'just <recipe>' to run commands

# Variables
registry := "ghcr.io/skorionos"
vm_memory := "8G"
vm_cpus := "4"

image_name := env("BUILD_IMAGE_NAME", "skorionos")
image_tag := env("BUILD_IMAGE_TAG", "latest")
output_dir := env("BUILD_OUTPUT_DIR", "output")
image_size := env("BUILD_IMAGE_SIZE", "20G")
filesystem := env("BUILD_FILESYSTEM", "btrfs")

# Default recipe - show available commands
default:
    @just --list

# Build minimal system image
build-minimal:
    @echo "Building minimal system image..."
    sudo podman build \
        -f Containerfile.minimal \
        -t {{image_name}}:minimal-{{image_tag}} \
        --layers \
        .

# Build base system image
build-base:
    @echo "Building base system image..."
    sudo podman build \
        -f Containerfile.base \
        -t {{image_name}}:base-{{image_tag}} \
        --layers \
        .

# Build KDE variant
build-kde: build-base
    @echo "Building KDE variant..."
    sudo podman build \
        -f Containerfile.kde \
        -t {{image_name}}:kde-{{image_tag}} \
        --layers \
        .

# Build GNOME variant
build-gnome: build-base
    @echo "Building GNOME variant..."
    sudo podman build \
        -f Containerfile.gnome \
        -t {{image_name}}:gnome-{{image_tag}} \
        --layers \
        .

# Build Hyprland variant
build-hyprland: build-base
    @echo "Building Hyprland variant..."
    sudo podman build \
        -f Containerfile.hyprland \
        -t {{image_name}}:hyprland-{{image_tag}} \
        --layers \
        .

# Build all variants
build-all: build-kde build-gnome build-hyprland
    @echo "All variants built successfully!"

# Pre-build AUR packages
build-packages:
    @echo "Building AUR and local packages..."
    bash scripts/build-packages.sh

# Generate bootable disk image (KDE default)
generate-image variant="kde":
    @echo "Generating bootable image for {{variant}} variant..."
    mkdir -p {{output_dir}}
    bash scripts/generate-image.sh {{variant}} {{output_dir}}

# Generate bootable disk image with composefs backend
generate-bootable-image-local variant="minimal" filesystem=filesystem output_dir=output_dir image_size=image_size:
    #!/usr/bin/env bash
    set -e
    IMG_FILE="{{output_dir}}/skorionos-{{variant}}.img"
    IMG_REF="{{image_name}}:{{variant}}-{{image_tag}}"

    if [[ "{{output_dir}}" = /* ]]; then
        OUTPUT_PATH="{{output_dir}}"
    else
        OUTPUT_PATH="$(pwd)/{{output_dir}}"
    fi

    echo "==> Creating disk..."
    mkdir -p "$OUTPUT_PATH"
    rm -f "$IMG_FILE"
    fallocate -l {{image_size}} "$IMG_FILE"

    echo "==> Installing..."

    sudo podman run \
        --rm --privileged --pid=host \
        -it \
        -v /etc/containers:/etc/containers:Z \
        -v /var/lib/containers:/var/lib/containers:Z \
        -v /dev:/dev \
        -e RUST_LOG=debug \
        -v "$OUTPUT_PATH:/output" \
        --security-opt label=type:unconfined_t \
        "$IMG_REF" \
        bootc install to-disk \
        --composefs-backend --insecure --via-loopback \
        --filesystem {{filesystem}} --wipe /output/skorionos-{{variant}}.img

    echo "✅ Done: $IMG_FILE"

# Fast build using tmpfs (25x faster, requires RAM)
generate-bootable-image-fast variant="minimal" filesystem=filesystem size=image_size:
    #!/usr/bin/env bash
    set -e
    echo "⚡ Fast build using tmpfs..."
    BUILD_OUTPUT_DIR=/tmp just generate-bootable-image-local {{variant}} {{filesystem}} /tmp {{size}}
    echo "Moving to output directory..."
    mkdir -p {{output_dir}}
    mv /tmp/skorionos-{{variant}}.img {{output_dir}}/
    echo "✅ Fast build complete: {{output_dir}}/skorionos-{{variant}}.img"

# Run VM with generated image
run-vm image="output/skorionos-bootc.img":
    @echo "Starting VM with {{image}}..."
    qemu-system-x86_64 \
        -enable-kvm \
        -m {{vm_memory}} \
        -cpu host \
        -smp {{vm_cpus}} \
        -drive file={{image}},format=raw,if=virtio \
        -bios /usr/share/ovmf/x64/OVMF.fd \
        -device virtio-vga-gl \
        -display gtk,gl=on \
        -device qemu-xhci \
        -device usb-kbd \
        -device usb-tablet \
        -net nic,model=virtio \
        -net user,hostfwd=tcp::2222-:22

# Test build in container
test-build:
    @echo "Running test build..."
    sudo podman build \
        -f Containerfile.base \
        -t {{image_name}}:test \
        --target test \
        .

# Push image to registry
push variant="kde" tag="{{image_tag}}":
    @echo "Pushing {{variant}} variant to registry..."
    sudo podman tag {{image_name}}:{{variant}}-{{image_tag}} {{registry}}/{{image_name}}:{{variant}}-{{tag}}
    sudo podman push {{registry}}/{{image_name}}:{{variant}}-{{tag}}

# Push all variants
push-all tag="{{image_tag}}":
    @just push kde {{tag}}
    @just push gnome {{tag}}
    @just push hyprland {{tag}}

# Clean build artifacts
clean:
    @echo "Cleaning build artifacts..."
    rm -rf {{output_dir}}/*
    sudo podman image prune -f

# Deep clean (including containers and cache)
clean-all:
    @echo "Deep cleaning all containers and cache..."
    sudo podman system prune -a -f
    rm -rf {{output_dir}}

# Show image information
info variant="kde":
    @echo "Image information for {{variant}} variant:"
    sudo podman images {{image_name}}:{{variant}}-{{image_tag}}
    @echo ""
    @echo "Image layers:"
    sudo podman inspect {{image_name}}:{{variant}}-{{image_tag}} | jq '.[0].RootFS.Layers'

# Export image for debugging
export variant="kde":
    @echo "Exporting {{variant}} image..."
    mkdir -p {{output_dir}}/export
    sudo podman save {{image_name}}:{{variant}}-{{image_tag}} -o {{output_dir}}/export/{{variant}}.tar
    @echo "Exported to {{output_dir}}/export/{{variant}}.tar"

# Shell into image for debugging
shell variant="kde":
    @echo "Starting shell in {{variant}} image..."
    sudo podman run -it --rm {{image_name}}:{{variant}}-{{image_tag}} /bin/bash

# Lint Containerfiles
lint:
    @echo "Linting Containerfiles..."
    hadolint Containerfile.base || echo "Install hadolint for linting: pacman -S hadolint"

# Check package updates
check-updates:
    @echo "Checking for package updates..."
    sudo podman run --rm {{image_name}}:base-{{image_tag}} pacman -Qu || echo "No updates available"

# Show disk usage
disk-usage:
    @echo "Container storage usage:"
    sudo podman system df

# Development: quick rebuild and test
dev variant="kde":
    @echo "Development workflow: rebuild and test..."
    just build-{{variant}}
    just shell {{variant}}

# CI: Full build and test pipeline
ci:
    @echo "Running CI pipeline..."
    just lint
    just build-all
    just test-build
    @echo "CI pipeline completed successfully!"


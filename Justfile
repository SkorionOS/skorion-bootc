# SkorionOS Bootc Build Automation
# Use 'just <recipe>' to run commands

# Variables
image_name := "skorionos"
image_tag := "latest"
registry := "ghcr.io/skorionos"
output_dir := "output"
vm_memory := "8G"
vm_cpus := "4"

# Default recipe - show available commands
default:
    @just --list

# Build base system image
build-base:
    @echo "Building base system image..."
    podman build \
        -f Containerfile.base \
        -t {{image_name}}:base-{{image_tag}} \
        --layers \
        .

# Build KDE variant
build-kde: build-base
    @echo "Building KDE variant..."
    podman build \
        -f Containerfile.kde \
        -t {{image_name}}:kde-{{image_tag}} \
        --layers \
        .

# Build GNOME variant
build-gnome: build-base
    @echo "Building GNOME variant..."
    podman build \
        -f Containerfile.gnome \
        -t {{image_name}}:gnome-{{image_tag}} \
        --layers \
        .

# Build Hyprland variant
build-hyprland: build-base
    @echo "Building Hyprland variant..."
    podman build \
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
    podman build \
        -f Containerfile.base \
        -t {{image_name}}:test \
        --target test \
        .

# Push image to registry
push variant="kde" tag="{{image_tag}}":
    @echo "Pushing {{variant}} variant to registry..."
    podman tag {{image_name}}:{{variant}}-{{image_tag}} {{registry}}/{{image_name}}:{{variant}}-{{tag}}
    podman push {{registry}}/{{image_name}}:{{variant}}-{{tag}}

# Push all variants
push-all tag="{{image_tag}}":
    @just push kde {{tag}}
    @just push gnome {{tag}}
    @just push hyprland {{tag}}

# Clean build artifacts
clean:
    @echo "Cleaning build artifacts..."
    rm -rf {{output_dir}}/*
    podman image prune -f

# Deep clean (including containers and cache)
clean-all:
    @echo "Deep cleaning all containers and cache..."
    podman system prune -a -f
    rm -rf {{output_dir}}

# Show image information
info variant="kde":
    @echo "Image information for {{variant}} variant:"
    podman images {{image_name}}:{{variant}}-{{image_tag}}
    @echo ""
    @echo "Image layers:"
    podman inspect {{image_name}}:{{variant}}-{{image_tag}} | jq '.[0].RootFS.Layers'

# Export image for debugging
export variant="kde":
    @echo "Exporting {{variant}} image..."
    mkdir -p {{output_dir}}/export
    podman save {{image_name}}:{{variant}}-{{image_tag}} -o {{output_dir}}/export/{{variant}}.tar
    @echo "Exported to {{output_dir}}/export/{{variant}}.tar"

# Shell into image for debugging
shell variant="kde":
    @echo "Starting shell in {{variant}} image..."
    podman run -it --rm {{image_name}}:{{variant}}-{{image_tag}} /bin/bash

# Lint Containerfiles
lint:
    @echo "Linting Containerfiles..."
    hadolint Containerfile.base || echo "Install hadolint for linting: pacman -S hadolint"

# Check package updates
check-updates:
    @echo "Checking for package updates..."
    podman run --rm {{image_name}}:base-{{image_tag}} pacman -Qu || echo "No updates available"

# Show disk usage
disk-usage:
    @echo "Container storage usage:"
    podman system df

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


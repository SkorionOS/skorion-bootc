# SkorionOS Bootc

A modern, container-native implementation of SkorionOS using bootc and composefs technology.

## Overview

SkorionOS Bootc is a modern reimplementation of SkorionOS (formerly ChimeraOS) using container-native operating system technology. Build your OS like a Docker image, distribute via container registries, and update atomically.

### Core Technology

- **bootc** - Container-native OS management with atomic updates
- **dracut** - Modern initramfs generation (replaces mkinitcpio)
- **ostree + composefs** - Zero-copy filesystem with instant rollback
- **OCI containers** - Standard image format and distribution
- **Arch Linux** - Rolling release base system

### Key Advantages

- ⚡ **Fast updates** - Incremental layer-based downloads
- 🔄 **Atomic updates** - All-or-nothing with automatic rollback
- 🐳 **Standard ecosystem** - Use container registries and tools
- 🎮 **Gaming optimized** - For handheld gaming devices
- 🏗️ **Reproducible** - Declare system state in Containerfile

## Architecture

### Three-Layer System

```
archlinux:latest (Official Arch base)
  └─> skorionos:minimal-latest (bootc + dracut + kernel)
        └─> skorionos:base-latest (Full desktop system support)
              ├─> skorionos:kde-latest (KDE Plasma)
              ├─> skorionos:gnome-latest (GNOME Shell)
              └─> skorionos:hyprland-latest (Hyprland)
```

### Build → Deploy Flow

```
Containerfile → OCI Image → Registry → bootc → composefs mount
   (Build)      (Package)   (Distribute) (Deploy)  (Zero-copy)
```

## AUR and Local Packages

SkorionOS uses a separate **[skorion-packages](https://github.com/SkorionOS/skorion-packages)** repository to manage AUR and local packages:

- 🎯 **Custom pacman repository**: Pre-built AUR and local packages
- 📦 **GitHub Releases**: Uses `latest` release as rolling repository
- 🔄 **Incremental builds**: CI only rebuilds changed packages
- 📅 **Daily snapshots**: Automatic dated archive releases

All Containerfiles are configured to use this repository:

```ini
[skorion]
SigLevel = Optional TrustAll
Server = https://github.com/SkorionOS/skorion-packages/releases/download/latest
```

## Project Status

🚀 **90% Complete** - Core bootc integration finished, ready for testing.

### ✅ Completed (90%)
- [x] **bootc + dracut integration** - Full container-native OS stack
- [x] **Three-layer architecture** - minimal → base → desktop variants
- [x] **Desktop variants** - KDE, GNOME, Hyprland
- [x] **AUR packages repository** - Separate repo with CI/CD
- [x] **System services** - All services configured
- [x] **Build optimization** - Efficient layer caching

### 🔨 In Progress (10%)
- [ ] Complete build testing
- [ ] Boot image generation
- [ ] Hardware quirks integration
- [ ] Performance benchmarking
- [ ] CI/CD automation

**See [BUILD_SUMMARY.md](BUILD_SUMMARY.md) for detailed progress.**

## Prerequisites

### Linux Build Host

```bash
# Arch Linux
sudo pacman -S \
    podman \
    buildah \
    skopeo \
    just \
    qemu-full

# Fedora
sudo dnf install \
    podman \
    buildah \
    skopeo \
    just \
    qemu-system-x86

# Optional: bootc-image-builder for generating bootable images
# (May need to build from source or use container)
```

### macOS Build Host (with OrbStack)

```bash
# Install OrbStack (Docker compatible)
brew install orbstack

# Install build tools
brew install just jq

# Optional: Dockerfile linting
brew install hadolint

# See MACOS.md for detailed instructions
```

**Note**: macOS can build container images but cannot generate bootable images directly. See [MACOS.md](MACOS.md) for the complete macOS workflow.

### Runtime Requirements (Target System)

- bootc
- composefs
- systemd-boot
- Arch Linux kernel with composefs support

## Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/SkorionOS/skorion-bootc.git
cd skorion-bootc
```

### 2. Build the Container Image

```bash
# Linux (with Podman)
just build-base
just build-kde

# macOS (with Docker/OrbStack)
just -f Justfile.macos build-base
just -f Justfile.macos build-kde

# Or create a symlink on macOS
ln -sf Justfile.macos Justfile.local
just build-kde
```

### 3. Generate Bootable Image

```bash
# Linux only (requires bootc-image-builder)
just generate-image kde

# Output: output/skorionos-kde.img

# macOS: Export and convert on Linux
just -f Justfile.macos export-for-linux kde
# Transfer to Linux machine for bootable image generation
```

**Note**: Bootable image generation requires Linux. macOS users can build containers and push to registry, then generate images on Linux/CI. See [MACOS.md](MACOS.md) for details.

### 4. Test in Virtual Machine

```bash
# Using QEMU
just run-vm

# Or manually
qemu-system-x86_64 \
    -enable-kvm \
    -m 8G \
    -cpu host \
    -smp 4 \
    -drive file=output/skorionos-bootc.img,format=raw \
    -bios /usr/share/ovmf/x64/OVMF.fd
```

## Directory Structure

```
skorion-bootc/
├── Containerfile.minimal      # bootc + dracut foundation
├── Containerfile.base         # Complete system layer
├── Containerfile.{kde,gnome,hyprland}  # Desktop variants
├── manifest                   # Package lists and configs
├── rootfs/                    # Configuration overlay
├── scripts/                   # Build helper functions
└── Justfile*                  # Build automation
```

**Note**: AUR/local packages are in the separate [skorion-packages](https://github.com/SkorionOS/skorion-packages) repository.

## Building Details

### Image Variants

| Variant | Base | Purpose |
|---------|------|---------|
| **minimal** | Arch Linux | bootc + dracut + kernel foundation |
| **base** | minimal | Full desktop system support (no DE) |
| **kde** | base | KDE Plasma desktop |
| **gnome** | base | GNOME Shell desktop |
| **hyprland** | base | Hyprland tiling compositor |

### Build Optimization

- **Layer caching** - Stable packages first, configs last
- **Shared base** - Desktop variants share base layer
- **Hook management** - dracut runs once at the end
- **Incremental updates** - Users only download changed layers

**See [BUILD_SUMMARY.md](BUILD_SUMMARY.md) for architecture details.**

## Update Workflow

### End User Updates

```bash
sudo bootc update    # Download and stage update
sudo reboot          # Boot into new version
sudo bootc rollback  # Rollback if needed
```

Updates are incremental - only changed container layers are downloaded.

### Developer Workflow

```bash
# 1. Edit Containerfile
# 2. Build: just build-base
# 3. Push to registry
# 4. Users run: bootc update
```

All system changes go through Containerfile - no manual package installation on running system.

## Comparison with frzr

| Feature | frzr (Current) | bootc (New) |
|---------|----------------|-------------|
| **Updates** | Full image download | Incremental layers |
| **Distribution** | Custom server | OCI registry |
| **Format** | tar.zst | OCI container |
| **Tooling** | Custom | Standard ecosystem |
| **Maturity** | Production | Experimental |
| **Speed** | 3-5 minutes | ~50 seconds |

## Desktop Variants

### KDE Plasma (Default)
- Steam Deck-like experience
- Gamescope session
- Full desktop fallback

### GNOME
- Modern, touch-friendly
- Wayland-native
- Steam integration

### Hyprland
- Tiling compositor
- Advanced customization
- Minimal resource usage

## Contributing

Contributions, testing, and feedback are welcome!

```bash
# Fork, clone, and make changes
git clone https://github.com/YOUR_USERNAME/skorion-bootc.git

# Test your changes
just build-base
just run-vm

# Submit PR
```

## Troubleshooting

### Build Issues
- Clean cache: `podman system prune -a`
- Check logs in build output
- Ensure skorion-packages repo is accessible

### Boot Issues
- Disable Secure Boot (currently unsupported)
- Use UEFI boot mode
- Check bootc logs: `journalctl -u bootc`

### Update Issues
- Check status: `bootc status`
- Rollback: `bootc rollback`
- View logs: `journalctl -u bootc-update`

## Documentation

- [BUILD_SUMMARY.md](BUILD_SUMMARY.md) - Detailed architecture and progress
- [skorion-packages](https://github.com/SkorionOS/skorion-packages) - AUR/local packages repo

## Resources

- [bootc](https://github.com/containers/bootc) - Container-native OS
- [composefs](https://github.com/containers/composefs) - Zero-copy filesystem
- [steamos-bootc](https://github.com/bootcrew/steamos-bootc) - Reference implementation

## License

GPLv3 - See LICENSE file

## Acknowledgments

- Based on the excellent work of the ChimeraOS/SkorionOS project
- Inspired by steamos-bootc and arch-bootc experiments
- Thanks to the bootc and composefs developers

---

**Note**: This is experimental software. Use on production devices at your own risk. For stable SkorionOS, use the main frzr-based distribution.

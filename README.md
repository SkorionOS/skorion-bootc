# SkorionOS Bootc

A modern, container-native implementation of SkorionOS using bootc and composefs technology.

## Overview

SkorionOS Bootc is an experimental reimplementation of SkorionOS (formerly ChimeraOS) using container-native operating system deployment. This project leverages:

- **bootc**: Container-native OS management
- **composefs**: Fast, zero-copy filesystem mounting
- **OCI containers**: Standardized image format and distribution
- **Arch Linux**: Rolling release base system

### Key Advantages

- ⚡ **Faster updates**: ~50 seconds vs several minutes
- 📦 **Incremental updates**: Only download changed container layers
- 🐳 **Container ecosystem**: Use standard container registries and tools
- 🔄 **Atomic updates**: All-or-nothing system updates with automatic rollback
- 🎮 **Gaming optimized**: Optimized for handheld gaming devices

## Architecture

```
┌─────────────────────────────────────┐
│  Containerfile (System Definition)  │
└──────────────┬──────────────────────┘
               │
               ↓
┌─────────────────────────────────────┐
│  OCI Image (Built & Published)      │
└──────────────┬──────────────────────┘
               │
               ↓
┌─────────────────────────────────────┐
│  bootc client (On User Device)      │
└──────────────┬──────────────────────┘
               │
               ↓
┌─────────────────────────────────────┐
│  composefs (Zero-copy Mount)        │
└─────────────────────────────────────┘
```

## AUR and Local Packages

SkorionOS uses a separate **[skorion-packages](https://github.com/SkorionOS/skorion-packages)** repository to manage AUR and local packages:

- 🎯 **自建 pacman 仓库**: 预构建的 AUR 和本地包
- 📦 **GitHub Releases**: 使用 `latest` Release 作为滚动仓库
- 🔄 **增量构建**: CI 只重建有变化的包
- 📅 **每周快照**: 自动创建带日期的归档 Release

所有 Containerfile 已配置使用此仓库：

```ini
[skorion]
SigLevel = Optional TrustAll
Server = https://github.com/SkorionOS/skorion-packages/releases/download/latest
```

## Project Status

🚧 **Work In Progress** - This is an experimental project for testing and validation.

### Completed
- [x] Project structure
- [x] Base system Containerfile
- [x] Desktop environment variants (KDE, GNOME, Hyprland)
- [x] AUR/local packages repository
- [x] Build scripts
- [x] CI/CD workflows
- [ ] Boot image generation
- [ ] Hardware quirks integration
- [ ] Update mechanism testing

### Planned
- [ ] Performance benchmarking vs frzr
- [ ] Migration tool from frzr to bootc
- [ ] User testing
- [ ] Production deployment

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
├── README.md                   # This file
├── Justfile                    # Build automation
├── Containerfile.base          # Base system definition
├── Containerfile.kde           # KDE variant
├── Containerfile.gnome         # GNOME variant
├── Containerfile.hyprland      # Hyprland variant
├── config/                     # System configurations
│   ├── systemd/               # Systemd units
│   ├── sddm/                  # Display manager config
│   └── services/              # Service configurations
├── rootfs/                     # Root filesystem overlay
│   ├── etc/                   # System configuration files
│   └── usr/                   # User binaries and data
├── scripts/                    # Helper scripts
│   ├── build-packages.sh      # Build AUR/local packages
│   ├── postinstall.sh         # Post-installation tasks
│   └── generate-image.sh      # Image generation
├── packages/                   # Local package definitions
│   ├── aur/                   # AUR PKGBUILDs
│   └── local/                 # Local PKGBUILDs
└── output/                     # Build outputs
```

## Building Details

### Container Build Process

1. **Base Layer**: Arch Linux with core packages
2. **Gaming Layer**: Steam, Mesa, drivers
3. **Desktop Layer**: KDE/GNOME/Hyprland
4. **Customization Layer**: SkorionOS-specific configs

### Package Management

All packages must be installed during image build:

```dockerfile
# Official packages
RUN pacman -Syu --noconfirm \
    steam \
    gamescope \
    plasma-desktop

# AUR packages (pre-built)
COPY packages/aur/*.pkg.tar.zst /tmp/
RUN pacman -U --noconfirm /tmp/*.pkg.tar.zst
```

## Update Workflow

### For End Users

```bash
# Check for updates
sudo bootc status

# Update system (downloads only changed layers)
sudo bootc update

# Reboot to new version
sudo systemctl reboot

# If issues occur, rollback
sudo bootc rollback
```

### For Developers

```bash
# 1. Modify Containerfile
vim Containerfile.base

# 2. Build new image
just build-base

# 3. Tag with version
podman tag skorionos:base ghcr.io/skorionos/skorionos:v1.2.3

# 4. Push to registry
podman push ghcr.io/skorionos/skorionos:v1.2.3

# 5. Users pull update with bootc
# (Automatically happens with 'bootc update')
```

## Comparison with frzr

| Feature | frzr (Current) | bootc (New) |
|---------|----------------|-------------|
| **Update Speed** | 3-5 minutes | ~50 seconds |
| **Incremental Updates** | ❌ Full image | ✅ Layer-based |
| **Distribution** | Custom server | Standard OCI registry |
| **Standard Format** | tar.zst | OCI container |
| **Ecosystem** | Custom tools | Container ecosystem |
| **Complexity** | Low | Medium |
| **Maturity** | High | Experimental |

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

This is an experimental project. Contributions, testing, and feedback are welcome!

### Development Setup

```bash
# Fork and clone
git clone https://github.com/YOUR_USERNAME/skorion-bootc.git
cd skorion-bootc

# Make changes
vim Containerfile.base

# Test locally
just build-test
just run-vm

# Submit PR
git push origin your-feature
```

## Troubleshooting

### Build Failures

```bash
# Clean build cache
podman system prune -a

# Rebuild from scratch
just clean
just build-base
```

### Boot Issues

- Check UEFI boot settings
- Verify Secure Boot is disabled (for now)
- Use OVMF firmware for QEMU testing

### Update Issues

```bash
# Check bootc status
sudo bootc status

# View logs
sudo journalctl -u bootc-update

# Force rollback
sudo bootc rollback
```

## Resources

- [bootc Documentation](https://github.com/containers/bootc)
- [composefs Project](https://github.com/containers/composefs)
- [steamos-bootc Reference](https://github.com/bootcrew/steamos-bootc)
- [SkorionOS Main Project](https://github.com/SkorionOS/skorionos)

## License

GPLv3 - See LICENSE file

## Acknowledgments

- Based on the excellent work of the ChimeraOS/SkorionOS project
- Inspired by steamos-bootc and arch-bootc experiments
- Thanks to the bootc and composefs developers

---

**Note**: This is experimental software. Use on production devices at your own risk. For stable SkorionOS, use the main frzr-based distribution.

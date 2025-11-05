# SkorionOS Bootc - Architecture Documentation

## System Architecture

### High-Level Overview

```
┌─────────────────────────────────────────────────────────┐
│                    Developer Workflow                    │
│                                                          │
│  1. Edit Containerfile                                  │
│  2. Build OCI Image (podman build)                      │
│  3. Push to Registry (GitHub/Quay.io)                   │
└──────────────────┬──────────────────────────────────────┘
                   │
                   ↓
┌─────────────────────────────────────────────────────────┐
│                   OCI Container Registry                 │
│                                                          │
│  ghcr.io/skorionos/skorionos:kde-v1.0.0                │
│  ghcr.io/skorionos/skorionos:gnome-v1.0.0              │
│  ghcr.io/skorionos/skorionos:hyprland-v1.0.0           │
└──────────────────┬──────────────────────────────────────┘
                   │
                   ↓
┌─────────────────────────────────────────────────────────┐
│                      User Device                         │
│                                                          │
│  bootc update ──> skopeo copy ──> /usr/lib/bootc/storage│
│                                                          │
│  composefs mount ──> /sysroot                           │
│                                                          │
│  systemd-boot ──> Linux Kernel ──> SkorionOS            │
└─────────────────────────────────────────────────────────┘
```

## Container Image Layers

### Layer Architecture

```
┌─────────────────────────────────────────┐
│  Desktop Layer (KDE/GNOME/Hyprland)     │  ← 2-3 GB
│  - Desktop environment                   │
│  - Applications                          │
│  - Themes & configs                      │
├─────────────────────────────────────────┤
│  Gaming Layer                            │  ← 3-4 GB
│  - Steam                                 │
│  - Gamescope                             │
│  - Game libraries                        │
│  - Gaming tools                          │
├─────────────────────────────────────────┤
│  SkorionOS Base Layer                    │  ← 2-3 GB
│  - Core utilities                        │
│  - Audio (PipeWire)                      │
│  - Graphics drivers                      │
│  - Container runtime                     │
├─────────────────────────────────────────┤
│  Arch Linux Base                         │  ← 1-2 GB
│  - systemd                               │
│  - pacman                                │
│  - Basic tools                           │
└─────────────────────────────────────────┘

Total: ~8-12 GB depending on variant
```

### Layer Sharing Benefits

```
Base Image: 8 GB
├── KDE variant:      +2 GB  = 10 GB total
├── GNOME variant:    +2.5 GB = 10.5 GB total
└── Hyprland variant: +1 GB  = 9 GB total

But on disk: 8 GB (base) + 2 + 2.5 + 1 = 13.5 GB
Not: 10 + 10.5 + 9 = 29.5 GB

Savings: ~16 GB (54%)
```

## Filesystem Layout

### Boot Time

```
/
├── sysroot/                    # OSTree-style root
│   ├── ostree/                # (Compatibility symlink)
│   └── bootc/
│       └── storage/           # Container image storage
│           ├── overlay/       # Container layers
│           ├── images/        # Image manifests
│           └── objects/       # Content-addressable blobs
```

### Runtime

```
/
├── usr/                       # Read-only system files
│   ├── bin/                   # Binaries
│   ├── lib/                   # Libraries
│   └── share/                 # Shared data
├── etc/                       # Configuration (writable)
├── var/                       # Variable data (writable)
├── home/                      # User homes (writable)
└── tmp/                       # Temporary files
```

## Update Mechanism

### Update Flow

```
1. User runs: sudo bootc update
   │
   ↓
2. bootc checks registry for new image
   │
   ↓
3. skopeo copy downloads changed layers only
   │  Example: Only 500MB instead of 10GB
   │
   ↓
4. New image stored in /usr/lib/bootc/storage
   │
   ↓
5. composefs prepares new root filesystem
   │  Zero-copy! Just metadata changes
   │
   ↓
6. Bootloader updated with new entry
   │
   ↓
7. User reboots to new version
   │
   ↓
8. If issues: bootc rollback
```

### Version Management

```
Bootloader Menu:
├── SkorionOS v1.2.3 (current) ✓
├── SkorionOS v1.2.2 (previous)
└── SkorionOS v1.2.1 (old)

Only 2-3 versions kept
Automatic cleanup of old versions
```

## Build Process

### Development Build

```bash
# Stage 1: Base system
Containerfile.base
├── FROM archlinux:latest
├── RUN pacman -Syu (base packages)
├── RUN pacman -S (skorionos packages)
├── RUN useradd gamer
└── COPY rootfs/ /

# Stage 2: Desktop variant
Containerfile.kde
├── FROM skorionos:base-latest
├── RUN pacman -S (plasma packages)
├── COPY config/kde/ /
└── RUN systemctl enable sddm

# Output: skorionos:kde-latest
```

### Production Build (CI/CD)

```
GitHub Action Trigger
│
↓
Build Container Images
├── Build base
├── Build KDE
├── Build GNOME
└── Build Hyprland
│
↓
Tag with Version
├── latest
├── v1.2.3
└── stable
│
↓
Push to Registry
└── ghcr.io/skorionos/skorionos:*
```

## Storage Efficiency

### Content-Addressable Storage

```
File: /usr/bin/bash (same in all variants)
├── SHA256: abc123...
└── Stored once, referenced multiple times

File: /usr/share/backgrounds/wallpaper.png
├── SHA256: def456...
└── Shared between versions if unchanged
```

### Update Efficiency

```
Update v1.0 → v1.1:
├── Changed: kernel, mesa, steam (500MB)
├── Unchanged: 95% of system (9.5GB)
└── Download: 500MB only

Update v1.0 → v1.2:
├── Changed: many packages (2GB)
├── Unchanged: 80% of system (8GB)
└── Download: 2GB only
```

## Security Model

### Read-Only Root

```
/ (read-only)
├── /usr (read-only) ✓
├── /etc (writable) ✓
├── /var (writable) ✓
└── /home (writable) ✓
```

### Benefits

- Malware can't modify system files
- Accidental corruption prevented
- Easy system recovery
- Verifiable system integrity

### Limitations

- Can't install packages at runtime
- Must rebuild image for system changes
- Learning curve for users

## Comparison with frzr

### frzr (Current ChimeraOS)

```
Update Process:
1. Download full tar.zst (3-5 GB)
2. Extract to new btrfs subvolume
3. Switch subvolume
4. Reboot

Storage:
- Full copy per version
- 2-3 versions = 10-15 GB

Pros:
- Simple
- Proven
- Fast to implement

Cons:
- Large downloads
- No incremental updates
- Custom tooling
```

### bootc (This Project)

```
Update Process:
1. Download changed layers (500MB-2GB)
2. composefs mount (instant)
3. Update bootloader
4. Reboot

Storage:
- Shared layers
- 2-3 versions = 10-12 GB (deduplicated)

Pros:
- Smaller downloads
- Standard OCI format
- Container ecosystem

Cons:
- More complex
- Newer technology
- Requires composefs
```

## Performance Characteristics

### Boot Time

```
Target: < 15 seconds to login
├── UEFI: 2s
├── Kernel: 3s
├── systemd: 5s
├── Display Manager: 3s
└── Desktop: 2s
```

### Update Time

```
Small update (kernel + drivers):
├── Download: 30s (500MB @ 15MB/s)
├── Verify: 5s
├── Mount: 5s
└── Total: ~40s

Large update (new release):
├── Download: 2min (2GB @ 15MB/s)
├── Verify: 10s
├── Mount: 10s
└── Total: ~2.5min
```

### Disk I/O

```
composefs advantages:
├── Zero-copy mounting
├── Lazy loading (on-demand)
├── Efficient caching
└── Minimal write amplification
```

## Hardware Requirements

### Minimum

- CPU: 64-bit x86_64
- RAM: 4 GB
- Disk: 30 GB
- GPU: Any with Mesa support

### Recommended

- CPU: 4+ cores
- RAM: 8 GB
- Disk: 60 GB SSD
- GPU: AMD or Intel (best Linux support)

### Tested Devices

- [ ] Steam Deck
- [ ] AYANEO devices
- [ ] GPD Win devices
- [ ] ASUS ROG Ally
- [ ] Generic x86_64 PCs
- [ ] Virtual machines (QEMU/KVM)

## Future Enhancements

### Planned

1. **Immutable /etc** - More security
2. **A/B partitioning** - Faster rollback
3. **Delta updates** - Even smaller downloads
4. **Signed images** - Verification
5. **Multi-arch** - ARM64 support

### Research

1. **eBPF integration** - Advanced monitoring
2. **Zstd compression** - Smaller images
3. **GPU-accelerated boot** - Faster startup
4. **Predictive caching** - Better performance
5. **Distributed registry** - CDN support

---

This architecture is designed to be:
- **Fast**: Quick updates and boots
- **Reliable**: Atomic updates with rollback
- **Efficient**: Shared storage and incremental updates
- **Secure**: Read-only root and verified images
- **Modern**: Standard container technologies


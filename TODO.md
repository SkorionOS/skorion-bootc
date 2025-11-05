# SkorionOS Bootc - TODO List

## Immediate Tasks (This Week)

- [ ] Test base Containerfile build
- [ ] Verify package installation
- [ ] Test KDE variant build
- [ ] Create minimal test image
- [ ] Boot test image in QEMU

## High Priority

### Build System
- [ ] Fix any package conflicts in Containerfile.base
- [ ] Add error handling to build scripts
- [ ] Implement build caching strategy
- [ ] Add progress indicators to scripts
- [ ] Create build verification tests

### Desktop Environments
- [ ] Complete KDE Plasma configuration
- [ ] Add gamescope-session integration
- [ ] Configure KDE for gaming mode
- [ ] Test GNOME variant
- [ ] Create Hyprland variant

### Core Functionality
- [ ] Implement first-boot setup
- [ ] Add user home expansion
- [ ] Configure Flatpak integration
- [ ] Setup systemd services
- [ ] Add network configuration

## Medium Priority

### Hardware Support
- [ ] Port device quirks from main repo
- [ ] Add handheld device detection
- [ ] Integrate controller drivers
- [ ] Add TDP control (handheld devices)
- [ ] Test on real hardware

### Gaming Features
- [ ] Configure Steam integration
- [ ] Add MangoHud overlay
- [ ] Setup gamemode
- [ ] Configure gamescope
- [ ] Test game compatibility

### System Services
- [ ] Port all ChimeraOS services
- [ ] Add power management
- [ ] Configure suspend/resume
- [ ] Add update notifications
- [ ] Implement auto-update option

## Low Priority

### Documentation
- [ ] Add architecture diagrams
- [ ] Write troubleshooting guide
- [ ] Create video tutorials
- [ ] Translate to other languages
- [ ] Add FAQ section

### Optimization
- [ ] Reduce image size
- [ ] Optimize boot time
- [ ] Minimize memory usage
- [ ] Improve build speed
- [ ] Add layer caching

### Testing
- [ ] Create automated tests
- [ ] Add CI/CD pipeline
- [ ] Performance benchmarks
- [ ] Compatibility testing
- [ ] Security audit

## Research & Investigation

- [ ] Research composefs kernel requirements
- [ ] Investigate bootc update optimizations
- [ ] Study steamos-bootc implementation
- [ ] Explore arch-bootc progress
- [ ] Test different bootloaders (systemd-boot vs grub)

## Bug Fixes

*No bugs reported yet - this is experimental!*

## Ideas & Future Features

- [ ] Multi-boot configuration
- [ ] Recovery mode
- [ ] Remote management interface
- [ ] Cloud save sync
- [ ] Performance profiles
- [ ] Custom theme creator
- [ ] Plugin system
- [ ] Web-based configurator

## Community Requests

*Awaiting community feedback*

## Blockers

- [ ] Need access to test hardware
- [ ] Waiting for composefs kernel support verification
- [ ] Need to test bootc-image-builder
- [ ] Require feedback from potential users

---

## Completed ✅

- [x] Create project repository
- [x] Write README.md
- [x] Create Containerfile.base
- [x] Create Containerfile.kde
- [x] Create Containerfile.gnome
- [x] Write Justfile for automation
- [x] Create build scripts
- [x] Setup directory structure
- [x] Add .gitignore
- [x] Create QUICK_START.md
- [x] Write LICENSE
- [x] Create ROADMAP.md

---

Last updated: 2025-11-05


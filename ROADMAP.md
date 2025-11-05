# SkorionOS Bootc - Development Roadmap

## Phase 1: Foundation (当前阶段)

### Week 1-2: Project Setup ✅
- [x] Create project structure
- [x] Write comprehensive README
- [x] Create base Containerfile
- [x] Setup build automation (Justfile)
- [x] Create helper scripts

### Week 3-4: Base System
- [ ] Test base system build
- [ ] Verify all core packages install correctly
- [ ] Test in QEMU VM
- [ ] Add missing essential packages
- [ ] Optimize package selection

### Week 5-6: Desktop Variants
- [ ] Complete KDE variant
- [ ] Complete GNOME variant
- [ ] Add Hyprland variant
- [ ] Test each variant in VM
- [ ] Configure autologin and gaming mode

## Phase 2: Gaming Integration

### Week 7-8: Steam and Gaming
- [ ] Integrate gamescope
- [ ] Configure gamescope-session
- [ ] Add Steam library management
- [ ] Test Steam games in VM
- [ ] Configure controller support

### Week 9-10: Hardware Support
- [ ] Port device quirks from ChimeraOS
- [ ] Add handheld device drivers
- [ ] Integrate HHD (Handheld Daemon)
- [ ] Test on real hardware
- [ ] Add hardware detection scripts

### Week 11-12: Performance Optimization
- [ ] Optimize boot time
- [ ] Configure CPU governor
- [ ] Add power management
- [ ] Optimize memory usage
- [ ] Test gaming performance

## Phase 3: bootc Integration

### Week 13-14: composefs Setup
- [ ] Verify composefs kernel support
- [ ] Test composefs mounting
- [ ] Configure bootc client
- [ ] Test image deployment
- [ ] Benchmark update speed

### Week 15-16: Update Mechanism
- [ ] Setup OCI registry
- [ ] Configure bootc update service
- [ ] Test incremental updates
- [ ] Implement rollback testing
- [ ] Add update notifications

### Week 17-18: Migration Tools
- [ ] Create frzr-to-bootc migration script
- [ ] Test migration process
- [ ] Add data preservation
- [ ] Document migration steps
- [ ] Create migration guide

## Phase 4: Features & Polish

### Week 19-20: System Services
- [ ] Port all ChimeraOS systemd services
- [ ] Add first-boot setup
- [ ] Configure networking
- [ ] Add update management
- [ ] Test service dependencies

### Week 21-22: User Experience
- [ ] Create SkorionOS branding
- [ ] Add custom themes
- [ ] Configure default applications
- [ ] Add welcome screen
- [ ] Create user documentation

### Week 23-24: AUR Integration
- [ ] Setup AUR package building
- [ ] Port critical AUR packages
- [ ] Automate package builds
- [ ] Create package repository
- [ ] Document package management

## Phase 5: Testing & Release

### Week 25-26: Alpha Testing
- [ ] Internal testing on multiple devices
- [ ] Fix critical bugs
- [ ] Performance benchmarking
- [ ] Compare with frzr version
- [ ] Collect feedback

### Week 27-28: Beta Release
- [ ] Public beta announcement
- [ ] Setup issue tracking
- [ ] Create testing guidelines
- [ ] Monitor beta feedback
- [ ] Fix reported issues

### Week 29-30: Release Preparation
- [ ] Final testing
- [ ] Documentation review
- [ ] Create release notes
- [ ] Setup release infrastructure
- [ ] Prepare announcement

### Week 31-32: Version 1.0 Release
- [ ] Official release
- [ ] Publish documentation
- [ ] Community announcement
- [ ] Monitor initial adoption
- [ ] Provide support

## Future Enhancements

### Post-1.0
- [ ] Multi-architecture support (ARM64)
- [ ] Improved hardware detection
- [ ] Advanced power profiles
- [ ] Cloud gaming integration
- [ ] Remote management tools

### Long-term Vision
- [ ] Become reference implementation for gaming Linux
- [ ] Contribute improvements back to bootc/composefs
- [ ] Build community ecosystem
- [ ] Partner with hardware vendors
- [ ] Support more desktop environments

## Performance Targets

- ⚡ Boot time: < 15 seconds to desktop
- 🔄 Update time: < 60 seconds for typical update
- 💾 Disk usage: < 15GB for base system
- 🎮 Gaming performance: Within 5% of native
- 🔋 Battery life: Match or exceed frzr version

## Success Metrics

- 100+ active testers in beta
- < 10 critical bugs at release
- 50%+ faster updates than frzr
- 90%+ compatibility with ChimeraOS configs
- Positive community feedback

## Dependencies

### Critical
- composefs kernel support in mainline Linux
- bootc stability and features
- OCI registry availability
- Testing hardware availability

### Optional
- bootc-image-builder improvements
- Better documentation
- Community contributions
- Hardware vendor support

## Risks & Mitigation

### Risk: composefs not stable enough
**Mitigation**: Keep frzr as fallback option

### Risk: bootc not ready for production
**Mitigation**: Extended beta testing period

### Risk: Performance worse than frzr
**Mitigation**: Optimization phase before release

### Risk: Hardware compatibility issues
**Mitigation**: Extensive testing on varied devices

### Risk: User migration problems
**Mitigation**: Thorough migration tools and docs

## Notes

- This roadmap is flexible and may change based on feedback
- Community input is welcome
- Some phases may overlap
- Timeline is approximate (32 weeks ≈ 8 months)

---

Last updated: 2025-11-05


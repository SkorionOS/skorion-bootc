# SkorionOS Bootc - Build Summary

## 📊 镜像构建结果

| 变体 | 镜像标签 | 大小 | 相比 Base 增量 | 桌面环境 |
|------|---------|------|---------------|----------|
| **Base** | `skorionos:base-latest` | 6.62 GB | - | 无（命令行） |
| **GNOME** | `skorionos:gnome-latest` | 7.80 GB | +1.18 GB | GNOME Shell 49 |
| **KDE** | `skorionos:kde-latest` | 8.49 GB | +1.87 GB | Plasma Desktop 6.5 |
| **Hyprland** | `skorionos:hyprland-latest` | 8.19 GB | +1.57 GB | Hyprland 0.51 |

## 🎯 构建成功验证

### Base 镜像
- ✅ 837 个软件包已安装
- ✅ Steam 游戏平台
- ✅ Mesa/Vulkan 驱动
- ✅ 音频系统（PipeWire）
- ✅ 容器运行时（Podman）
- ✅ 输入法（ibus）
- ✅ 系统工具完整

### GNOME 变体
- ✅ GNOME Shell 49.1
- ✅ GNOME Control Center 49.1
- ✅ Nautilus 文件管理器 49.1
- ✅ Epiphany 浏览器 49.1
- ✅ GNOME Shell 扩展支持
- ✅ Wayland 会话支持

### KDE 变体
- ✅ Plasma Desktop 6.5.1
- ✅ Dolphin 文件管理器
- ✅ Konsole 终端
- ✅ Falkon 浏览器
- ✅ fcitx5 输入法
- ✅ SDDM 显示管理器
- ✅ Wayland 会话支持

### Hyprland 变体
- ✅ Hyprland 0.51.1
- ✅ Waybar 状态栏 0.14.0
- ✅ Thunar 文件管理器 4.20.6
- ✅ Kitty 终端
- ✅ fcitx5 输入法
- ✅ Rofi/Wofi 启动器
- ✅ Hypr 生态工具（hypridle, hyprlock, hyprpaper）
- ✅ Wayland 原生

## 🏗️ 分层架构优化

### Base 镜像（37 层）

按更新频率组织，最稳定的在前：

```
Layer 1:     系统初始化 (pacman-key, 系统更新)
Layer 2:     skorion 自定义仓库 (最高优先级)
Layer 3:     multilib 仓库启用
Layer 4:     Package Overrides (自定义内核 + 固定版本包)
             - linux-skchos 6.17.7-1 + headers
             - libxkbcommon 1.11.0-1 (3个包)
             - ibus-pinyin 1.5.1-2.3 (SteamOS版本)
Layer 5-28:  系统包按功能分层
             - Graphics, Firmware, Audio, Network
             - Gaming, Container, Services
             - Fonts, Multimedia, Tools
             - AUR/Local packages from skorion repo
Layer 29-32: 用户创建 + 服务启用
Layer 33:    rootfs overlay (53个配置文件)
Layer 34:    SDDM gamescope session 配置
Layer 35:    系统配置 (locale, hostname, SSH, etc.)
Layer 36:    frzr 系统调整 (vim, steam, waydroid, etc.)
Layer 37:    最终清理
```

### GNOME 变体（13 层）

```
Layer 1:   Core GNOME Shell              382 MB  ★ 最大层
Layer 2:   Control & Settings            48 MB
Layer 3:   System Integration            12.7 MB
Layer 4:   File Manager (Nautilus)       11.7 MB
Layer 5:   System Utilities              25.6 MB
Layer 6:   Text Editor & Terminal        13.2 MB
Layer 7:   Software Center               7.99 MB
Layer 8:   Web Browser (Epiphany)        6.92 MB
Layer 9:   Fonts & Icons                 668 MB
Layer 10:  SDDM Config                   116 B
Layer 11:  Config Files                  (占位)
Layer 12:  Desktop Files                 0 B
Layer 13:  Cleanup                       108 KB
```

### KDE 变体（14 层）

```
Layer 1:   Core Plasma Desktop           858 MB  ★ 最大层
Layer 2:   System Integration            417 MB
Layer 3:   KDE Applications              274 MB
Layer 4:   Advanced Utilities            127 MB
Layer 5:   Security & Auth               62 MB
Layer 6:   Package Management (Discover) 57 MB
Layer 7:   Multimedia (kpipewire)        489 KB
Layer 8:   Input Method (fcitx5)         127 MB
Layer 9:   Web Browser (Falkon)          34 MB
Layer 10:  Accessibility (Onboard)       13 MB
Layer 11:  Wallpapers                    63 MB
Layer 12:  SDDM Config                   116 B
Layer 13:  Config Files                  (占位)
Layer 14:  Cleanup                       115 KB
```

### Hyprland 变体（21 层）

```
Layer 1:   Core Hyprland                 58 MB  ★ 最大层
Layer 2:   Hypr Tools (idle/lock/paper)  2 MB
Layer 3:   Desktop Portals               1 MB
Layer 4:   Status Bar & Notifications    18 MB
Layer 5:   Launchers (rofi, wofi)        2 MB
Layer 6:   Terminal (kitty) & Editor     82 MB
Layer 7:   File Manager (Thunar)         24 MB
Layer 8:   System Utilities              62 MB
Layer 9:   Graphics & Media              43 MB
Layer 10:  Screenshot & Clipboard        6 MB
Layer 11:  Theme & Appearance            17 MB
Layer 12:  Polkit (Authentication)       0.3 MB
Layer 13:  Input Method (fcitx5)         350 MB
Layer 14:  Session Manager (uwsm)        0.3 MB
Layer 15:  Software Center               13 MB
Layer 16:  Web Browser (Falkon)          16 MB
Layer 17:  Fonts & Icons                 409 MB
Layer 18:  dconf-editor                  3 MB
Layer 19:  PAM Configuration             <1 KB
Layer 20:  Config Files                  (占位)
Layer 21:  Cleanup                       <1 KB
```

## 📦 关键包版本

| 组件 | Base | GNOME | KDE | Hyprland |
|------|------|-------|-----|----------|
| Kernel | 6.x (OrbStack) | 同左 | 同左 | 同左 |
| Mesa | 24.x | 同左 | 同左 | 同左 |
| PipeWire | 1.x | 同左 | 同左 | 同左 |
| Steam | Latest | 同左 | 同左 | 同左 |
| Desktop | - | GNOME 49 | Plasma 6.5 | Hyprland 0.51 |
| Input Method | ibus | 同左 | fcitx5 | fcitx5 |
| Browser | - | Epiphany 49 | Falkon | Falkon |

## 🎮 游戏优化特性

所有变体都包含：
- ✅ Steam 游戏平台
- ✅ MangoHud 性能监控
- ✅ GameMode 性能优化
- ✅ Mesa/Vulkan 完整驱动
- ✅ 32-bit 库支持（multilib）
- ✅ 硬件加速（VAAPI）

## 🚀 性能优化

### 分层缓存策略
- **稳定层在前**：驱动、固件等很少变化的放在最前
- **配置层在后**：用户配置、系统设置等经常变化的放在最后
- **增量构建快**：修改配置层，前面 30+ 层全部缓存复用

### 镜像推送优化
- **只推送变化的层**：OCI 镜像格式的天然优势
- **共享 Base 层**：GNOME 和 KDE 共享 6.62GB 的 Base
- **网络带宽节省**：用户更新只下载变化部分

## 🔄 更新策略

### 推荐分发方式

1. **发布到 Registry**
   ```bash
   docker tag skorionos:base-latest ghcr.io/skorionos/skorionos:base-latest
   docker tag skorionos:kde-latest ghcr.io/skorionos/skorionos:kde-latest
   docker tag skorionos:gnome-latest ghcr.io/skorionos/skorionos:gnome-latest
   
   docker push ghcr.io/skorionos/skorionos:base-latest
   docker push ghcr.io/skorionos/skorionos:kde-latest
   docker push ghcr.io/skorionos/skorionos:gnome-latest
   ```

2. **用户端更新**
   ```bash
   # bootc 自动处理层级增量更新
   bootc upgrade
   ```

3. **回滚机制**
   ```bash
   # OSTree/composefs 提供的原子回滚
   bootc rollback
   ```

## 📈 构建性能

| 阶段 | 时间 | 说明 |
|------|------|------|
| Base 首次构建 | ~6 分钟 | 包含下载所有包 |
| GNOME 增量构建 | ~2 分钟 | 基于 Base 缓存 |
| KDE 增量构建 | ~4 分钟 | 基于 Base 缓存 |
| **总计** | ~12 分钟 | macOS (Apple Silicon) |

### 构建环境
- 平台：macOS (Apple Silicon M1/M2/M3)
- 容器引擎：OrbStack Docker
- 目标架构：linux/amd64 (交叉编译)
- 构建方式：BuildKit

## 🎨 桌面环境对比

| 特性 | GNOME | KDE | Hyprland |
|------|-------|-----|----------|
| **镜像大小** | 7.80 GB | 8.49 GB | 8.19 GB |
| **增量大小** | +1.18 GB | +1.87 GB | +1.57 GB |
| **内存占用** | 中等 | 较高 | 低 |
| **触屏支持** | 优秀 | 优秀 | 一般 |
| **自定义性** | 中等 | 极高 | 极高 |
| **Wayland 支持** | 原生 | 优秀 | 原生 |
| **输入法** | ibus | fcitx5 | fcitx5 |
| **浏览器** | Epiphany | Falkon | Falkon |
| **适合设备** | 平板/触屏 | 笔记本/掌机 | 极客/高级用户 |

## 🔧 技术栈

- **基础系统**：Arch Linux (rolling)
- **包管理器**：pacman
- **bootc**：Red Hat container-native OS
- **存储后端**：composefs (zero-copy)
- **容器格式**：OCI Image
- **显示协议**：Wayland (默认)
- **音频系统**：PipeWire
- **容器运行时**：Podman

## 📝 注意事项

1. **macOS 构建限制**：
   - ❌ 无法生成可启动镜像（需要 Linux）
   - ❌ 无法运行 QEMU 测试
   - ✅ 可以构建容器镜像
   - ✅ 可以推送到 Registry

2. **配置文件**：
   - ✅ 已从 ChimeraOS 迁移 rootfs（53个文件）
   - ✅ 包含：网络、蓝牙、输入法、Steam、Waydroid 等配置
   - 路径：`rootfs/etc/`, `rootfs/usr/`

## ✅ 已完成的 frzr 迁移

### 核心架构
- [x] **自定义 pacman 仓库**：skorion 仓库配置（最高优先级）
- [x] **自定义内核安装**：linux-skchos 6.17.7-1 + headers
- [x] **PACKAGE_OVERRIDES**：6个固定版本包（libxkbcommon, ibus-pinyin）
- [x] **rootfs 配置迁移**：53个配置文件从 chimeraos 迁移
- [x] **postinstallhook 系统调整**：
  - sudoers 配置
  - vim 默认编辑器
  - ALSA 配置
  - Steam desktop 文件修改（条件）
  - Waydroid 服务启用（条件）
  - Onboard uinput 规则（条件）
  - scx-scheds 服务启用（条件）
  - 构建工具删除（gcc, make, etc.）
- [x] **GNOME 特定调整**：mutter x11 fractional scaling

### AUR/Local 包管理
- [x] **skorion-packages 仓库**：独立仓库 + CI/CD
- [x] **66个 AUR 包**：完整同步 frzr 的 aur-pkgs/
- [x] **10个本地包**：从 chimeraos/pkgs 迁移
- [x] **增量构建**：检测版本变化，只构建更新的包
- [x] **版本控制**：aur-pinned.txt 支持固定特定 commit
- [x] **自动发布**：GitHub Release 作为 pacman 仓库

## ⚠️ 待完成的 frzr 迁移

### 🔴 高优先级（影响基本功能）

#### 1. SERVICES 系统服务启用（关键）
当前缺失 manifest 中的以下服务：
```bash
# 需要检查 frzr manifest SERVICES 列表
# 对比 Containerfile.base Layer 30-31 已启用的服务
# 补充缺失的关键服务
```
**位置**：`Containerfile.base` Layer 31

#### 2. USER_SERVICES 用户服务启用（关键）
当前缺失用户级服务启用：
```bash
# 需要检查 frzr manifest USER_SERVICES
# 使用 systemctl --user enable 或 systemctl --global enable
```
**位置**：`Containerfile.base` Layer 32 附近

### 🟡 中优先级（功能完整性）

#### 3. FILES_TO_DELETE 文件清理
```bash
# manifest FILES_TO_DELETE：
# - /usr/share/doc/* (文档)
# - /usr/share/man/* (手册)
# - /usr/lib/modules/*/build (dkms build files)
# - 其他不必要文件
```
**作用**：节省 500MB+ 空间  
**位置**：`Containerfile.base` Layer 37 清理阶段

#### 4. PACKAGES_TO_DELETE 包删除
```bash
# manifest PACKAGES_TO_DELETE：
# 删除与我们选择的包冲突的默认依赖
# 例如：pulseaudio（我们用 pipewire）
```
**作用**：避免包冲突  
**位置**：`Containerfile.base` Layer 36 调整阶段

#### 5. predownload.sh 资源预下载
**包含内容**：
- Decky Loader + 插件
- Steam 主题（Vapor, VGUI2）
- Oh-My-Zsh + 插件
- Rime 输入法词库
- 各种配置工具

**方案选择**：
- ❓ 方案A：在 Containerfile 中直接下载到 `/usr/local/share/sk-pre/`
- ❓ 方案B：构建 sk-pre.tar.gz 然后 COPY 进镜像
- ❓ 方案C：启动时首次运行脚本下载

**位置**：待定（需要讨论）

### 🟢 低优先级（优化体验）

#### 6. BUILD_SUMMARY.md 持续更新
保持本文档与实际状态同步

## 🎯 下一步行动

**建议顺序**：
1. 检查并补全 **SERVICES** 和 **USER_SERVICES**（30分钟）
2. 添加 **FILES_TO_DELETE** 清理逻辑（15分钟）
3. 添加 **PACKAGES_TO_DELETE** 删除逻辑（10分钟）
4. 讨论并实施 **predownload.sh** 方案（1-2小时）
5. 测试完整镜像构建
6. 设置 CI/CD 自动构建

## 📚 相关文档

- [README.md](README.md) - 项目总览
- [Containerfile.base](Containerfile.base) - Base 系统镜像定义
- [Containerfile.kde](Containerfile.kde) - KDE Plasma 变体
- [Containerfile.gnome](Containerfile.gnome) - GNOME 变体
- [Containerfile.hyprland](Containerfile.hyprland) - Hyprland 变体
- [Justfile](Justfile) - 构建脚本（Linux/Podman）
- [Justfile.macos](Justfile.macos) - macOS 构建脚本（Docker）
- [skorion-packages](https://github.com/SkorionOS/skorion-packages) - AUR/Local 包仓库

---

**最后更新**: 2025-11-05  
**当前阶段**: frzr 配置迁移中（70%完成）  
**下一里程碑**: 补全系统服务 + predownload 资源


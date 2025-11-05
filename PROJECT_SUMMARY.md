# SkorionOS Bootc - Project Summary

## 项目概述

这是 SkorionOS（原 ChimeraOS）基于 bootc + composefs 技术的实验性重构项目。目标是利用容器原生技术实现更快的更新速度和更好的系统管理。

## 创建日期

2025-11-05

## 项目状态

🚧 **实验阶段** - 基础架构已完成，等待测试验证

## 技术栈

- **Base OS**: Arch Linux
- **Container Runtime**: Podman
- **OS Management**: bootc
- **Filesystem**: composefs
- **Build Tool**: Just
- **Desktop**: KDE Plasma / GNOME / Hyprland

## 项目结构

```
skorion-bootc/
├── README.md                   # 完整项目文档
├── QUICK_START.md             # 快速开始指南
├── ARCHITECTURE.md            # 架构设计文档
├── ROADMAP.md                 # 开发路线图（32周计划）
├── TODO.md                    # 任务清单
├── LICENSE                    # GPLv3 许可证
│
├── Justfile                   # 构建自动化（15+ recipes）
├── Containerfile.base         # 基础系统定义
├── Containerfile.kde          # KDE 变体
├── Containerfile.gnome        # GNOME 变体
│
├── config/                    # 系统配置
│   ├── sddm/                 # SDDM 显示管理器配置
│   ├── gnome/                # GNOME 默认配置
│   ├── plasma/               # KDE Plasma 配置
│   └── systemd/              # Systemd 服务
│
├── rootfs/                    # 根文件系统覆盖层
│   ├── etc/                  # 系统配置文件
│   └── usr/local/bin/        # 系统脚本
│       └── skorionos-first-boot
│
├── scripts/                   # 构建和工具脚本
│   ├── build-packages.sh     # 构建 AUR 包
│   ├── generate-image.sh     # 生成可引导镜像
│   └── postinstall.sh        # 安装后配置
│
├── packages/                  # 包管理
│   ├── aur/                  # AUR PKGBUILD
│   ├── local/                # 本地包定义
│   └── built/                # 编译完成的包
│
└── output/                    # 构建输出
    └── *.img                 # 生成的磁盘镜像
```

## 核心文件说明

### 1. Containerfile.base
- 定义基础系统
- 包含 Arch Linux + Mesa + PipeWire + 核心工具
- ~2-3 GB 基础层

### 2. Justfile
- 构建自动化脚本
- 提供 15+ 个构建和测试命令
- 类似 Makefile 但更现代

### 3. Scripts
- `build-packages.sh`: 自动构建 AUR 和本地包
- `generate-image.sh`: 使用 bootc-image-builder 生成可引导镜像
- `postinstall.sh`: 容器内运行的配置脚本

### 4. Config
- SDDM 自动登录配置
- GNOME dconf 默认设置
- Systemd 服务定义

## 主要命令

```bash
# 构建
just build-base              # 构建基础系统
just build-kde              # 构建 KDE 变体
just build-all              # 构建所有变体

# 测试
just generate-image kde     # 生成可引导镜像
just run-vm                 # 在虚拟机中测试

# 工具
just shell kde              # 进入镜像调试
just info kde               # 查看镜像信息
just clean                  # 清理构建产物
```

## 与原版 ChimeraOS 的关系

### 继承的部分
- 包列表（从 manifest 和 base-pub）
- 系统配置理念
- 游戏优化设置
- 硬件支持逻辑

### 改变的部分
- **构建方式**: Containerfile 而非脚本 + manifest
- **分发方式**: OCI 容器注册表而非 tar.zst
- **更新机制**: bootc 而非 frzr
- **存储方式**: composefs 而非 btrfs 子卷

## 预期优势

| 特性 | frzr (当前) | bootc (新) | 改进 |
|------|------------|-----------|------|
| 更新速度 | 3-5 分钟 | ~50 秒 | **4-6x 更快** |
| 增量更新 | ❌ | ✅ | 只下载变化部分 |
| 标准化 | 自定义 | OCI 标准 | 更好的兼容性 |
| 生态系统 | 有限 | 容器生态 | 海量工具支持 |

## 技术创新点

1. **composefs 零拷贝挂载**
   - 不需要解压容器层
   - 直接将容器镜像作为根文件系统

2. **内容寻址存储**
   - 文件级去重
   - 多版本共享相同文件

3. **增量更新**
   - 只下载变化的容器层
   - 典型更新 500MB vs 3GB

## 下一步行动

### 立即（本周）
1. 测试 Containerfile.base 构建
2. 在虚拟机中验证基础系统
3. 修复发现的问题

### 短期（1-2周）
1. 完成 KDE 变体
2. 集成 gamescope
3. 测试 Steam 运行

### 中期（1-2月）
1. 移植硬件支持
2. 完善更新机制
3. 性能基准测试

### 长期（3-6月）
1. Alpha 测试
2. 社区反馈
3. Beta 发布

## 风险与挑战

### 技术风险
- ⚠️ composefs 可能还不够稳定
- ⚠️ bootc 还在快速发展中
- ⚠️ Arch Linux 上的 composefs 支持未验证

### 缓解策略
- ✅ 保持实验性质，不急于生产部署
- ✅ 充分测试后再推广
- ✅ 保留 frzr 作为备选方案

## 资源需求

### 开发环境
- 构建机器: 8GB+ RAM, 4+ cores
- 测试设备: 各类掌机硬件
- 存储: 100GB+ for builds and images

### 基础设施
- OCI 容器注册表 (GitHub Container Registry 或 Quay.io)
- CI/CD (GitHub Actions)
- 文档托管 (GitHub Pages)

## 贡献方式

1. 测试构建流程
2. 报告 Bug
3. 提交硬件兼容性信息
4. 改进文档
5. 优化 Containerfile

## 联系与反馈

- GitHub Issues: [报告问题]
- Discussions: [讨论功能]
- Discord/Matrix: [社区聊天] (待建立)

## 致谢

- ChimeraOS/SkorionOS 团队
- bootc 开发者
- composefs 开发者
- steamos-bootc 项目
- Arch Linux 社区

---

## 项目状态标记

```
[████░░░░░░] 40% - Foundation
[██░░░░░░░░] 20% - Gaming Integration
[░░░░░░░░░░]  0% - bootc Integration
[░░░░░░░░░░]  0% - Testing
[░░░░░░░░░░]  0% - Release
```

**整体进度: 12%** (基础架构已完成)

---

最后更新: 2025-11-05
作者: SkorionOS Team
许可证: GPLv3


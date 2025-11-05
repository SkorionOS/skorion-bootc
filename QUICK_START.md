# SkorionOS Bootc - Quick Start Guide

## 快速开始（5分钟上手）

### 1. 安装依赖

```bash
# Arch Linux
sudo pacman -S podman buildah skopeo just qemu-full

# 其他发行版
# Fedora: sudo dnf install podman buildah skopeo just qemu-system-x86
# Ubuntu: sudo apt install podman buildah skopeo just qemu-system-x86
```

### 2. 克隆项目

```bash
git clone https://github.com/SkorionOS/skorion-bootc.git
cd skorion-bootc
```

### 3. 构建镜像

```bash
# 构建基础系统
just build-base

# 构建 KDE 变体（推荐）
just build-kde

# 或构建其他变体
# just build-gnome
# just build-hyprland
```

### 4. 生成可引导镜像

```bash
# 生成 KDE 变体的磁盘镜像
just generate-image kde

# 镜像输出位置: output/skorionos-kde.img
```

### 5. 在虚拟机中测试

```bash
# 使用内置的 QEMU 启动脚本
just run-vm output/skorionos-kde.img

# 或手动启动
qemu-system-x86_64 \
    -enable-kvm \
    -m 8G \
    -cpu host \
    -smp 4 \
    -drive file=output/skorionos-kde.img,format=raw \
    -bios /usr/share/ovmf/x64/OVMF.fd
```

### 6. 登录信息

- **用户名**: `gamer`
- **密码**: `gamer`
- **默认**: 自动登录

## 常用命令

```bash
# 查看所有可用命令
just

# 构建所有变体
just build-all

# 清理构建产物
just clean

# 深度清理（包括容器缓存）
just clean-all

# 查看镜像信息
just info kde

# 进入镜像调试
just shell kde
```

## 构建你自己的变体

### 修改基础系统

编辑 `Containerfile.base` 添加/删除包：

```dockerfile
RUN pacman -S --noconfirm --needed \
    your-package-here \
    another-package \
    && pacman -Scc --noconfirm
```

### 创建自定义变体

复制现有的 Containerfile：

```bash
cp Containerfile.kde Containerfile.myvariant
```

修改内容，然后在 `Justfile` 中添加构建目标：

```makefile
# Build my variant
build-myvariant: build-base
    @echo "Building my variant..."
    podman build \
        -f Containerfile.myvariant \
        -t {{image_name}}:myvariant-{{image_tag}} \
        --layers \
        .
```

构建：

```bash
just build-myvariant
```

## 添加 AUR 包

1. 在 `packages/aur/` 中添加 PKGBUILD：

```bash
mkdir packages/aur/your-package
cd packages/aur/your-package
# 从 AUR 复制 PKGBUILD
```

2. 构建包：

```bash
just build-packages
```

3. 在 Containerfile 中安装：

```dockerfile
# Copy pre-built AUR packages
COPY packages/built/*.pkg.tar.zst /tmp/
RUN sudo pacman -U --noconfirm /tmp/your-package-*.pkg.tar.zst
```

## 调试技巧

### 查看构建日志

```bash
podman build -f Containerfile.base -t test --progress=plain . 2>&1 | tee build.log
```

### 进入运行中的容器

```bash
podman run -it --rm skorionos:base-latest /bin/bash
```

### 检查镜像层

```bash
podman inspect skorionos:kde-latest | jq '.[0].RootFS'
```

### 导出镜像用于调试

```bash
just export kde
tar -xf output/export/kde.tar
```

## 性能对比测试

### 测试更新速度

```bash
# 在运行的系统中
time sudo bootc update
```

### 测试启动时间

```bash
systemd-analyze
systemd-analyze blame
```

## 故障排除

### 构建失败

```bash
# 清理并重试
podman system prune -a -f
just build-base
```

### 镜像生成失败

```bash
# 检查 bootc-image-builder 日志
journalctl -xe

# 使用容器化的 builder
# (已在 generate-image.sh 中实现)
```

### 启动失败

1. 检查 UEFI 设置
2. 禁用 Secure Boot
3. 确保使用 OVMF 固件

### 包冲突

```bash
# 在 Containerfile 中添加
RUN pacman -Rdd --noconfirm conflicting-package
```

## 下一步

- 阅读完整的 [README.md](README.md)
- 查看 [steamos-bootc](https://github.com/bootcrew/steamos-bootc) 参考实现
- 研究 [bootc 文档](https://github.com/containers/bootc)
- 加入社区讨论

## 贡献

欢迎提交 Issue 和 Pull Request！

1. Fork 项目
2. 创建特性分支 (`git checkout -b feature/amazing-feature`)
3. 提交更改 (`git commit -m 'Add amazing feature'`)
4. 推送到分支 (`git push origin feature/amazing-feature`)
5. 开启 Pull Request

---

Have fun! 🎮🚀


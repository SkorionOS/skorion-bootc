#!/bin/bash
# Post-installation script for SkorionOS Bootc
# This script runs inside the container during build

set -e

echo "==> Running SkorionOS post-installation tasks..."

# Configure sudo
echo "==> Configuring sudo..."
sed -i "s/Defaults secure_path=/# Defaults secure_path=/g" /etc/sudoers

# Configure vim
echo "==> Configuring vim..."
if [ -f /usr/share/vim/vim*/defaults.vim ]; then
    sed -i 's/set mouse=a/set mouse-=a/g' /usr/share/vim/vim*/defaults.vim
fi
ln -sf /usr/bin/vim /usr/bin/vi

# Disable SPDIF/IEC958 audio output
echo "==> Configuring audio..."
if [ -f /usr/share/alsa-card-profile/mixer/profile-sets/default.conf ]; then
    sed -e '/\[Mapping iec958/,+5 s/^/#/' -i /usr/share/alsa-card-profile/mixer/profile-sets/default.conf
fi

# Configure Steam desktop shortcut
echo "==> Configuring Steam shortcuts..."
if [ -f /usr/share/applications/steam.desktop ]; then
    sed -i -e 's/Name=Steam (Runtime)/Name=Steam/' /usr/share/applications/steam.desktop
    # Uncomment if using skorion-steam wrapper
    # sed -i 's,Exec=/usr/bin/steam-runtime,Exec=/usr/bin/skorion-steam,' /usr/share/applications/steam.desktop
    # sed -i 's,Exec=/usr/bin/steam,Exec=/usr/bin/skorion-steam,' /usr/share/applications/steam.desktop
fi

# Create necessary directories
echo "==> Creating directory structure..."
mkdir -p /var/lib/flatpak
mkdir -p /etc/systemd/system
mkdir -p /etc/skel/.config

# Configure flatpak
echo "==> Configuring Flatpak..."
if command -v flatpak &> /dev/null; then
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true
fi

# Set up user configuration
echo "==> Setting up user configuration..."
# This will be copied to new users' home directories
cp -r /etc/skel /tmp/skel.bak 2>/dev/null || true

# Configure power management
echo "==> Configuring power management..."
mkdir -p /etc/systemd/logind.conf.d
cat > /etc/systemd/logind.conf.d/skorionos.conf <<EOF
[Login]
HandlePowerKey=suspend
HandleLidSwitch=suspend
HandleLidSwitchExternalPower=ignore
IdleAction=ignore
EOF

# Configure journal
echo "==> Configuring systemd journal..."
mkdir -p /etc/systemd/journald.conf.d
cat > /etc/systemd/journald.conf.d/skorionos.conf <<EOF
[Journal]
SystemMaxUse=100M
RuntimeMaxUse=50M
EOF

# Create fstab template
echo "==> Creating fstab template..."
cat > /etc/fstab <<EOF
# SkorionOS fstab
# Device mounts will be configured during first boot
tmpfs /tmp tmpfs defaults,noatime,mode=1777 0 0
EOF

echo "==> Post-installation complete!"


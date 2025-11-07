#!/bin/bash
# Build functions for SkorionOS Bootc
# Used by Containerfile to modularize complex operations

set -e

# ==============================================================================
# Build optimization: Disable dracut hooks during package installation
# ==============================================================================
disable_dracut() {
    # Backup dracut hooks to prevent automatic initramfs regeneration
    mkdir -p /tmp/dracut-hooks-backup
    mv /usr/share/libalpm/hooks/*dracut*.hook /tmp/dracut-hooks-backup/ 2>/dev/null || true
    echo "=========================================="
    echo "dracut hooks disabled for build efficiency"
    echo "initramfs will be generated once at the end"
    echo "=========================================="
}

# ==============================================================================
# Build optimization: Restore dracut hooks and generate initramfs once
# ==============================================================================
restore_and_run_dracut() {
    # Restore dracut hooks
    if [ -d /tmp/dracut-hooks-backup ]; then
        mv /tmp/dracut-hooks-backup/*.hook /usr/share/libalpm/hooks/ 2>/dev/null || true
        rm -rf /tmp/dracut-hooks-backup
    fi
    
    # Generate initramfs once with all modules
    echo "=========================================="
    echo "Running dracut ONCE to generate initramfs"
    echo "=========================================="
    KVER=$(ls /usr/lib/modules | grep -v '\.img$' | head -1)
    dracut --force --no-hostonly --reproducible --zstd --verbose \
           --kver "$KVER" "/usr/lib/modules/$KVER/initramfs.img"
    
    echo "initramfs generated: /usr/lib/modules/$KVER/initramfs.img"
}


remove_conflicting_packages() {
    source /tmp/manifest
    for package in ${PACKAGES_TO_DELETE}; do
        echo "Checking if $package is installed"
	    if [[ $(pacman -Qq $package) == "$package" ]]; then
		    echo "$package is installed, deleting"
		    pacman --noconfirm -Rnsdd $package || true
		fi
    done
}

# ==============================================================================
# Create user and configure sudo
# ==============================================================================
setup_user() {
    source /tmp/manifest
    
    groupadd -r autologin || true
    useradd -m -u ${USER_UID} -G autologin,wheel,i2c,input ${USERNAME}
    echo "${USERNAME}:${USERNAME}" | chpasswd
    echo "%wheel ALL=(ALL:ALL) ALL" >> /etc/sudoers
    echo "Defaults !secure_path" >> /etc/sudoers
}

# ==============================================================================
# Setup SDDM autologin for gamescope session
# ==============================================================================
setup_sddm() {
    source /tmp/manifest
    
    mkdir -p /etc/sddm.conf.d
    cat > /etc/sddm.conf.d/10-skorionos-session.conf << EOF
[Autologin]
Session=gamescope-session-steam
User=${USERNAME}
Relogin=true

[General]
DisplayServer=wayland
HideUsers=true
EOF
}

# ==============================================================================
# Setup system locale, timezone, hostname
# ==============================================================================
setup_system_basics() {
    source /tmp/manifest
    
    # Set locale
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
    locale-gen
    echo "LANG=en_US.UTF-8" > /etc/locale.conf
    
    # Set timezone
    ln -sf /usr/share/zoneinfo/UTC /etc/localtime
    
    # Configure hostname
    echo "${SYSTEM_NAME}" > /etc/hostname
    
    # Enable multicast DNS
    sed -i "/^hosts:/ s/resolve/mdns resolve/" /etc/nsswitch.conf
}

# ==============================================================================
# Setup SSH configuration
# ==============================================================================
setup_ssh() {
    cat > /etc/ssh/sshd_config << 'EOF'
AuthorizedKeysFile	.ssh/authorized_keys
PasswordAuthentication yes
ChallengeResponseAuthentication no
UsePAM yes
PrintMotd no # pam does that
Subsystem	sftp	/usr/lib/ssh/sftp-server
EOF
}

# ==============================================================================
# Setup podman and shell defaults
# ==============================================================================
setup_user_environment() {
    source /tmp/manifest
    
    # Podman configuration
    echo "unqualified-search-registries = ['docker.io']" >> /etc/containers/registries.conf
    
    # Set default editor
    echo "export EDITOR=/usr/bin/vim" >> /etc/bash.bashrc
    
    # Set default shell
    chsh -s /usr/bin/zsh ${USERNAME}
}

# ==============================================================================
# Generate /etc/lsb-release and /etc/os-release
# ==============================================================================
setup_release_info() {
    source /tmp/manifest
    
    # /etc/lsb-release
    cat > /etc/lsb-release << EOF
LSB_VERSION=1.4
DISTRIB_ID=${SYSTEM_NAME}
DISTRIB_RELEASE="${VERSION}"
DISTRIB_DESCRIPTION=${SYSTEM_DESC}
EOF
    
    # /etc/os-release
    cat > /etc/os-release << EOF
NAME="${SYSTEM_DESC}"
VERSION_CODENAME=skorionos
VERSION="${VERSION}"
VERSION_ID="${VERSION}"
VARIANT_ID=skorionos
PRETTY_NAME="${SYSTEM_DESC} ${VERSION}"
ID="${SYSTEM_NAME}"
ID_LIKE=arch
ANSI_COLOR="1;31"
HOME_URL="${WEBSITE}"
DOCUMENTATION_URL="${DOCUMENTATION_URL}"
BUG_REPORT_URL="${BUG_REPORT_URL}"
EOF
}

# ==============================================================================
# Apply system tweaks and delete conflicting packages
# ==============================================================================
apply_system_tweaks() {
    source /tmp/manifest
    
    # Remove conflicting packages first
    pacman --noconfirm -Rnsdd $PACKAGES_TO_DELETE || true
    
    # Execute frzr postinstallhook
    postinstallhook
}

# ==============================================================================
# Final cleanup
# ==============================================================================
cleanup_system() {
    source /tmp/manifest
    
    # Clean pacman cache
    pacman -Scc --noconfirm
    rm -rf /var/cache/pacman/pkg/*
    
    # Remove unnecessary files
    for file in $FILES_TO_DELETE; do
        rm -rf "$file"
    done
    
    # Clean temp directories
    rm -rf /tmp/*
    rm -rf /var/tmp/*
}


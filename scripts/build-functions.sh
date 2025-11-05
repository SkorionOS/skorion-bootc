#!/bin/bash
# Build functions for SkorionOS Bootc
# Used by Containerfile to modularize complex operations

set -e

# ==============================================================================
# Build optimization: Disable mkinitcpio using pacman hook
# ==============================================================================
disable_mkinitcpio() {
    # Create helper script for the hook
    mkdir -p /usr/local/bin
    cat > /usr/local/bin/replace-mkinitcpio-with-dummy.sh << 'EOFREPLACEMENT'
#!/bin/bash
# Backup real mkinitcpio if not already backed up
if [ -f /usr/bin/mkinitcpio ] && [ ! -f /usr/bin/mkinitcpio.real ]; then
    cp /usr/bin/mkinitcpio /usr/bin/mkinitcpio.real
fi

# Replace with dummy
cat > /usr/bin/mkinitcpio << 'EOFDUMMY'
#!/bin/bash
echo "=========================================="
echo "mkinitcpio: SKIPPED during build"
echo "Will run once at Layer 37"
echo "=========================================="
exit 0
EOFDUMMY
chmod +x /usr/bin/mkinitcpio
echo "mkinitcpio replaced with dummy"
EOFREPLACEMENT
    chmod +x /usr/local/bin/replace-mkinitcpio-with-dummy.sh
    
    # Create pacman hook that triggers when mkinitcpio is installed/upgraded
    mkdir -p /usr/share/libalpm/hooks
    cat > /usr/share/libalpm/hooks/00-disable-mkinitcpio.hook << 'EOFHOOK'
[Trigger]
Type = File
Operation = Install
Operation = Upgrade
Target = usr/bin/mkinitcpio

[Action]
Description = Replacing mkinitcpio with dummy for build efficiency
When = PostTransaction
Exec = /usr/local/bin/replace-mkinitcpio-with-dummy.sh
EOFHOOK
    
    # Backup and remove existing mkinitcpio hooks
    # (in case mkinitcpio is already installed from base image)
    mkdir -p /tmp/mkinitcpio-hooks-backup
    find /usr/share/libalpm/hooks -name "*mkinitcpio*.hook" ! -name "00-disable-mkinitcpio.hook" \
        -exec mv {} /tmp/mkinitcpio-hooks-backup/ \; 2>/dev/null || true
    
    echo "mkinitcpio auto-replacement hook installed (will activate when mkinitcpio is installed)"
}

# ==============================================================================
# Build optimization: Restore and run mkinitcpio once at the end
# ==============================================================================
restore_and_run_mkinitcpio() {
    # Remove our hook and helper script
    rm -f /usr/share/libalpm/hooks/00-disable-mkinitcpio.hook
    rm -f /usr/local/bin/replace-mkinitcpio-with-dummy.sh
    
    # Restore original mkinitcpio
    if [ -f /usr/bin/mkinitcpio.real ]; then
        mv /usr/bin/mkinitcpio.real /usr/bin/mkinitcpio
    else
        # If no backup, reinstall the package to get original
        pacman -S --noconfirm mkinitcpio
    fi
    
    # Restore original hooks
    if [ -d /tmp/mkinitcpio-hooks-backup ]; then
        find /tmp/mkinitcpio-hooks-backup -name "*.hook" -exec mv {} /usr/share/libalpm/hooks/ \; 2>/dev/null || true
        rm -rf /tmp/mkinitcpio-hooks-backup
    fi
    
    # Generate initramfs once with all modules
    echo "=========================================="
    echo "Running mkinitcpio ONCE to generate initramfs"
    echo "=========================================="
    mkinitcpio -P
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
# Layer 30: Create user and configure sudo
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
# Layer 34: Setup SDDM autologin for gamescope session
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
# Layer 35: Setup system locale, timezone, hostname
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
# Layer 35: Setup SSH configuration
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
# Layer 35: Setup podman and shell defaults
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
# Layer 35: Generate /etc/lsb-release and /etc/os-release
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
# Layer 36: Apply system tweaks and delete conflicting packages
# ==============================================================================
apply_system_tweaks() {
    source /tmp/manifest
    
    # Remove conflicting packages first
    pacman --noconfirm -Rnsdd $PACKAGES_TO_DELETE || true
    
    # Execute frzr postinstallhook
    postinstallhook
}

# ==============================================================================
# Layer 37: Final cleanup
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


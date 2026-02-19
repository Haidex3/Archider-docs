#!/usr/bin/env bash
set -e

echo "========================================"
echo "      Automatically Detecting Hardware"
echo "========================================"

IS_LAPTOP=false
HAS_NVIDIA=false

# =========================================
# Detect laptop (battery presence)
# =========================================
if [ -d /sys/class/power_supply/BAT0 ]; then
    IS_LAPTOP=true
fi

# =========================================
# Detect NVIDIA GPU
# =========================================
if lspci | grep -qi nvidia; then
    HAS_NVIDIA=true
fi

# =========================================
# Laptop configuration
# =========================================
if [[ "$IS_LAPTOP" == "true" ]]; then
    echo "Laptop detected"

    pacman -S --noconfirm --needed \
        brightnessctl \
        tlp \
        acpi \
        acpid \
        upower \
        power-profiles-daemon

    systemctl enable tlp
    systemctl enable acpid
    systemctl enable power-profiles-daemon

    # Suspend when laptop lid is closed
    sed -i 's/^#HandleLidSwitch=suspend/HandleLidSwitch=suspend/' /etc/systemd/logind.conf

else
    echo "Desktop system detected"

    pacman -S --noconfirm --needed ddcutil
fi

# =========================================
# NVIDIA configuration (if present)
# =========================================
if [[ "$HAS_NVIDIA" == "true" ]]; then
    echo "NVIDIA GPU detected"

    pacman -S --noconfirm --needed \
        nvidia \
        nvidia-utils \
        nvidia-settings

    # Enable DRM modesetting for Wayland (e.g., Hyprland)
    echo "options nvidia_drm modeset=1" > /etc/modprobe.d/nvidia.conf

else
    echo "No NVIDIA GPU detected"
fi

echo "========================================"
echo "     Hardware configuration complete"
echo "========================================"

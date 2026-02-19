#!/usr/bin/env bash
set -e

pacman -S --noconfirm grub efibootmgr os-prober

echo "GRUB_DISABLE_OS_PROBER=false" >> /etc/default/grub

# =========================================
# Detect EFI mount point dynamically
# =========================================

if mount | grep -q "on /boot/efi "; then
    EFI_DIR="/boot/efi"
elif mount | grep -q "on /boot "; then
    EFI_DIR="/boot"
else
    echo "Error: EFI partition is not mounted."
    echo "Please mount the EFI partition to /boot or /boot/efi before running this script."
    exit 1
fi

echo "Detected EFI mount point: $EFI_DIR"

# =========================================
# Install GRUB
# =========================================

grub-install --target=x86_64-efi --efi-directory="$EFI_DIR" --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

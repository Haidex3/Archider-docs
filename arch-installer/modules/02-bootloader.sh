#!/usr/bin/env bash
set -euo pipefail

echo "Installing GRUB and required packages..."
pacman -S --noconfirm grub efibootmgr os-prober

# =========================================
# Ensure os-prober is enabled (no duplicates)
# =========================================
if grep -q "^GRUB_DISABLE_OS_PROBER=" /etc/default/grub; then
    sed -i 's/^GRUB_DISABLE_OS_PROBER=.*/GRUB_DISABLE_OS_PROBER=false/' /etc/default/grub
else
    echo "GRUB_DISABLE_OS_PROBER=false" >> /etc/default/grub
fi

# =========================================
# Detect EFI partition by GPT type
# Official EFI PARTTYPE:
# c12a7328-f81f-11d2-ba4b-00a0c93ec93b
# =========================================

EFI_DIR=$(lsblk -o MOUNTPOINT,PARTTYPE | awk '/c12a7328-f81f-11d2-ba4b-00a0c93ec93b/ {print $1}')

if [ -z "${EFI_DIR:-}" ]; then
    echo "ERROR: EFI partition not mounted."
    echo "Make sure you mounted it before running arch-chroot."
    echo "Example:"
    echo "  mount /dev/nvme0n1p1 /mnt/efi"
    exit 1
fi

echo "Detected EFI mount point: $EFI_DIR"

# =========================================
# Install GRUB
# =========================================

grub-install \
    --target=x86_64-efi \
    --efi-directory="$EFI_DIR" \
    --bootloader-id=GRUB

grub-mkconfig -o /boot/grub/grub.cfg

echo "GRUB installation completed successfully."
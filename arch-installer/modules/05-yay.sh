#!/usr/bin/env bash
set -e

echo "----------------------------------------"
echo "Installing yay AUR helper"
echo "----------------------------------------"

# Directorio temporal de build
BUILD_DIR="/home/$USERNAME/build-yay"
mkdir -p "$BUILD_DIR"
chown "$USERNAME:$USERNAME" "$BUILD_DIR"

# Ejecutar build como el usuario normal
su - "$USERNAME" -c "
cd $BUILD_DIR &&
git clone https://aur.archlinux.org/yay.git &&
cd yay &&
makepkg -f --noconfirm
"

# Instalar el paquete generado como root
PACMAN_PKG=$(find "$BUILD_DIR/yay" -maxdepth 1 -type f -name "yay-*.pkg.tar.zst" | head -n1)

if [ -f "$PACMAN_PKG" ]; then
    echo "Installing $PACMAN_PKG..."
    pacman -U --noconfirm "$PACMAN_PKG"
else
    echo "Error: yay package not found!"
    exit 1
fi

echo "yay installed successfully"
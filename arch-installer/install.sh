#!/usr/bin/env bash
set -e

# ========================================
# Root check (must be executed inside arch-chroot as root)
# ========================================

if [ "$EUID" -ne 0 ]; then
  echo "This script must be executed as root inside arch-chroot."
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "========================================"
echo "           Arch Installer"
echo "========================================"

# ========================================
# USER INPUTS
# ========================================

read -p "Username: " USERNAME
read -s -p "Password (for root and user): " PASSWORD
echo
read -p "Hostname: " HOSTNAME
read -p "Timezone (e.g. America/Bogota): " TIMEZONE
read -p "Use la-latin1 keyboard layout? (y/n): " KEYBOARD_OPTION

DOTS_URL="https://github.com/Haidex3/Archider"

export USERNAME PASSWORD HOSTNAME TIMEZONE KEYBOARD_OPTION DOTS_URL SCRIPT_DIR

echo
echo "========================================"
echo "      Ensuring module permissions..."
echo "========================================"

# ========================================
# Ensure all module scripts are executable
# ========================================

find "$SCRIPT_DIR/modules" -type f -name "*.sh" -exec chmod +x {} \;

echo
echo "========================================"
echo "         Running modules..."
echo "========================================"

# ========================================
# EXECUTE INSTALLATION MODULES
# ========================================

bash "$SCRIPT_DIR/modules/01-system.sh"
bash "$SCRIPT_DIR/modules/02-bootloader.sh"
bash "$SCRIPT_DIR/modules/03-user.sh"
bash "$SCRIPT_DIR/modules/04-packages.sh"
bash "$SCRIPT_DIR/modules/05-yay.sh"
bash "$SCRIPT_DIR/modules/06-hardware.sh"
bash "$SCRIPT_DIR/modules/07-dots.sh"

echo
echo "========================================"
echo "        Installation completed"
echo "        You can now reboot"
echo "========================================"

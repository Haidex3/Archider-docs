#!/usr/bin/env bash
set -e

pacman -S --noconfirm --needed - < "$SCRIPT_DIR/config/packages.txt"
pacman -S --noconfirm --needed base-devel go
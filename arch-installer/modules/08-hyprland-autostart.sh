#!/usr/bin/env bash
set -e

echo "----------------------------------------"
echo "Configuring Hyprland auto-start (TTY1)"
echo "----------------------------------------"

USER_HOME="/home/$USERNAME"
BASH_PROFILE="$USER_HOME/.bash_profile"

# Crear archivo si no existe
if [ ! -f "$BASH_PROFILE" ]; then
    touch "$BASH_PROFILE"
fi

# Evitar duplicar configuración
if ! grep -q "exec Hyprland" "$BASH_PROFILE"; then
cat << 'EOF' >> "$BASH_PROFILE"

# Auto-start Hyprland on TTY1
if [[ -z $DISPLAY ]] && [[ $(tty) == /dev/tty1 ]]; then
  exec start-hyprland
fi

EOF
fi

# Asegurar que bashrc se cargue
if ! grep -q ".bashrc" "$BASH_PROFILE"; then
    echo '[[ -f ~/.bashrc ]] && . ~/.bashrc' >> "$BASH_PROFILE"
fi

# Permisos correctos
chown "$USERNAME:$USERNAME" "$BASH_PROFILE"

echo "Hyprland auto-start configured successfully."
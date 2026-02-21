# Archider

```
     _    ____   ____ _   _ ___ ____  _____ ____  
    / \  |  _ \ / ___| | | |_ _|  _ \| ____|  _ \ 
   / _ \ | |_) | |   | |_| || || | | |  _| | |_) |
  / ___ \|  _ <| |___|  _  || || |_| | |___|  _ < 
 /_/   \_\_| \_\\____|_| |_|___|____/|_____|_| \_\
```

**Author:** Haidex3
**Repository:** [https://github.com/Haidex3/Archider](https://github.com/Haidex3/Archider)

---

# Connecting to WiFi from the Arch Linux ISO

The Arch Linux live environment uses `iwd` as the wireless manager.
The control utility is `iwctl`.

---

## 1. Verify that the WiFi interface is detected

```bash
ip link
```

Identify the wireless interface (for example: `wlan0`, `wlp2s0`, etc.).

---

## 2. Start the interactive iwd environment

```bash
iwctl
```

---

## 3. List wireless devices

Inside `iwctl`:

```bash
device list
```

Note the exact device name.

---

## 4. Scan available networks

```bash
station INTERFACE_NAME scan
station INTERFACE_NAME get-networks
```

Replace `INTERFACE_NAME` with the real detected interface name.

---

## 5. Connect to a network

```bash
station INTERFACE_NAME connect NETWORK_NAME
```

If the network name contains spaces:

```bash
station INTERFACE_NAME connect "Network Name"
```

If the network name is omitted:

```bash
station INTERFACE_NAME connect
```

You can autocomplete with the `Tab` key.

---

## 6. Verify connectivity

Exit `iwctl`:

```bash
exit
```

Check connection:

```bash
ping archlinux.org
```

---

# Direct Method (Non-Interactive Mode)

```bash
iwctl --passphrase "PASSWORD" station INTERFACE_NAME connect "NETWORK_NAME"
```

---

# Installation Environment Preparation

## 1. Verify partitions

```bash
lsblk
```

Identify:

* Existing EFI partition
* Target partition for Arch Linux

---

## 2. Format the target partition

Example using `ext4`:

```bash
mkfs.ext4 /dev/PARTITION_NAME
```

Do not format the EFI partition if it is used by other operating systems.

---

## 3. Mount partitions

Mount root:

```bash
mount /dev/PARTITION_NAME /mnt
```

Mount EFI:

```bash
mkdir -p /mnt/boot
mount /dev/EFI_PARTITION /mnt/boot
```

---

## 4. Install the base system

```bash
pacstrap /mnt base linux linux-firmware
```

Recommended installation:

```bash
pacstrap /mnt base linux linux-firmware sudo nano networkmanager grub efibootmgr git
```

---

## 5. Generate fstab

```bash
genfstab -U /mnt >> /mnt/etc/fstab
```

Verify:

```bash
cat /mnt/etc/fstab
```

---

## 6. Enter the installed environment

```bash
arch-chroot /mnt
```

---

# Description

**Archider** is an automated Arch Linux installer designed to be executed **directly after `arch-chroot`**, featuring automatic hardware detection (laptop, NVIDIA GPU) and complete system, bootloader, and dotfiles configuration.

Objective:

```
USB → arch-chroot → ./install.sh → reboot → ready system
```

---

# Installation (Inside arch-chroot)

```bash
pacman -S git
git clone https://github.com/Haidex3/Archider-docs
cd Archider-docs
chmod +x install.sh
./install.sh
exit
reboot
```

The script handles:

* Regional and keyboard configuration
* User creation and sudo setup
* GRUB installation (UEFI)
* Automatic detection of:

  * Laptop (battery)
  * NVIDIA GPU
* Base package installation
* Dotfiles installation
* Power, brightness, and graphics driver configuration

---

# Automatic Hardware Detection

Archider **does not prompt** whether the system is a laptop or desktop.

---

## Laptop (Battery Detected)

Automatically installs:

* `brightnessctl`
* `tlp`
* `acpid`
* `upower`
* `power-profiles-daemon`

And enables the corresponding services.

---

## Desktop PC

Installs:

* `ddcutil` (brightness control via DDC/CI)

---

## NVIDIA GPU (If Detected)

Installs:

* `nvidia`
* `nvidia-utils`
* `nvidia-settings`

Also properly enables Wayland support (`nvidia_drm modeset=1`).

---

# Package Management

## Base Packages

Defined in:

```
config/packages.txt
```

This file should contain **only packages common to all systems**.

---

## Hardware-Specific Packages

Managed automatically in:

```
modules/07-hardware.sh
```

---

# Dotfiles Synchronization

Once the system is installed, you may manually sync your dotfiles:

```bash
./sync-dotfiles.sh
```

To pull changes from the remote repository:

```bash
./sync-dotfiles.sh --pull
```

---

# GTK Themes / Icons / Fonts

Theme configuration via `gsettings`:

```bash
gsettings set org.gnome.desktop.interface gtk-theme Default
gsettings set org.gnome.desktop.interface icon-theme Papirus-Dark
gsettings set org.gnome.desktop.interface font-name "Sans 10"
```

Assign proper permissions to local themes:

```bash
chown -R $USER:$USER ~/.local/share/themes
```

---

# Spicetify

```bash
spicetify backup
sudo chown -R $USER:$USER /opt/spotify
spicetify apply
```

---

# Additional Utilities

Manual installation (if required):

```bash
sudo pacman -S fftw
sudo pacman -S jq
sudo pacman -S ddcutil
sudo pacman -S qt5ct
```

Qt configuration:

```bash
export QT_QPA_PLATFORMTHEME=qt5ct
```

---

# Packaging Extensions (Example: Firefox)

```bash
zip -r ../dark-contrast-1.3.xpi .
```

---

# Recommended Services

```bash
sudo systemctl enable upower
sudo systemctl enable bluetooth
sudo systemctl enable power-profiles-daemon
```

---

# Shell Configuration

## `~/.bash_profile`

```bash
[[ -f ~/.bashrc ]] && . ~/.bashrc

if [[ -z $DISPLAY ]] && [[ $(tty) == /dev/tty1 ]]; then
  exec start-hyprland
fi

export PATH="$HOME/.local/bin:$PATH"
```

---

## `~/.bashrc`

```bash
# If not running interactively, do nothing
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias code='code --ozone-platform=wayland --enable-features=WaylandWindowDecorations'

PS1='[\u@\h \W]\$ '

runbg() {
    nohup "$@" >/dev/null 2>&1 &
    disown
}

eval "$(ssh-agent -s)" > /dev/null
```

---

# Final Result

After reboot, the system will have:

* Functional Arch Linux
* GRUB configured
* User account ready
* Network active
* Hyprland installed
* Correct drivers installed
* Dotfiles applied
* System automatically adapted to your hardware

---

# Firefox Configuration

For Firefox visual customizations (such as `userChrome.css` or `userContent.css`) to function properly, custom stylesheet support must be enabled.

---

## 1 Enable `userChrome.css` Support

1. Open Firefox.

2. In the address bar, type:

   ```
   about:config
   ```

3. Accept the security warning.

4. Search for the following preference:

   ```
   toolkit.legacyUserProfileCustomizations.stylesheets
   ```

5. Set its value to:

   ```
   true
   ```

This allows Firefox to load custom CSS files from the user profile.

---

## 2 Install the Custom Extension

Install the extension included in the repository:

```
firefox/extension
```

Available at:

[https://github.com/Haidex3/Archider/tree/main/firefox/extension](https://github.com/Haidex3/Archider/tree/main/firefox/extension)

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
Perfecto, estás en el **live ISO de Arch Linux** 👌 Te explico cómo conectarte a WiFi paso a paso.

Arch usa **`iwctl` (iwd)** para conectarse inalámbricamente.

---

## 1️ Verifica que tu tarjeta WiFi esté detectada

```bash
ip link
```

Deberías ver algo como `wlan0` o `wlp2s0`.

---

## 2️ Inicia iwctl

```bash
iwctl
```

Entrarás a un prompt interactivo que se ve así:

```
[iwd]#
```

---

## 3️ Ver dispositivos WiFi

Dentro de `iwctl`:

```bash
device list
```

Anota el nombre del dispositivo (ejemplo: `wlan0` o `wlp2s0`).

---

## 4️ Escanear redes

```bash
station wlan0 scan
```

(Luego)

```bash
station wlan0 get-networks
```

Cambia `wlan0` por el nombre real de tu interfaz.

---

## 5️ Conectarte a tu red

```bash
station wlan0 connect NOMBRE_DE_TU_WIFI
```

Si tiene contraseña, te la pedirá.

Si el nombre tiene espacios:

```bash
station wlan0 connect "Mi Wifi Casa"
```
sino funciona se puede escribir:


```bash
station wlan0 connect
```
y presionar tab
---

## 6️ Verificar conexión

Sal de iwctl:

```bash
exit
```

Y prueba:

```bash
ping archlinux.org
```

Si responde, ya estás conectado 🎉

---

# Método rápido (comando directo sin entrar al menú)

También puedes hacerlo en una sola línea:

```bash
iwctl --passphrase "TU_PASSWORD" station wlan0 connect "TU_WIFI"
```

---

## Descripción

**Archider** es un instalador automatizado para Arch Linux diseñado para ser ejecutado **directamente después de `arch-chroot`**, con detección automática de hardware (portátil, GPU NVIDIA) y configuración completa del sistema, bootloader y dotfiles.

Objetivo:

```
USB → arch-chroot → ./install.sh → reboot → sistema listo
```

---

Perfecto 🔥 entonces ya estás conectado a WiFi y tienes:

* Una partición **EFI** ya creada (la reutilizarás)
* `nvme0n1p4` como partición donde quieres instalar Arch

Vamos paso a paso.

---

# 1️ Verifica las particiones

Primero confirma todo:

```bash
lsblk
```

Deberías ver algo así:

```
nvme0n1
├─nvme0n1p1   (EFI)
├─nvme0n1p2
├─nvme0n1p3
└─nvme0n1p4   (DESTINO ARCH)
```

---

# 2️ Formatear SOLO la partición de instalación


Si usarás ext4:

```bash
mkfs.ext4 /dev/nvme0n1p4
```

NO formatees la EFI si ya la usas para otros sistemas.

---

# 3️ Montar particiones

### Monta la raíz:

```bash
mount /dev/nvme0n1p4 /mnt
```

### Monta la EFI (ejemplo si es p1):

```bash
mount /dev/nvme0n1p1 /mnt/boot
```

Si `/mnt/boot` no existe:

```bash
mkdir -p /mnt/boot
mount /dev/nvme0n1p1 /mnt/boot
```

---

# 4️Instalar sistema base

```bash
pacstrap /mnt base linux linux-firmware
```

Yo recomiendo agregar:

```bash
pacstrap /mnt base linux linux-firmware sudo nano networkmanager grub efibootmgr
```

---

# 📄 5️⃣ Generar fstab

```bash
genfstab -U /mnt >> /mnt/etc/fstab
```

Verifica:

```bash
cat /mnt/etc/fstab
```

---

# 6️ Entrar al sistema

```bash
arch-chroot /mnt
```


## Requisitos mínimos

Antes de ejecutar Archider necesitas **lo mínimo para clonar un repositorio Git**.

Desde la ISO de Arch Linux:

```bash
pacstrap /mnt base linux linux-firmware networkmanager grub git
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt
```

---

## Instalación (dentro de arch-chroot)

Una vez dentro del entorno `arch-chroot /mnt`:

```bash
pacman -S git
git clone https://github.com/Haidex3/Archider-docs
cd Archider-docs
chmod +x install.sh
./install.sh
exit
reboot
```

El script se encargará de:

* Configuración regional y de teclado
* Creación de usuario y sudo
* Instalación de GRUB (UEFI)
* Detección automática de:

  * Portátil (batería)
  * GPU NVIDIA
* Instalación de paquetes base
* Instalación de dotfiles
* Configuración de energía, brillo y drivers gráficos

---

## Detección automática de hardware

Archider **no pregunta** si el sistema es portátil o PC.

### Portátil (batería detectada)

Se instalan automáticamente:

* `brightnessctl`
* `tlp`
* `acpid`
* `upower`
* `power-profiles-daemon`

Y se habilitan los servicios correspondientes.

### PC

Se instala:

* `ddcutil` (control de brillo por DDC/CI)

### GPU NVIDIA (si se detecta)

Se instalan:

* `nvidia`
* `nvidia-utils`
* `nvidia-settings`

Además se habilita Wayland correctamente (`nvidia_drm modeset=1`).

---

## Gestión de paquetes

### Paquetes base

Se definen en:

```
config/packages.txt
```

Aquí van **solo los paquetes comunes a todos los sistemas**.

### Paquetes específicos por hardware

Se gestionan automáticamente en:

```
modules/07-hardware.sh
```

---

## Sincronización de dotfiles

Una vez instalado el sistema, puedes sincronizar manualmente tus dotfiles:

```bash
./sync-dotfiles.sh
```

Para traer cambios desde el repositorio remoto:

```bash
./sync-dotfiles.sh --pull
```

---

## Temas GTK / Iconos / Fuentes

Configuración de temas vía `gsettings`:

```bash
gsettings set org.gnome.desktop.interface gtk-theme Default
gsettings set org.gnome.desktop.interface icon-theme Papirus-Dark
gsettings set org.gnome.desktop.interface font-name "Sans 10"
```

Asignar permisos correctos a temas locales:

```bash
chown -R $USER:$USER ~/.local/share/themes
```

---

## Spicetify

```bash
spicetify backup
sudo chown -R $USER:$USER /opt/spotify
spicetify apply
```

---

## Utilidades adicionales

Instalación manual (si se requieren):

```bash
sudo pacman -S fftw
sudo pacman -S jq
sudo pacman -S ddcutil
sudo pacman -S qt5ct
```

Configuración de Qt:

```bash
export QT_QPA_PLATFORMTHEME=qt5ct
```

---

## Empaquetar extensiones (ej. Firefox)

```bash
zip -r ../dark-contrast-1.3.xpi .
```

---

## Servicios recomendados

```bash
sudo systemctl enable upower
sudo systemctl enable bluetooth
sudo systemctl enable power-profiles-daemon
```

---

## Configuración de shell

### `~/.bash_profile`

```bash
[[ -f ~/.bashrc ]] && . ~/.bashrc

if [[ -z $DISPLAY ]] && [[ $(tty) == /dev/tty1 ]]; then
  exec start-hyprland
fi

export PATH="$HOME/.local/bin:$PATH"
```

---

### `~/.bashrc`

```bash
# If not running interactively, don't do anything
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

## Resultado final

Después del reboot tendrás:

* Arch Linux funcional
* GRUB configurado
* Usuario listo
* Red activa
* Hyprland
* Drivers correctos
* Dotfiles aplicados
* Sistema adaptado automáticamente a tu hardware

---

## Nota final

Este proyecto está pensado para **uso personal avanzado**, pero su estructura es lo suficientemente limpia como para evolucionar a una herramienta pública.

> Archider no intenta ser Archinstall
> Archider es *tu* Arch

Si quieres, en el siguiente paso podemos:

* Añadir modo no interactivo
* Logging a `/var/log/archider.log`
* Flags tipo `--minimal`, `--full`
* Detección automática de CPU (microcode)

Esto ya es **portfolio-level serio**.


# Archider-docs

toolkit.legacyUserProfileCustomizations.stylesheets = true

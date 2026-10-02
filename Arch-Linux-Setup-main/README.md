# Arch Linux Setup

This document describes my personal **Arch Linux installation workflow**.  
I use the **archinstall script** with the *minimal* profile, starting from Wi-Fi setup and disk formatting.  
My main environment is **Hyprland** (JaKoolit’s rice), with **KDE Plasma** as a backup desktop environment.

Im going to install **Gentoo** later but for now, this is fine

---

## 🌐 Connect to Wi-Fi (Arch ISO)

First, connect to the internet:

```bash
iwctl
```

Inside `iwctl`:
```text
device list
station <device> scan
station <device> get-networks
station <device> connect <SSID>
exit
```

Verify with:
```bash
ping archlinux.org
```

---

## 💽 Drive Partitioning & Formatting

I usually create:

- **EFI partition** → `/mnt/boot` (e.g. 3 GB, FAT32)  
- **Root partition** → `/mnt` (e.g. 30 GB, ext4)  

Format them:

```bash
mkfs.fat -F32 /dev/sdX1     # EFI
mkfs.ext4 /dev/sdX2         # root
```

Mount them:

```bash
mount /dev/sdX2 /mnt
mkdir /mnt/boot
mount /dev/sdX1 /mnt/boot
```

---

## ⚙️ Run archinstall

Instead of letting `archinstall` partition, I use my **premounted config**:

```bash
/mnt
```

- Profile: `minimal`  
- Disk layout: already mounted (`/mnt` and `/mnt/boot`)  
- Configure locale, timezone, and users.  

After the script finishes, reboot into the new system.

---

## 📦 Packages

Once inside the installed system, I install my package set:

- **System & Utilities**  
  `base` `base-devel` `dosfstools` `efibootmgr` `grub` `mtools` `git` `wget` `flatpak` `yay`

- **Networking**  
  `openssh` `blueman`

- **System Monitoring**  
  `btop` `fastfetch` `power-profiles-daemon`

- **Development / Editors**  
  `nano` `vim` `neovim` `kate`

- **File Management**  
  `dolphin` `gparted` `gwenview`

- **Multimedia**  
  `vlc` `lmms`

- **Browsers & Communication**  
  `firefox` `discord`

- **Fun / Games**  
  `supertux` `supertuxkart`

- **Office**  
  `libreoffice-fresh`

- **Terminal**  
  `kitty`

---

## 🎨 Hyprland Setup (JaKoolit Rice)

After packages are installed:

```bash
git clone https://github.com/JaKooLit/Hyprland-Dots.git
cd Hyprland-Dots
./install.sh
```

This sets up:
- Hyprland WM  
- Preconfigured dotfiles  
- Theming and rice by JaKoolit  

Reload Hyprland configs with:

```bash
hyprctl reload
```

---

## 🖼️ Plasma (Backup Desktop)

I also install **KDE Plasma** as a fallback environment:

```bash
sudo pacman -S plasma-meta sddm
sudo systemctl enable sddm
```

---

## 🚀 Post-Install Notes

- Manage Flatpak apps via:
  ```bash
  flatpak install flathub <appname>
  ```

- Use Yay for AUR packages:
  ```bash
  yay -S <package>
  ```

- Plasma is available as a safety net if Hyprland fails to start.

#!/usr/bin/env bash

set -e

# --- Colors ---
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

USERNAME=""

# --- Helper Functions ---
info() { printf "\n${BLUE}:: %s${NC}\n" "$1"; }
success() { printf "${GREEN}✔ %s${NC}\n" "$1"; }
error() { printf "${RED}✖ %s${NC}\n" "$1"; }

# --- Script Functions ---

get_username() {
  USERNAME="${USERNAME:-$USER}"

  if [ -z "$USERNAME" ]; then
    error "Username cannot be determined"
    exit 1
  fi

  info "Script will be running for: $USERNAME"
}


bootstrap_system() {
    info "System update and doas installation..."
    sudo pacman -Syu --noconfirm --needed opendoas reflector
    sudo reflector --latest 5 --sort rate --save /etc/pacman.d/mirrorlist
    sudo pacman -Sy
    success "System updated, doas installed, mirrors selected."
}

# 2. Configure doas
configure_doas() {
    info "Configuring doas..."
    local doas_conf_line="permit persist ${USERNAME} as root"
    
    if ! sudo grep -qF "$doas_conf_line" /etc/doas.conf &>/dev/null; then
        echo "$doas_conf_line" | sudo tee /etc/doas.conf > /dev/null
       sudo chown -c root:root /etc/doas.conf
       sudo chmod -c 0400 /etc/doas.conf
        success "Rule for user $USERNAME added to /etc/doas.conf."
    else
        success "Doas rule already exists."
    fi
}

# 3. Install packages
install_pacman_packages() {
    info "Installing packages..."
    
    local packages=(
        alsa-tools alsa-utils bat cups dnsmasq dua-cli dust eza fd fzf
        gparted gvfs gvfs-gphoto2 gvfs-mtp gvfs-nfs htop libappindicator-gtk3
        libguestfs man-db cmus netstat-nat
        qt5-wayland ripgrep sof-firmware
        stow thunar xdg-desktop-portal-hyprland xorg-xhost
        zoxide egl-wayland hyprland
        swww ly neovim vim wget base-devel pipewire pipewire-pulse pipewire-alsa pipewire-jack wireplumber
        gst-plugin-pipewire zsh rofi alacritty ttf-jetbrains-mono-nerd cliphist clipman clipnotify wl-clipboard tumbler)

    doas pacman -S --noconfirm --needed "${packages[@]}"
    success "All packages from repositories are installed."
}

# Programs
install_useless_shit() {
  info "Installing something"
  
  local packages=(qemu-full openbsd-netcat tor torbrowser-launcher traceroute tree unrar unzip
        veracrypt virt-manager virt-viewer obs-studio)
}

# 4. Install AUR helper (paru)
install_paru() {
    info "Installing AUR helper (paru)..."
    if ! command -v paru &> /dev/null; then
        info "paru not found. Installing..."
        git clone https://aur.archlinux.org/paru-bin.git /tmp/paru-bin
        (cd /tmp/paru-bin && makepkg -si --noconfirm)
        rm -rf /tmp/paru-bin
        success "paru installed successfully."
    else
        info "paru is already installed."
    fi
}

# 5. Configure system files
configure_system_files() {
    info "Configuring system files..."

    if [ -f /etc/paru.conf ]; then
        if ! grep -q "Sudo = doas" /etc/paru.conf; then
            doas sed -i '/\[bin\]/a Sudo = doas' /etc/paru.conf
            success "Paru is configured to use doas."
        fi
    else
        printf "[bin]\nSudo = doas\n" | doas tee /etc/paru.conf > /dev/null
        success "Created /etc/paru.conf and configured to use doas."
    fi 
  }
nvidia(){  
  info "Configuring NVIDIA drivers..."
  
  doas pacman -S --needed nvidia-dkms nvidia-utils lib32-nvidia-utils  
  
  local nvidia_conf_content="options nvidia_drm modeset=1"
    echo "$nvidia_conf_content" | doas tee /etc/modprobe.d/nvidia.conf > /dev/null
    success "Created /etc/modprobe.d/nvidia.conf."

    info "Adding NVIDIA modules to mkinitcpio..."
    doas sed -i 's/^MODULES=.*/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf
    success "NVIDIA modules added to /etc/mkinitcpio.conf."
    
    info "Rebuilding initramfs (mkinitcpio)..."
    doas mkinitcpio -P
    success "Initramfs rebuilt successfully."
}

install_aur_packages() {
    info "Installing packages from AUR..."
    local packages=(
        "librewolf-bin"
        "waybar-git" 
        "localsend-bin"
        "nekoray-bin"
        "downgrade"
        "obfs4proxy"
    )

    paru -S --noconfirm --needed "${packages[@]}"
    success "All packages from AUR are installed."
}

enable_services() {
    info "Enabling system and user services..."

    info "Enabling PipeWire services..."
    systemctl --user enable pipewire.service
    systemctl --user enable pipewire-pulse.service
    systemctl --user enable wireplumber.service
    success "PipeWire services enabled for user $USERNAME."

    info "Enabling Ly Display Manager..."
    doas systemctl enable ly.service
    success "Ly Display Manager service enabled."
}

# 7. Change shell to Zsh
setup_zsh() {
    info "Setting Zsh as the default shell..."
    if [[ "$SHELL" != "/bin/zsh" ]]; then
        doas chsh -s "$(which zsh)" "$USERNAME"
        success "Default shell for $USERNAME changed to Zsh."
    else
        info "Zsh is already the default shell."
    fi
}

apply_dotfiles() {
    info "Applying configuration files (dotfiles) using stow..."
    cd "$(dirname "$0")"
    stow --target="$HOME" --restow .
    swww img $HOME/.dotfiles/.wallpapers/10.jpg
    success "Dotfiles applied successfully."
}

install_zshplugins() {

echo ">> Cloning zsh-plugins..."

ZSH_PLUGINS_DIR="${HOME}/.zsh_plugins"
mkdir -p "$ZSH_PLUGINS_DIR"

# Powerlevel10k
if [ ! -d "${ZSH_PLUGINS_DIR}/powerlevel10k" ]; then
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_PLUGINS_DIR}/powerlevel10k"
fi

# Oh-My-Zsh 
if [ ! -d "${ZSH_PLUGINS_DIR}/ohmyzsh" ]; then
  git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "${ZSH_PLUGINS_DIR}/ohmyzsh"
fi

# fast-syntax-highlighting
if [ ! -d "${ZSH_PLUGINS_DIR}/fast-syntax-highlighting" ]; then
  git clone --depth=1 https://github.com/zdharma-continuum/fast-syntax-highlighting.git "${ZSH_PLUGINS_DIR}/fast-syntax-highlighting"
fi

# zsh-autosuggestions
if [ ! -d "${ZSH_PLUGINS_DIR}/zsh-autosuggestions" ]; then
  git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git "${ZSH_PLUGINS_DIR}/zsh-autosuggestions"
fi

echo ">> Plugins installed."

}

main() {
    read -p "This script will install programs and configure the system. Continue? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi

    get_username
    bootstrap_system
    configure_doas
    
    install_pacman_packages
    
    read -rp "Install some shit? [y/Nigger]: " answer
    case "$answer" in 
      [yY])
        install_useless_shit
        ;;
      *)
        echo "Okay, let's commit war crimes in git commits"
        ;;
    esac
    
    configure_system_files
    read -rp "Install Nvidia drivers [y/N]: " answer
    case "$answer" in 
      [yY])
        nvidia
        ;;
      *)
        echo "Okay, fuck it."
        ;;
    esac
    # Install and use paru
    install_paru
    install_aur_packages
    
    # Final user configuration
    setup_zsh
    install_zshplugins
    apply_dotfiles
    enable_services
    echo
    success "Installation and configuration complete!"
    info "EXTREMELY IMPORTANT: reboot your computer to apply NVIDIA driver and other system changes."
}

main

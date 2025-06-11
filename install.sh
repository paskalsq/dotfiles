#!/usr/bin/env bash


set -e

BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

USERNAME=""

info() { printf "\n${BLUE}:: %s${NC}\n" "$1"; }
success() { printf "${GREEN}✔ %s${NC}\n" "$1"; }
error() { printf "${RED}✖ %s${NC}\n" "$1"; }

get_username() {
    read -p "Type in your username: " -r USERNAME
    if [ -z "$USERNAME" ]; then
        error "Username cannot be empty"
        exit 1
    fi
    info "Script will be running for: $USERNAME"
}

bootstrap_system() {
    info "System update and doas installation..."
    sudo reflector --latest 5 --sort rate --save /etc/pacman.d/mirrorlist
    sudo pacman -Syu --noconfirm --needed opendoas
    success "Система обновлена, doas установлен."
}

# 2. Настройка doas
configure_doas() {
    info "Настройка doas..."
    local doas_conf_line="permit persist ${USERNAME} as root"
    
    if ! sudo grep -qF "$doas_conf_line" /etc/doas.conf &>/dev/null; then
        echo "$doas_conf_line" | sudo tee /etc/doas.conf > /dev/null
       sudo chown -c root:root /etc/doas.conf
       sudo chmod -c 0400 /etc/doas.conf
        success "правило для пользователя $username добавлено в /etc/doas.conf."
    else
        success "Правило для doas уже существует."
    fi
}

# 3. Установка основных пакетов из официальных репозиториев
install_pacman_packages() {
    info "Установка пакетов из официальных репозиториев..."
    
    local packages=(
        alsa-tools alsa-utils bat cups dnsmasq downgrade dua-cli dust eza fd fzf
        gparted gvfs gvfs-gphoto2 gvfs-mtp gvfs-nfs htop libappindicator-gtk3
        libguestfs man-db mpc mpd ncmpcpp netstat-nat npm obfs4proxy obs-studio
        openbsd-netcat python-eyed3 qemu-full qt5-wayland reflector ripgrep sof-firmware
        steam stow thunar tor torbrowser-launcher traceroute tree unrar unzip
        veracrypt virt-manager virt-viewer xdg-desktop-portal-hyprland xorg-xhost
        zoxide nvidia-dkms nvidia-utils lib32-nvidia-utils egl-wayland hyprland
        swww ly neovim vim git wget base-devel pipewire pipewire-pulse pipewire-alsa pipewire-jack wireplumber
        gst-plugin-pipewire lib32-pipewire lib32-pipewire-jack)

    doas pacman -S --noconfirm --needed "${packages[@]}"
    success "Все пакеты из репозиториев установлены."
}

# 4. Установка AUR-хелпера (paru)
install_paru() {
    info "Установка AUR-хелпера (paru)..."
    if ! command -v paru &> /dev/null; then
        info "paru не найден. Установка..."
        git clone https://aur.archlinux.org/packages/paru /tmp/paru
        (cd /tmp/paru && makepkg -si --noconfirm)
        rm -rf /tmp/paru
        success "paru успешно установлен."
    else
        info "paru уже установлен."
    fi
}

# 5. Настройка системных файлов
configure_system_files() {
    info "Настройка системных файлов..."

    if [ -f /etc/paru.conf ]; then
        if ! grep -q "Sudo = doas" /etc/paru.conf; then
            doas sed -i '/\[bin\]/a Sudo = doas' /etc/paru.conf
            success "Paru настроен на использование doas."
        fi
    else
        printf "[bin]\nSudo = doas\n" | doas tee /etc/paru.conf > /dev/null
        success "Создан /etc/paru.conf и настроен на использование doas."
    fi

    info "Настройка драйверов NVIDIA..."
    local nvidia_conf_content="options nvidia_drm modeset=1"
    echo "$nvidia_conf_content" | doas tee /etc/modprobe.d/nvidia.conf > /dev/null
    success "Создан /etc/modprobe.d/nvidia.conf."

    info "Добавление модулей NVIDIA в mkinitcpio..."
    doas sed -i 's/^MODULES=.*/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf
    success "Модули NVIDIA добавлены в /etc/mkinitcpio.conf."
    
    info "Пересборка initramfs (mkinitcpio)..."
    doas mkinitcpio -P
    success "Initramfs успешно пересобран."
}

install_aur_packages() {
    info "Установка пакетов из AUR..."
    local packages=(
        "librewolf-bin"
        "waybar-git" 
        "localsend-bin"
        "nekoray-bin"
    )

    paru -S --noconfirm --needed "${packages[@]}"
    success "Все пакеты из AUR установлены."
}

enable_services() {
    info "Активация системных и пользовательских сервисов..."

    info "Активация сервисов PipeWire..."
    systemctl --user enable pipewire.service
    systemctl --user enable pipewire-pulse.service
    systemctl --user enable wireplumber.service
    success "Сервисы PipeWire активированы для пользователя $USERNAME."

    info "Активация Ly Display Manager..."
    doas systemctl enable ly.service
    success "Сервис Ly Display Manager активирован."
}



# 7. Смена оболочки на Zsh
setup_zsh() {
    info "Настройка Zsh как оболочки по умолчанию..."
    if [[ "$SHELL" != "/bin/zsh" ]]; then
        doas chsh -s "$(which zsh)" "$USERNAME"
        success "Оболочка по умолчанию для $USERNAME изменена на Zsh."
    else
        info "Zsh уже является оболочкой по умолчанию."
    fi
}

apply_dotfiles() {
    info "Применение конфигурационных файлов (dotfiles) с помощью stow..."
    cd "$(dirname "$0")"
    stow --target="$HOME" --restow */
    success "Dotfiles успешно применены."
}

main() {
    read -p "Этот скрипт установит программы и настроит систему. Продолжить? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi

    get_username
    bootstrap_system
    configure_doas
    
    install_pacman_packages
    configure_system_files     
    # Установка и использование paru
    install_paru
    install_aur_packages
    
    # Финальные пользовательские настройки
    setup_zsh
    apply_dotfiles
    enable_services
    echo
    success "🎉 Установка и настройка завершены!"
    info "КРАЙНЕ ВАЖНО: перезагрузи компьютер, чтобы применились драйверы NVIDIA и другие системные изменения."
}

main

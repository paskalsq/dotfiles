#!/bin/bash

# Проверка на root-права для установки пакетов
if [ "$EUID" -ne 0 ]; then
  echo "Установка пакетов требует прав root, запрашиваю sudo..."
fi

# Установка обязательных пакетов
echo "Установка обязательных пакетов..."

sudo pacman -Syu --noconfirm git zsh neovim hyprland alacritty dunst rofi waybar eza fzf swww which zsh-autosuggestions zsh-syntax-highlighting fastfetch


# Запрос на установку дополнительных пакетов
read -p "Введите дополнительные пакеты через пробел (или нажмите Enter, чтобы пропустить): " extra_packages

# Установка дополнительных пакетов, если они введены
if [ -n "$extra_packages" ]; then
  echo "Установка дополнительных пакетов: $extra_packages"
  sudo pacman -S --noconfirm $extra_packages
else
  echo "Дополнительные пакеты не указаны, пропускаем..."
fi

# Клонирование dotfiles из репозитория
echo "Клонирование dotfiles в домашнюю директорию..."
if [ -d "$HOME/dotfiles" ]; then
  echo "Папка dotfiles уже существует, обновляю..."
  cd "$HOME/dotfiles" && git pull
else
  git clone https://github.com/your_username/dotfiles.git "$HOME/dotfiles"
fi

# Создание необходимых директорий
echo "Создание необходимых директорий..."

mkdir -p $HOME/.config/nvim/
mkdir -p $HOME/.config/hypr/
mkdir -p $HOME/.config/alacritty/
mkdir -p $HOME/.config/dunst/
mkdir -p $HOME/.config/rofi/
mkdir -p $HOME/.config/waybar/
mkdir -p $HOME/.config/gtk-3.0/
mkdir -p $HOME/.config/gtk-4.0/

# Симлинк конфигурационных файлов
echo "Создание символических ссылок..."
ln -sf "$HOME/dotfiles/.zshrc" "$HOME/.zshrc"
ln -sf "$HOME/dotfiles/nvim" "$HOME/.config/nvim"
ln -sf "$HOME/dotfiles/hypr" "$HOME/.config/hypr"
ln -sf "$HOME/dotfiles/alacritty" "$HOME/.config/alacritty"
ln -sf "$HOME/dotfiles/dunst" "$HOME/.config/dunst"
ln -sf "$HOME/dotfiles/rofi" "$HOME/.config/rofi"
ln -sf "$HOME/dotfiles/waybar" "$HOME/.config/waybar"
ln -sf "$HOME/dotfiles/gtk-3.0" "$HOME/.config/gtk-3.0"
ln -sf "$HOME/dotfiles/gtk-4.0" "$HOME/.config/gtk-4.0"

mkdir -p $HOME/.config/

# Симлинк конфигурационных файлов
echo "Создание символических ссылок..."
ln -sf "$HOME/dotfiles/.zshrc" "$HOME/"
ln -sf "$HOME/dotfiles/nvim" "$HOME/.config"
ln -sf "$HOME/dotfiles/hypr" "$HOME/.config"
ln -sf "$HOME/dotfiles/alacritty" "$HOME/.config"
ln -sf "$HOME/dotfiles/dunst" "$HOME/.config"
ln -sf "$HOME/dotfiles/rofi" "$HOME/.config"
ln -sf "$HOME/dotfiles/waybar" "$HOME/.config"
ln -sf "$HOME/dotfiles/gtk-3.0" "$HOME/.config"
ln -sf "$HOME/dotfiles/gtk-4.0" "$HOME/.config"


# Установка Zsh в качестве основной оболочки
echo "Установка Zsh в качестве основной оболочки..."
chsh -s $(which zsh)

echo "Установка завершена! Перезайдите в систему или перезапустите терминал."

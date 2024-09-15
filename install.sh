#!/bin/bash

# Проверка на root-права
if [ "$EUID" -ne 0 ]; then
  echo "Пожалуйста, запустите скрипт с правами root"
  exit
fi

# Установка необходимых пакетов
echo "Установка необходимых пакетов..."
sudo pacman -Syu --noconfirm git zsh neovim hyprland alacritty dunst rofi waybar # Добавь сюда нужные тебе пакеты

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
echo "Клонирование dotfiles..."
if [ -d "$HOME/dotfiles" ]; then
  echo "Папка dotfiles уже существует, обновляю..."
  cd "$HOME/dotfiles" && git pull
else
  git clone https://github.com/paskalsq/dotfiles.git "$HOME/dotfiles"
fi

# Симлинк конфигурационных файлов
echo "Создание символических ссылок..."
ln -sf "$HOME/dotfiles/.zshrc" "$HOME/.zshrc"
ln -sf "$HOME/dotfiles/nvim" "$HOME/.config/nvim"
ln -sf "$HOME/dotfiles/hypr" "$HOME/.config/hypr"
ln -sf "$HOME/dotfiles/alacritty/" "$HOME/.config/alacritty"
ln -sf "$HOME/dotfiles/dunst" "$HOME/.config/dunst"
ln -sf "$HOME/dotfiles/rofi" "$HOME/.config/rofi"
ln -sf "$HOME/dotfiles/waybar" "$HOME/.config/waybar"
ln -sf "$HOME/dotfiles/gtk-3.0/" "$HOME/.config/gtk-3.0/"
ln -sf "$HOME/dotfiles/gtk-4.0/" "$HOME/.config/gtk-4.0/"

# Добавь сюда другие конфигурационные файлы

# Установка Zsh в качестве основной оболочки
echo "Установка Zsh в качестве основной оболочки..."
chsh -s $(which zsh)

echo "Установка завершена! Перезайдите в систему или перезапустите терминал."


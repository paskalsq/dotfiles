#!/bin/bash

# Проверка на root-права
if [ "$EUID" -ne 0 ]; then
  echo "Пожалуйста, запустите скрипт с правами root"
  exit
fi

# Установка необходимых пакетов
echo "Установка необходимых пакетов..."
sudo pacman -Syu --noconfirm git zsh neovim hyprland alacritty dunst rofi waybar # Добавь сюда нужные тебе пакеты

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
ln -sf "$HOME/dotfiles/.config/nvim" "$HOME/.config/nvim"
# Добавь сюда другие конфигурационные файлы

# Установка Zsh в качестве основной оболочки
echo "Установка Zsh в качестве основной оболочки..."
chsh -s $(which zsh)

echo "Установка завершена! Перезайдите в систему или перезапустите терминал."


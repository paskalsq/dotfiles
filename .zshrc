export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="xiong-chiamiov-plus"

plugins=(
    git
    archlinux
    zsh-autosuggestions
    zsh-syntax-highlighting
    web-search
    fast-syntax-highlighting
    zsh-autocomplete
    command-not-found
)

source $ZSH/oh-my-zsh.sh
export EDITOR=nvim
export XDG_CURRENT_DESKTOP=hyprland

# Set-up icons for files/folders in terminal
alias ls='eza -a --icons'
alias ll='eza -al --icons'
alias lt='eza -a --tree --level=1 --icons'

#Aliases
alias obs='QT_QPA_PLATFORM=wayland obs'
alias vi='$EDITOR'
alias shutdown='systemctl poweroff'
alias cleanup='~/.config/ml4w/scripts/cleanup.sh'
alias ascii='~/.config/ml4w/scripts/figlet.sh'
alias wallpapers='vim /home/paskalsq/dotfiles/.config/hypr/hyprpaper.conr'
alias cat='bat'
alias vps='ssh paskalsq@45.91.237.159'
alias windows='sudo bootctl set-oneshot auto-windows; sudo reboot'
# Set-up FZF key bindings (CTRL R for fuzzy history finder)
source <(fzf --zsh)

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory
fastfetch -c examples/15.jsonc

## [Completion]
## Completion scripts setup. Remove the following line to uninstall
[[ -f /home/paskalsq/.dart-cli-completion/zsh-config.zsh ]] && . /home/paskalsq/.dart-cli-completion/zsh-config.zsh || true
## [/Completion]



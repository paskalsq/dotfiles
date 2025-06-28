# ── Powerlevel10k Instant Prompt ──────────────────────────────
load_p10k_instant_prompt() {
  local cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}"
  local prompt_file="$cache_dir/p10k-instant-prompt-${(%):-%n}.zsh"

  [[ -r $prompt_file ]] && source "$prompt_file"
}
load_p10k_instant_prompt

ZSH_THEME="powerlevel10k/powerlevel10k"
source ~/.zsh_plugins/powerlevel10k/powerlevel10k.zsh-theme

# Path to plugin directory
ZSH_PLUGINS="$HOME/.zsh_plugins"

# Initialize completion system
autoload -Uz compinit && compinit

# Load Oh-My-Zsh plugins
# These plugins provide useful features: git integration, syntax highlighting, and autosuggestions.
source "$ZSH_PLUGINS/ohmyzsh/plugins/git/git.plugin.zsh"
source "$ZSH_PLUGINS/web-search/web-search.plugin.zsh"
source "$ZSH_PLUGINS/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"
source "$ZSH_PLUGINS/zsh-autosuggestions/zsh-autosuggestions.zsh"

# Language and encoding settings
export LANG=en_US.UTF-8

# Completion system settings
zstyle ':completion:*' list-colors ''          # Colorize file completions
zstyle ':completion:*' group-name ''           # Group completions by type
zstyle ':completion:*' format '%B%d%b'         # Format completion groups

# Command history settings
HISTFILE=$HOME/.zsh_history                    # File to store command history
SAVEHIST=1000                                  # Number of commands to save
setopt HIST_IGNORE_SPACE                       # Ignore commands starting with a space
setopt HIST_IGNORE_DUPS                        # Ignore duplicates of the previous command
setopt INC_APPEND_HISTORY                      # Save commands to history immediately

# Shell options
setopt AUTO_CD                                 # Change directory without 'cd' command
setopt NO_BEEP                                 # Disable beeping
setopt INTERACTIVE_COMMENTS                    # Allow comments in interactive shell
setopt NO_CLOBBER                              # Prevent overwriting files with redirection
setopt NO_MULTIOS                              # Disable multiple redirections
setopt NO_FLOW_CONTROL                         # Disable flow control (Ctrl+S, Ctrl+Q)


eval "$(zoxide init zsh)" # Zoxide Initialize


# Enable command correction
ENABLE_CORRECTION="true"

# Use Vi keybindings
# bindkey -v

# Aliases for convenience
alias gparted='pkexec env WAYLAND_DISPLAY="$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY" XDG_RUNTIME_DIR=/run/user/0 gparted'
alias ls='exa --icons --group-directories-first --color=always'     # Replace ls with exa with icons
alias ll='exa -l --icons --group-directories-first --color=always'  # Long listing
alias la='exa -la --icons --group-directories-first --color=always' # Include hidden files
alias lt='exa --tree --level=2 --icons --color=always'              # Tree view
# alias grep='rg'                                                     # Replace grep with ripgrep
alias f='fd'                                                        # Quick file search
alias du='dust'                                                     # Replace du with dust
alias df='dua'                                                      # Replace df with dua
alias cat='bat --style=plain'                                       # Replace cat with bat
alias bathelp='bat --paging=always --language=help'                 # View help with bat
# Custom functions
function h() {
  "$@" --help 2>&1 | bat --paging=always --language=help
}                                                             # bathelp (h cat)

# fzf + ctrl-R History
if [[ -n $commands[fzf] ]]; then
  source /usr/share/fzf/key-bindings.zsh
fi

omz_urlencode() {
  local length="${#1}"
  for (( i = 0; i < length; i++ )); do
    local c="${1:$i:1}"
    case $c in
      [a-zA-Z0-9.~_-]) printf '%s' "$c" ;;
      *) printf '%%%02X' "'$c" ;;
    esac
  done
}


open_command() {
  if command -v xdg-open >/dev/null; then
    xdg-open "$@"
  elif command -v open >/dev/null; then
    open "$@"
  else
    echo "Ошибка: не найдено ни xdg-open, ни open." >&2
    return 1
  fi
}

# Create a function to find a file with fzf and put it in the command buffer
fzf-edit-dotfile() {
  # Run find and fzf, storing the selected file in a variable
  local selected_file
  selected_file=$(command find ~/.dotfiles/.config/hypr ~/.dotfiles/.config/alacritty ~/.zshrc ~/.dotfiles/.config/waybar -type f | fzf)

  # If a file was selected (the variable is not empty)
  if [[ -n "$selected_file" ]]; then
    LBUFFER="nvim $selected_file"
    RBUFFER=""
  fi
}
# Create a ZLE widget from the function
zle -N fzf-edit-dotfile 


bindkey "^[[1;5C" forward-word      # Ctrl+→
bindkey "^[[1;5D" backward-word     # Ctrl+←
bindkey '^f' fzf-edit-dotfile

# Load Powerlevel10k configuration if it exists
# To customize the prompt, run `p10k configure` or edit ~/.p10k.zsh
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


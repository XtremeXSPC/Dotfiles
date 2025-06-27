# =========================================================================== #
# +++++++++++++++++++++++++++ BASE CONFIGURATION ++++++++++++++++++++++++++++ #
# =========================================================================== #

# =============== Startup Commands =============== #
# fastfetch

# =============== Helper Functions ============== #
# Function to check for duplicates in the PATH
check_path_dupes() {
  echo $PATH | tr ':' '\n' | sort | uniq -d
}

# Optimized function to configure the PATH in batch mode
setup_path() {
  # Initial base path
  local base_path="/usr/bin:/bin:/usr/sbin:/sbin"
  
  # Array for directories to prepend (high priority)
  local prepend_dirs=(
    "/opt/homebrew/bin"
    "$HOME/.local/bin"
    "/usr/local/bin"
    "$HOME/usr/local/bin"
  )
  
  # Array for directories to append
  local append_dirs=(
    "$HOME/.nix-profile/bin"
    "/nix/var/nix/profiles/default/bin"
    "/run/current-system/sw/bin"
    "$HOME/.cabal/bin"
    "$HOME/.ghcup/bin"
    "$HOME/.ada/bin"
    "$HOME/.cargo/bin"
    "$GOPATH/bin"
    "$GOROOT/bin"
    "$HOME/.config/emacs/bin"
    "/opt/homebrew/opt/openjdk/bin"
    "/opt/homebrew/opt/llvm/bin"
    "/usr/local/texlive/2025/bin/universal-darwin"
    "/Library/TeX/texbin"
    "$ANDROID_HOME/tools"
    "$ANDROID_HOME/tools/bin"
    "$ANDROID_HOME/platform-tools"
    "/usr/local/git/bin"
    "/usr/local/mysql/bin"
    "/opt/homebrew/opt/ncurses/bin"
    "$HOME/00_ENV/miniforge3/bin"
    "$HOME/00_ENV/miniforge3/condabin"
    "$HOME/.lcs-bin"
    "$HOME/Library/Application Support/JetBrains/Toolbox/scripts"
  )
  
  # Build the prepend paths
  local new_prepend=""
  for dir in "${prepend_dirs[@]}"; do
    if [[ -d "$dir" && ":$base_path:" != *":$dir:"* ]]; then
      new_prepend="$dir:$new_prepend"
    fi
  done

  # Modify the function to skip existence checks for some critical paths
  for dir in "${append_dirs[@]}"; do
    # Check if the path is critical (add paths here that MUST be included)
    if [[ "$dir" == "$HOME/.nix-profile/bin"  ||
          "$dir" == "$ANDROID_HOME/tools"     ||
          "$dir" == "$ANDROID_HOME/tools/bin" ||
          "$dir" == "/usr/local/git/bin" ]]; then
      # Add without existence check
      new_append="$new_append:$dir"
    elif [[ -d "$dir" && ":$base_path:" != *":$dir:"* && ":$new_prepend:" != *":$dir:"* ]]; then
      # Normal check for other paths
      new_append="$new_append:$dir"
    fi
  done
  
  # Assemble the complete path
  export PATH="${new_prepend}${base_path}${new_append}"
}

# =========================================================================== #
# +++++++++++++++++++++++++++++ PATH CONFIGURATION ++++++++++++++++++++++++++ #
# =========================================================================== #

# Setup PATH in batch mode
setup_path

# =============== Terminal Variables ============= #
if [ "$TERM" = "xterm-kitty" ]; then
    export TERM=xterm-kitty
else
    export TERM=xterm-256color
fi

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load
ZSH_THEME="robbyrussell"

# Set up XDG Base Directory Specification
export XDG_CONFIG_HOME="$HOME/.config"

# Set default editor
export EDITOR="nvim"

# =========================================================================== #
# +++++++++++++++++++++++++++++++ OH-MY-ZSH +++++++++++++++++++++++++++++++ #
# =========================================================================== #

# Would you like to use another custom folder than $ZSH/custom?
ZSH_CUSTOM=$HOME/.config/zsh

# Which plugins would you like to load?
# Note: zsh-syntax-highlighting must be the last plugin to work correctly
plugins=( 
    git
    sudo
    extract
    colored-man-pages
    zsh-autosuggestions
    zsh-syntax-highlighting 
)

source $ZSH/oh-my-zsh.sh

# Cache di ZSH
export ZSH_COMPDUMP="$ZSH/cache/.zcompdump-$HOST"

# =========================================================================== #
# +++++++++++++++++++++++++++ ENVIRONMENT VARIABLES +++++++++++++++++++++++++ #
# =========================================================================== #

# ------------ Homebrew ------------- #
# Set PATH, MANPATH, etc., for Homebrew.
eval "$(/opt/homebrew/bin/brew shellenv)"

# Update Homebrew packages
function brew() {
  command brew "$@" 

  if [[ $* =~ "upgrade" ]] || [[ $* =~ "update" ]] || [[ $* =~ "outdated" ]]; then
    sketchybar --trigger brew_update
  fi
}

# ------------ Nix ------------------ #
if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
  . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
elif [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
  . "$HOME/.nix-profile/etc/profile.d/nix.sh"
fi

# Note: Nix paths are already configured in the setup_path function

# =========================================================================== #
# +++++++++++++++++++++ LINGUAGGI E STRUMENTI DI SVILUPPO ++++++++++++++++++ #
# =========================================================================== #

# Nota: tutti i percorsi sono già configurati nella funzione setup_path 
# all'inizio del file

# Haskell (ghcup-env)
[ -f "/Users/lcs-dev/.ghcup/env" ] && . "/Users/lcs-dev/.ghcup/env"

# C/C++ Libraries
export CPATH=/opt/homebrew/include

# GO Language 
export GOROOT=/usr/local/go
export GOPATH=$HOME/00_ENV/go

# Java
#export JAVA_HOME=$(/usr/libexec/java_home)

# OpenJDK
export CPPFLAGS="-I/opt/homebrew/opt/openjdk/include"

# Android ADB
export ANDROID_HOME="$HOME/Library/Android/Sdk"

# NVM - It's necessary to load nvm path here before call to setup_path
# export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
# This loads nvm
# [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh" 
# This loads nvm bash_completion
# [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

# FNM (Fast Node Manager)
FNM_PATH="/opt/homebrew/bin/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="/opt/homebrew/bin/fnm:$PATH"
fi
eval "$(fnm env --use-on-cd --shell zsh)"

# =========================================================================== #
# +++++++++++++++++++++++++++ GLOBAL VARIABLES ++++++++++++++++++++++++++++++ #
# =========================================================================== #

# -------------------------------- Directories ------------------------------ #
# LCS.Data Volume
export LCS_Data="/Volumes/LCS.Data"
# Check if the volume is already mounted
if [ ! -d "$LCS_Data" ]; then
  echo "⚠️  Attenzione: Il volume LCS.Data non è montato"
fi

# Configuration System Directory
export CONFIG_DIR="$HOME/.config"

# Clang-Format Configuration
export CLANG_FORMAT_CONFIG="$HOME/.config/clang-format/.clang-format"

# -------------------------------- BLOG ------------------------------------- #
# Variables for Blog Automation
export BLOG_POSTS_DIR="$LCS_Data/Blog/CS-Topics/content/posts/"
export BLOG_STATIC_IMAGES_DIR="$LCS_Data/Blog/CS-Topics/static/images"
export IMAGES_SCRIPT_PATH="$LCS_Data/Blog/Automatic-Updates/images.py"
export OBSIDIAN_ATTACHMENTS_DIR="$HOME/Documents/Obsidian-Vault/XSPC-Vault/Blog/images"

# =========================================================================== #
# ++++++++++++++++++++++ PERSONAL CONFIGURATION - THEMES ++++++++++++++++++++ #
# =========================================================================== #

# -------------------------------- VI-MODE ---------------------------------- #
# Abilita modalità vi
bindkey -v

# Riduce il ritardo per il cambio modalità (0.1 secondi)
export KEYTIMEOUT=10

# Imposta la variabile per Oh-My-Posh
export ZSH_VI_MODE="viins"

# Funzione principale per aggiornare la modalità
function update_vim_mode() {
  export ZSH_VI_MODE="${KEYMAP}"
  zle reset-prompt
}

# Collega agli eventi zle
function zle-keymap-select() {
  update_vim_mode
}

function zle-line-init() {
  zle -K viins
  update_vim_mode
}

zle -N zle-keymap-select
zle -N zle-line-init

# Funzioni esplicite per cambio modalità
function vim_insert_mode() {
  zle -K viins
  update_vim_mode
}

function vim_normal_mode() {
  zle -K vicmd
  update_vim_mode
}

# Crea widget zle
zle -N vim_insert_mode
zle -N vim_normal_mode

# Associa i tasti per il passaggio alla modalità inserimento
bindkey -M vicmd 'i' vim_insert_mode
bindkey -M vicmd 'I' vim_insert_mode
bindkey -M vicmd 'a' vim_insert_mode
bindkey -M vicmd 'A' vim_insert_mode
bindkey -M vicmd 'o' vim_insert_mode
bindkey -M vicmd 'O' vim_insert_mode

# Associa ESC per il passaggio alla modalità normale
bindkey -M viins '^[' vim_normal_mode

# -------------------------------- PROMPT ----------------------------------- #
# Oh My Posh - Prompt personalizzato
eval "$(oh-my-posh init zsh --config $XDG_CONFIG_HOME/oh-my-posh/lcs-dev.omp.json)"

# --------------------------------- COLORS ---------------------------------- #
# --------------- FZF --------------- #
# Set up fzf key bindings and fuzzy completion
eval "$(fzf --zsh)"

_gen_fzf_default_opts() {
# ---------- Setup FZF theme -------- #
# Scheme name: Tokyo Night

local color00='#1a1b26'  # background
local color01='#16161e'  # darker background
local color02='#2f3549'  # selection background
local color03='#414868'  # comments
local color04='#787c99'  # dark foreground
local color05='#a9b1d6'  # foreground
local color06='#c0caf5'  # light foreground
local color07='#cfc9c2'  # lighter foreground
local color08='#f7768e'  # red
local color09='#ff9e64'  # orange
local color0A='#e0af68'  # yellow
local color0B='#9ece6a'  # green
local color0C='#2ac3de'  # cyan
local color0D='#7aa2f7'  # blue
local color0E='#bb9af7'  # purple
local color0F='#cfc9c2'  # grey/white

export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS"\
" --color=bg+:$color01,bg:$color00,spinner:$color0C,hl:$color0D"\
" --color=fg:$color04,header:$color0D,info:$color0A,pointer:$color0C"\
" --color=marker:$color0C,fg+:$color06,prompt:$color0A,hl+:$color0D"
}

_gen_fzf_default_opts

# ------ Use fd instead of fzf ------ #
export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

# Use fd (https://github.com/sharkdp/fd) for listing path candidates.
_fzf_compgen_path() {
  fd --hidden --exclude .git . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type=d --hidden --exclude .git . "$1"
}

source ~/.config/fzf-git.sh/fzf-git.sh

export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always --line-range :500 {}'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

# Advanced customization of fzf options via _fzf_comprun function
_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview 'eza --tree --color=always {} | head -200'   "$@" ;;
    export|unset) fzf --preview "eval 'echo $'{}"         "$@" ;;
    ssh)          fzf --preview 'dig {}'                  "$@" ;;
    *)            fzf --preview "bat -n --color=always --line-range :500 {}" "$@" ;;
  esac
}

# --------- Bat (better cat) -------- #
export BAT_THEME=tokyonight_night

# =========================================================================== #
# +++++++++++++++++++++++++++ APPLICATIONS OPTIONS ++++++++++++++++++++++++++ #
# =========================================================================== #

# ------- Zoxide (better cd) -------- #
eval "$(zoxide init zsh)"

# ------------ ngrok ---------------- #
if command -v ngrok &>/dev/null; then
    eval "$(ngrok completion)"
fi

# ----------- Angular CLI ----------- #
if command -v ng &>/dev/null; then
    source <(ng completion script)
fi

# -------------- PyENV -------------- #
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# >>> Conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/lcs-dev/00_ENV/miniforge3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/lcs-dev/00_ENV/miniforge3/etc/profile.d/conda.sh" ]; then
        . "/Users/lcs-dev/00_ENV/miniforge3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/lcs-dev/00_ENV/miniforge3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< Conda initialize <<<

# vTerm - Emacs Settings
vterm_printf() {
    if [ -n "$TMUX" ] && ([ "${TERM%%-*}" = "tmux" ] || [ "${TERM%%-*}" = "screen" ]); then
        # Tell tmux to pass the escape sequences through
        printf "\ePtmux;\e\e]%s\007\e\\" "$1"
    elif [ "${TERM%%-*}" = "screen" ]; then
        # GNU screen (screen, screen-256color, screen-256color-bce)
        printf "\eP\e]%s\007\e\\" "$1"
    else
        printf "\e]%s\e\\" "$1"
    fi
}

# =========================================================================== #
# ++++++++++++++++++++++++++++++++ ALIASES +++++++++++++++++++++++++++++++++++ #
# =========================================================================== #

# Dirs
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ......="cd ../../../../.."

# Compile C++ programs
alias compile="clang++ -std=c++20 -O3 -march=native -flto=thin -ffast-math -I/usr/local/include"

# Eza (sostituto moderno di ls)
alias ls="eza --color=always --long --git --icons=always"

# thefuck alias (corregge i comandi digitati male)
eval $(thefuck --alias)       # Crea l'alias "fuck"
eval $(thefuck --alias fk)    # Crea l'alias più breve "fk"

# Zoxide (sostituto intelligente di cd)
# Nota: questo alias sovrascrive completamente il comando cd nativo
# Se hai problemi con script che si aspettano il comportamento standard di cd, rimuovi questa riga
alias cd="z"

# Clear terminal
alias c="clear"

# Tailscale
alias tailscale="/Applications/Tailscale.app/Contents/MacOS/Tailscale"

# Ranger (file manager da terminale)
alias ranger='TERM=screen-256color ranger'

# MySQL
alias mysql=/usr/local/mysql/bin/mysql
alias mysqladmin=/usr/local/mysql/bin/mysqladmin

# Clang-Format alias
alias clang-format='clang-format -style=file:$CLANG_FORMAT_CONFIG'

# GCC Homebrew
alias gcc='gcc-14'

# LLDB
alias lldb='/usr/bin/lldb'

# =========================================================================== #


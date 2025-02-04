# =========================================================================== #
# +++++++++++++++++++++++++++ BASE CONFIGURATION ++++++++++++++++++++++++++++ #
# =========================================================================== #

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.

# if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#   source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
# fi

# =============== Startup Commands =============== #
# fastfetch

# =============== Terminal Variables ============= #
if [ "$TERM" = "xterm-kitty" ]; then
    export TERM=xterm-kitty
else
    export TERM=xterm-256color
fi

# If you come from bash you might have to change your $PATH.
#export PATH=$HOME/bin:/usr/local/bin:$PATH
export PATH=$HOME/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder
ZSH_CUSTOM=$HOME/.config/zsh

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=( git
          sudo
          extract
		      colored-man-pages
          zsh-autosuggestions
		      zsh-syntax-highlighting )

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

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
# ------------ End Homebrew --------- #

# ------------ Nix ------------------ #
if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
  . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
elif [ -e '$HOME/.nix-profile/etc/profile.d/nix.sh' ]; then
  . '$HOME/.nix-profile/etc/profile.d/nix.sh'
fi

export PATH="/run/current-system/sw/bin:$PATH"
export PATH=$HOME/.nix-profile/bin:/nix/var/nix/profiles/default/bin:$PATH
# ------------ End Nix -------------- #

# Set up XDG Base Directory Specification
export XDG_CONFIG_HOME="$HOME/.config"

# C/C++ Libraries
export CPATH=/opt/homebrew/include

# Rust
export PATH=$HOME/.cargo/bin:$PATH

# GO Language 
export GOROOT=/usr/local/go
export GOPATH=$HOME/00_ENV/go
export PATH=$GOPATH/bin:$GOROOT/bin:$PATH

# Emacs
export PATH="$PATH:/Users/lcs-dev/.config/emacs/bin"

# LaTeX
export PATH="/usr/local/texlive/2024/bin/universal-darwin:$PATH"

# Java
#export JAVA_HOME=$(/usr/libexec/java_home)

# OpenJDK
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
export CPPFLAGS="-I/opt/homebrew/opt/openjdk/include"

# Android ADB
export ANDROID_HOME="$HOME/Library/Android/Sdk"
export PATH="$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools:$PATH"

# NVM
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

# Git
export PATH="/usr/local/git/bin:$PATH"
export PATH="/opt/homebrew/opt/ncurses/bin:$PATH"

# Miniforge3
export PATH="$PATH:$HOME/00_ENV/miniforge3/bin"

# Toolbox App
export PATH="$PATH:/Users/lcs-dev/Library/Application Support/JetBrains/Toolbox/scripts"

# MySQL
export PATH="/usr/local/mysql/bin:$PATH"

# ZSH Cache
export ZSH_COMPDUMP="$ZSH/cache/.zcompdump-$HOST"

# =========================================================================== #
# +++++++++++++++++++++++++++ GLOBAL VARIABLES ++++++++++++++++++++++++++++++ #
# =========================================================================== #

# -------------------------------- Directories ------------------------------ #
# LCS.Data Volume
export LCS_Data="/Volumes/LCS.Data"

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

# -------------------------------- PROMPT ----------------------------------- #
# Powerlevel10k
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
# [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
# source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme

# Oh My Posh
# eval "$(oh-my-posh init zsh --config $(brew --prefix oh-my-posh)/themes/tokyo-night.omp.json)"
eval "$(oh-my-posh init zsh --config $XDG_CONFIG_HOME/oh-my-posh/lcs-dev.omp.json)"

# Starship
# eval "$(starship init zsh)"

# --------------------------------- COLORS ---------------------------------- #
# --------------- FZF --------------- #
# Set up fzf key bindings and fuzzy completion
eval "$(fzf --zsh)"

_gen_fzf_default_opts() {

# --------- Setup FZF theme --------- #
# Scheme name: Gruvbox dark, soft

# local color00='#32302f'
# local color01='#3c3836'
# local color02='#504945'
# local color03='#665c54'
# local color04='#bdae93'
# local color05='#d5c4a1'
# local color06='#ebdbb2'
# local color07='#fbf1c7'
# local color08='#fb4934'
# local color09='#fe8019'
# local color0A='#fabd2f'
# local color0B='#b8bb26'
# local color0C='#8ec07c'
# local color0D='#83a598'
# local color0E='#d3869b'
# local color0F='#d65d0e'

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
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
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
# - The first argument to the function is the name of the command.
# - You should make sure to pass the rest of the arguments to fzf.
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

# Load Angular CLI autocompletion.
source <(ng completion script)

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
# ++++++++++++++++++++++++++++++++ OTHERS +++++++++++++++++++++++++++++++++++ #
# =========================================================================== #

# Vim
bindkey -v

alias mysql=/usr/local/mysql/bin/mysql
alias mysqladmin=/usr/local/mysql/bin/mysqladmin

# -------------------------------- Aliases ---------------------------------- #

# Dirs
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ......="cd ../../../../.."

# Compile C++ programs
alias compile="clang++ -std=c++17 -O3 -march=native -flto=thin -ffast-math"

# Eza
alias ls="eza --color=always --long --git --icons=always"

# thefuck alias
eval $(thefuck --alias)
eval $(thefuck --alias fk)

# Zoxide 
alias cd="z"

# Clear terminal
alias c="clear"

# Tailscale
alias tailscale="/Applications/Tailscale.app/Contents/MacOS/Tailscale"

# Ranger
ranger='TERM=screen-256color ranger'

# Fastfetch
# alias fastfetch-logo="$XDG_CONFIG_HOME/fastfetch/tmux_with_logo_fix.sh"

# Clang-Format alias
alias clang-format='clang-format -style=file:$CLANG_FORMAT_CONFIG'


# =========================================================================== #

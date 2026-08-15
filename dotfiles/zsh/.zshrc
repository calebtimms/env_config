#
# ~/.zshrc
#

# =============================================================================
# Shell Initialization
# =============================================================================

# If not running interactively, don't do anything
[[ -o interactive ]] || return


# =============================================================================
# Environment
# =============================================================================

# Environment configuration utilities
export PATH="$HOME/env_config/scripts:$PATH"


# =============================================================================
# Prompt
# =============================================================================

autoload -Uz colors && colors
autoload -Uz vcs_info
autoload -Uz add-zsh-hook

setopt prompt_subst

# -----------------------------------------------------------------------------
# Git Information
# -----------------------------------------------------------------------------

zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' check-for-changes true

# + = staged changes
# * = unstaged changes
zstyle ':vcs_info:git:*' stagedstr '+'
zstyle ':vcs_info:git:*' unstagedstr '*'

zstyle ':vcs_info:git:*' formats '%F{yellow}[%b%c%u]%f '
zstyle ':vcs_info:git:*' actionformats '%F{yellow}[%b|%a%c%u]%f '

add-zsh-hook precmd vcs_info


# -----------------------------------------------------------------------------
# Main Prompt
# -----------------------------------------------------------------------------

PROMPT='%B%F{cyan}%1~%f%b ${vcs_info_msg_0_}%B%F{magenta}>%f%b '


# -----------------------------------------------------------------------------
# Right Prompt
# -----------------------------------------------------------------------------

# Only show a non-zero exit status
RPROMPT='%(?..%F{red}exit %?%f) %(1j.%F{yellow}%j job(s)%f.)'

PROMPT_EOL_MARK=''


# =============================================================================
# Core Zsh Behavior
# =============================================================================

# -----------------------------------------------------------------------------
# General Options
# -----------------------------------------------------------------------------

unsetopt beep
setopt autocd extendedglob nomatch notify


# -----------------------------------------------------------------------------
# History
# -----------------------------------------------------------------------------

HISTFILE=~/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000

setopt SHARE_HISTORY           # Share history across terminals
setopt HIST_IGNORE_DUPS        # Ignore consecutive duplicates
setopt HIST_FIND_NO_DUPS       # Avoid duplicates in native ZLE history searches
setopt HIST_REDUCE_BLANKS      # Collapse repeated spaces
setopt HIST_VERIFY             # Expand !history but don't execute immediately


# =============================================================================
# Completion System
# =============================================================================

# The following lines were added by compinstall
zstyle :compinstall filename '/home/Timmseh/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

setopt noautomenu
setopt nomenucomplete
setopt list_ambiguous

# Stop inserting tabs on blank lines
zstyle ':completion:*' insert-tab false


# =============================================================================
# ZLE / Command-Line Editing
# =============================================================================

bindkey -e

# Don't highlight pasted text
zle_highlight+=(paste:none)


# -----------------------------------------------------------------------------
# Line Movement
# -----------------------------------------------------------------------------

# Like H / L in my Vim config
bindkey -M emacs '^H' beginning-of-line
bindkey -M emacs '^L' end-of-line


# -----------------------------------------------------------------------------
# Word Movement
# -----------------------------------------------------------------------------

# Like Alt+h / Alt+l in my Vim config
bindkey -M emacs '^[h' vi-backward-word
bindkey -M emacs '^[l' vi-forward-word


# -----------------------------------------------------------------------------
# Vertical / History Movement
# -----------------------------------------------------------------------------

# My Vim j/k are reversed:
# j = up
# k = down
bindkey -M emacs '^[j' up-line-or-history
bindkey -M emacs '^[k' down-line-or-history


# -----------------------------------------------------------------------------
# Beginning / End of History
# -----------------------------------------------------------------------------

# Similar idea to J = gg and K = G
bindkey -M emacs '^[J' beginning-of-history
bindkey -M emacs '^[K' end-of-history


# -----------------------------------------------------------------------------
# Editing
# -----------------------------------------------------------------------------

# Delete previous word
bindkey -M emacs '^W' backward-kill-word

# Delete from cursor back to beginning of line
bindkey -M emacs '^U' backward-kill-line

# Delete next word
bindkey -M emacs '^[d' kill-word

# Delete previous word
bindkey -M emacs '^[x' backward-kill-word


# -----------------------------------------------------------------------------
# Undo / Redo
# -----------------------------------------------------------------------------

bindkey -M emacs '^[u' undo
bindkey -M emacs '^[r' redo


# =============================================================================
# Plugin Configuration
# =============================================================================

# -----------------------------------------------------------------------------
# fzf
# -----------------------------------------------------------------------------

# Commands used to populate fzf
export FZF_DEFAULT_COMMAND='fd --type f --hidden'

# General fzf behavior
export FZF_DEFAULT_OPTS='
  --height=60%
  --layout=reverse
  --border
  --cycle
  --bind=ctrl-k:down
  --bind=ctrl-j:up
  --bind=ctrl-d:half-page-down
  --bind=ctrl-u:half-page-up
'

# Disable fzf's built-in Ctrl+R, Ctrl+T, and Alt+C bindings.
# Custom Ctrl+F, Ctrl+T, and Ctrl+G bindings are defined below.
FZF_CTRL_R_COMMAND= \
FZF_CTRL_T_COMMAND= \
FZF_ALT_C_COMMAND= \
source <(fzf --zsh)


# -----------------------------------------------------------------------------
# Zoxide
# -----------------------------------------------------------------------------

eval "$(zoxide init zsh --cmd cd)"


# -----------------------------------------------------------------------------
# Atuin
# -----------------------------------------------------------------------------

# Let Atuin record rich history, but don't let it install any keybindings.
export ATUIN_NOBIND="true"
eval "$(atuin init zsh)"


# =============================================================================
# Custom fzf / ZLE Integration
# =============================================================================

# -----------------------------------------------------------------------------
# Unified Switchable fzf Picker
# -----------------------------------------------------------------------------

_atuin_history_rows() {
    atuin search "$@" \
        --human \
        --format $'{command}\x1f{relativetime}\x1f{exit}\x1f{duration}\x1f{directory}' |
        awk -F $'\x1f' -v OFS=$'\x1f' -v home="$HOME" '
            function shorten_dir(dir, width) {
                # Replace $HOME with ~
                if (dir == home)
                    dir = "~"
                else if (index(dir, home "/") == 1)
                    dir = "~" substr(dir, length(home) + 1)

                # Keep the useful tail of very long paths
                if (length(dir) > width)
                    dir = "…" substr(dir, length(dir) - width + 2)

                return dir
            }

            !seen[$1]++ {
                command   = $1
                age       = $2
                code      = $3
                duration  = $4
                directory = shorten_dir($5, 28)

                # ANSI styling
                reset      = "\033[0m"
                dim        = "\033[90m"
                cyan       = "\033[36m"
                bold_white = "\033[1;37m"

                # Build status before coloring so ANSI codes
                # do not interfere with column alignment.
                if (code == "0") {
                    status_plain = "✓"
                    status_color = "\033[32m"
                }
                else if (code == "-1" || code == "") {
                    status_plain = "?"
                    status_color = "\033[90m"
                }
                else {
                    status_plain = "✗ " code
                    status_color = "\033[31m"
                }

                # Build fixed-width plain fields first
                age_field       = sprintf("%-7s", age)
                status_field    = sprintf("%-8s", status_plain)
                duration_field  = sprintf("%-10s", duration)
                directory_field = sprintf("%-28s", directory)

                # Apply color only after padding
                age_field       = dim age_field reset
                status_field    = status_color status_field reset
                duration_field  = dim duration_field reset
                directory_field = cyan directory_field reset
                command_field   = bold_white command reset

                display = age_field
                display = display " │ " status_field
                display = display " │ " duration_field
                display = display " │ " directory_field
                display = display " │ " command_field

                print command, display
            }
        '
}

_fzf_switcher() {
    local mode="$1"
    local result pressed selection file
    local -a lines selections

    while true; do
        case "$mode" in
            history)
                result=$(
                    _atuin_history_rows |
                        fzf \
                            --tac \
                            --ansi \
                            --scheme=history \
                            --delimiter=$'\x1f' \
                            --with-nth=2 \
                            --accept-nth=1 \
                            --header="$(printf '%-7s │ %-8s │ %-10s │ %-28s │ %s' \
                                AGE STATUS DURATION DIRECTORY COMMAND)" \
                            --prompt='History> ' \
                            --expect=ctrl-f,ctrl-r,ctrl-t,ctrl-g
                )
                ;;
            
            directory_history)
                result=$(
                    _atuin_history_rows --cwd . |
                        fzf \
                            --tac \
                            --ansi \
                            --scheme=history \
                            --delimiter=$'\x1f' \
                            --with-nth=2 \
                            --accept-nth=1 \
                            --header="$(printf '%-7s │ %-8s │ %-10s │ %-28s │ %s' \
                                AGE STATUS DURATION DIRECTORY COMMAND)" \
                            --prompt='Directory History> ' \
                            --expect=ctrl-f,ctrl-r,ctrl-t,ctrl-g
                )
                ;;

            files)
                result=$(
                    fd --type f --hidden \
                       --exclude .git \
                       --exclude .cache |
                        fzf \
                            --multi \
                            --prompt='Files> ' \
                            --expect=ctrl-f,ctrl-r,ctrl-t,ctrl-g
                )
                ;;

            directories)
                result=$(
                    fd --type d --hidden \
                       --exclude .git \
                       --exclude .cache |
                        fzf \
                            --prompt='Directories> ' \
                            --expect=ctrl-f,ctrl-r,ctrl-t,ctrl-g
                )
                ;;
        esac

        # Esc / Ctrl-C: leave the current command line untouched.
        if [[ -z "$result" ]]; then
            break
        fi

        # --expect reserves the first output line for the pressed key.
        lines=("${(@f)result}")
        pressed="${lines[1]}"
        selections=("${lines[@]:1}")

        case "$pressed" in
            ctrl-f)
                [[ "$mode" == history ]] && break
        
                mode=history
                zle reset-prompt
                zle -R
                continue
                ;;
        
            ctrl-r)
                [[ "$mode" == directory_history ]] && break
        
                mode=directory_history
                zle reset-prompt
                zle -R
                continue
                ;;
        
            ctrl-t)
                [[ "$mode" == files ]] && break
        
                mode=files
                zle reset-prompt
                zle -R
                continue
                ;;
        
            ctrl-g)
                [[ "$mode" == directories ]] && break
        
                mode=directories
                zle reset-prompt
                zle -R
                continue
                ;;
        esac

        # Enter was pressed without a selection.
        (( ${#selections} )) || break

        case "$mode" in
            history|directory_history)
                # History search replaces the current command with
                # the selected previous command.
                BUFFER="${selections[1]}"
                CURSOR=${#BUFFER}
                ;;
        
            files)
                # Insert selected path(s) exactly at the current cursor.
                for file in "${selections[@]}"; do
                    LBUFFER+="${(q)file} "
                done
                ;;
        
            directories)
                selection="${selections[1]}"
                [[ -n "$selection" ]] || break
        
                builtin cd -- "$selection"
                ;;
        esac

        break
    done

    # fzf temporarily takes over the terminal display.
    # Restore the prompt and whatever is currently in the ZLE buffer.
    zle reset-prompt
    zle -R
}


# -----------------------------------------------------------------------------
# fzf ZLE Widgets
# -----------------------------------------------------------------------------

_fzf_history_switcher() {
    _fzf_switcher history
}

_fzf_directory_history_switcher() {
    _fzf_switcher directory_history
}

_fzf_file_switcher() {
    _fzf_switcher files
}

_fzf_directory_switcher() {
    _fzf_switcher directories
}

zle -N _fzf_history_switcher
zle -N _fzf_directory_history_switcher
zle -N _fzf_file_switcher
zle -N _fzf_directory_switcher


# -----------------------------------------------------------------------------
# fzf ZLE Bindings
# -----------------------------------------------------------------------------

# Custom unified switcher
bindkey -M emacs '^F' _fzf_history_switcher
bindkey -M emacs '^R' _fzf_directory_history_switcher
bindkey -M emacs '^T' _fzf_file_switcher
bindkey -M emacs '^G' _fzf_directory_switcher


# =============================================================================
# Interactive Command Utilities
# =============================================================================

# -----------------------------------------------------------------------------
# Modern Unix Tools / File Listings
# -----------------------------------------------------------------------------

alias ls='eza -a --icons=auto'
alias ll='eza -la --icons=auto'
alias lt='eza -la --icons=auto --sort=modified'
alias ltr='eza -la --icons=auto --sort=modified --reverse'
alias lg='eza -la --git --icons=auto'

alias et='eza --tree --icons=auto'

# Previous coreutils ls configuration
#alias ls='ls -AF --color=auto'
#alias ll='ls -lAF --color=auto'
#alias lt='ls -lAFt --color=auto'
#alias lrt='ls -lAFrt --color=auto'

alias tree='tree -a'

alias dust='dust -r'

# Use bat as the man-page pager
export MANPAGER="bat -plman"


# -----------------------------------------------------------------------------
# Search / Grep
# -----------------------------------------------------------------------------

alias grep='grep --color=auto'
alias e='grep -EHsiInr'
alias ep='grep -EHsiIn'


# =============================================================================
# Editors
# =============================================================================

# -----------------------------------------------------------------------------
# Vim
# -----------------------------------------------------------------------------

export EDITOR='vim'
export SUDO_EDITOR='vim'

alias v='vim'
alias g='gvim'
alias vl='vim -S'
alias gl='gvim -S'
alias vimv='vim ~/.vimrc'
alias gvimv='gvim ~/.vimrc'
alias sv='sudoedit'


# -----------------------------------------------------------------------------
# Vim Plugin Maintenance
# -----------------------------------------------------------------------------

alias ob_fix='sed -i -e "s/'\''let g:this_session = v:this_session'\''/'\''g:this_session = v:this_session'\''/" -e "s/'\''let g:this_obsession = v:this_session'\''/'\''g:this_obsession = v:this_session'\''/" ~/.vim/pack/plugins/start/obsession/plugin/obsession.vim'


# =============================================================================
# Shell / Terminal Configuration
# =============================================================================

# -----------------------------------------------------------------------------
# Zsh Configuration
# -----------------------------------------------------------------------------

alias sz='source ~/.zshrc'
alias vimz='vim ~/.zshrc'
alias type='type -a'


# -----------------------------------------------------------------------------
# Kitty
# -----------------------------------------------------------------------------

alias icat='kitten icat'
alias vimk='vim ~/.config/kitty/kitty.conf'


# -----------------------------------------------------------------------------
# btop - System Monitor
# -----------------------------------------------------------------------------

alias monitor='btop'


# =============================================================================
# Package Management
# =============================================================================

# -----------------------------------------------------------------------------
# Pacman
# -----------------------------------------------------------------------------

alias pi='sudo pacman -S'
alias pr='sudo pacman -Rsu'
alias ps='pacman -Ss'
alias pu='sudo pacman -Syu'


# -----------------------------------------------------------------------------
# Yay / AUR
# -----------------------------------------------------------------------------

alias yi='yay -S'
alias ys='yay -Ss'
alias yu='yay'


# -----------------------------------------------------------------------------
# Package Lists
# -----------------------------------------------------------------------------

# Package list (for all explicitly installed packages)
alias pl='pacman -Qqen'
alias yl='pacman -Qqem'


# -----------------------------------------------------------------------------
# Full System Update
# -----------------------------------------------------------------------------

# Full system update via Pacman and Yay
update()
{
    echo "\n--- Updating via PacMan ---\n"

    if ! sudo pacman -Syu; then
        echo "\n--- PacMan update failed; skipping Yay ---\n"
        return 1
    fi

    echo "\n--- Updating via Yay ---\n"

    yay
    local yay_rc=$?

    echo "\n--- Saving Environment State ---\n"

    env_save

    return "$yay_rc"
}


# -----------------------------------------------------------------------------
# Package Search
# -----------------------------------------------------------------------------

# Package searching across official Arch repo and AUR
search() {
    echo "--- From PacMan ---"
    pacman -Ss "$@"

    echo
    echo "--- From AUR ---"
    yay -Ss "$@"
}


# =============================================================================
# System Administration
# =============================================================================

# -----------------------------------------------------------------------------
# Wine
# -----------------------------------------------------------------------------

wineprefix() {
    if (( $# != 1 )); then
        echo "Usage: wineprefix <name>"
        return 1
    fi

    export WINEPREFIX="$HOME/.wine-$1"
    echo "Using Wine prefix: $WINEPREFIX"
}


# -----------------------------------------------------------------------------
# Filesystems / Mounts
# -----------------------------------------------------------------------------

alias mount_windows='sudo mount -t ntfs-3g UUID=369CE5FA9CE5B491 /mnt/windows'
alias unmount_windows='sudo umount /mnt/windows'


# -----------------------------------------------------------------------------
# Disk / LVM Inspection
# -----------------------------------------------------------------------------

diskcheck() {
    echo '=== ROOT ==='
    findmnt /

    echo
    echo '=== HOME ==='
    findmnt /home

    echo
    echo '=== LVM LOGICAL VOLUMES ==='
    sudo lvs -o lv_name,vg_name,lv_size,devices

    echo
    echo '=== LVM PHYSICAL VOLUMES ==='
    sudo pvs -o pv_name,pv_size,pv_free,vg_name

    echo
    echo '=== PHYSICAL DISKS ==='
    lsblk -d -o NAME,SIZE,MODEL,SERIAL
}


# =============================================================================
# Projects / Application Shortcuts
# =============================================================================

# -----------------------------------------------------------------------------
# Trading Dashboard
# -----------------------------------------------------------------------------

alias td='python ~/TradingDashboard/main.py &'

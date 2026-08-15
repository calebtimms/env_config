#
# ~/.zshrc
#

# If not running interactively, don't do anything
[[ -o interactive ]] || return

# Prompt Customization
autoload -Uz colors && colors

PROMPT='%B%F{cyan}%1~ %F{magenta}>%f%b '

# Environment configuration utilities
export PATH="$HOME/env_config/scripts:$PATH"

# The following lines were added by compinstall
zstyle :compinstall filename '/home/Timmseh/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

# Zsh Options
unsetopt beep
setopt autocd extendedglob nomatch notify

HISTFILE=~/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000

setopt SHARE_HISTORY           # Share history across terminals
setopt HIST_IGNORE_DUPS        # Ignore consecutive duplicates
setopt HIST_FIND_NO_DUPS       # Avoid duplicates in native ZLE history searches
setopt HIST_REDUCE_BLANKS      # Collapse repeated spaces
setopt HIST_VERIFY             # Expand !history but don't execute immediately

setopt noautomenu
setopt nomenucomplete
setopt list_ambiguous

PROMPT_EOL_MARK=''

# Stop inserting tabs on blank lines
zstyle ':completion:*' insert-tab false

# Don't highlight pasted text
zle_highlight+=(paste:none)

# ============================================================
# ZLE / Command-Line Editing
# ============================================================
bindkey -e

# ----- Line movement -----
# Like H / L in my Vim config
bindkey -M emacs '^H' beginning-of-line
bindkey -M emacs '^L' end-of-line

# ----- Word movement -----
# Like Alt+h / Alt+l in my Vim config
bindkey -M emacs '^[h' vi-backward-word
bindkey -M emacs '^[l' vi-forward-word

# ----- Vertical / history movement -----
# My Vim j/k are reversed:
# j = up
# k = down
bindkey -M emacs '^[j' up-line-or-history
bindkey -M emacs '^[k' down-line-or-history

# ----- Beginning / end of history -----
# Similar idea to J = gg and K = G
bindkey -M emacs '^[J' beginning-of-history
bindkey -M emacs '^[K' end-of-history

# ----- Editing -----
# Delete previous word
bindkey -M emacs '^W' backward-kill-word

# Delete from cursor back to beginning of line
bindkey -M emacs '^U' backward-kill-line

# Delete next word
bindkey -M emacs '^[d' kill-word

# Delete previous word
bindkey -M emacs '^[x' backward-kill-word


# ----- Undo / redo -----

bindkey -M emacs '^[u' undo
bindkey -M emacs '^[r' redo

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


## Plugin Sourcing:

# fzf - Disable its built-in Ctrl+R, Ctrl+T, and Alt+C bindings.
# Custom Ctrl+F, Ctrl+T, and Ctrl+G bindings are defined below.
FZF_CTRL_R_COMMAND= \
FZF_CTRL_T_COMMAND= \
FZF_ALT_C_COMMAND= \
source <(fzf --zsh)

# Zoxide
eval "$(zoxide init zsh --cmd cd)"

# ---------------------------------------------------------------------------
# Unified switchable fzf picker
# ---------------------------------------------------------------------------

_fzf_switcher() {
    local mode="$1"
    local result pressed selection file
    local -a lines selections

    while true; do
        case "$mode" in
            history)
                result=$(
                    fc -rl 1 |
                        sed -E 's/^[[:space:]]*[0-9]+[[:space:]]+//' |
                        awk '!seen[$0]++' |
                        fzf \
                            --prompt='History> ' \
                            --expect=ctrl-f,ctrl-t,ctrl-g
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
                            --expect=ctrl-f,ctrl-t,ctrl-g
                )
                ;;

            directories)
                result=$(
                    fd --type d --hidden \
                       --exclude .git \
                       --exclude .cache |
                        fzf \
                            --prompt='Directories> ' \
                            --expect=ctrl-f,ctrl-t,ctrl-g
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
            history)
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

_fzf_history_switcher() {
    _fzf_switcher history
}

_fzf_file_switcher() {
    _fzf_switcher files
}

_fzf_directory_switcher() {
    _fzf_switcher directories
}

zle -N _fzf_history_switcher
zle -N _fzf_file_switcher
zle -N _fzf_directory_switcher

# ============================================================
# fzf ZLE bindings
# ============================================================

# Custom unified switcher
bindkey -M emacs '^F' _fzf_history_switcher
bindkey -M emacs '^T' _fzf_file_switcher
bindkey -M emacs '^G' _fzf_directory_switcher

# Explicitly removing CTRL+R keybinding
bindkey -M emacs -r '^R'


# ---------------------------------------------------------------------------
# System Aliases
# ---------------------------------------------------------------------------

alias ls='eza -a --icons=auto'
alias ll='eza -la --icons=auto'
alias lt='eza -la --icons=auto --sort=modified'
alias ltr='eza -la --icons=auto --sort=modified --reverse'
alias lg='eza -la --git --icons=auto'

alias et='eza --tree --icons=auto'

#alias ls='ls -AF --color=auto'
#alias ll='ls -lAF --color=auto'
#alias lt='ls -lAFt --color=auto'
#alias lrt='ls -lAFrt --color=auto'

alias tree='tree -a'

alias grep='grep --color=auto'
alias e='grep -EHsiInr'
alias ep='grep -EHsiIn'

alias icat='kitten icat'

# Use bat as the man-page pager
export MANPAGER="bat -plman"

# Vim Things
export EDITOR='vim'
export SUDO_EDITOR='vim'

alias v='vim'
alias g='gvim'
alias vl='vim -S'
alias gl='gvim -S'
alias vimv='vim ~/.vimrc'
alias gvimv='gvim ~/.vimrc'
alias sv='sudoedit'

# Vim Plugin Aliases
alias ob_fix='sed -i -e "s/'\''let g:this_session = v:this_session'\''/'\''g:this_session = v:this_session'\''/" -e "s/'\''let g:this_obsession = v:this_session'\''/'\''g:this_obsession = v:this_session'\''/" ~/.vim/pack/plugins/start/obsession/plugin/obsession.vim'

# Shell Aliases
alias sz='source ~/.zshrc'
alias vimz='vim ~/.zshrc'

alias dust='dust -r'

# Code Project Aliases
alias td='python ~/TradingDashboard/main.py &'

# Kitty Aliases
alias vimk='vim ~/.config/kitty/kitty.conf'

# Pacman Aliases
alias pi='sudo pacman -S'
alias pr='sudo pacman -Rsu'
alias ps='pacman -Ss'
alias pu='sudo pacman -Syu'

alias yi='yay -S'
alias ys='yay -Ss'
alias yu='yay'

# Package list (for all explicitly installed packages)
alias pl='pacman -Qqen'
alias yl='pacman -Qqem'

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

# Package searching across official Arch repo and AUR
search() {
    echo "--- From PacMan ---"
    pacman -Ss "$@"

    echo
    echo "--- From AUR ---"
    yay -Ss "$@"
}

# Wine Things
wineprefix() {
    if (( $# != 1 )); then
        echo "Usage: wineprefix <name>"
        return 1
    fi

    export WINEPREFIX="$HOME/.wine-$1"
    echo "Using Wine prefix: $WINEPREFIX"
}

# Mounts
alias mount_windows='sudo mount -t ntfs-3g UUID=369CE5FA9CE5B491 /mnt/windows'
alias unmount_windows='sudo umount /mnt/windows'

# Disk and LVM check
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

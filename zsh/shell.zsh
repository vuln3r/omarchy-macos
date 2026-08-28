# lyx-theme - shell (Osaka Jade)
# The terminal half of Omarchy, ported to zsh.
# Source: basecamp/omarchy default/bash/{aliases,envs,init}
#
# Every block asks for its tool first, so this file stays harmless on a
# machine where one of them is missing.

# --- eza: ls with icons, git state, directories first ------------------------
if command -v eza >/dev/null; then
    alias ls='eza -lh --group-directories-first --icons=auto'
    alias lsa='ls -a'
    alias lt='eza --tree --level=2 --long --icons --git'
    alias lta='lt -a'
fi

# --- bat: colored man pages --------------------------------------------------
# BAT_THEME=ansi makes bat use the 16 terminal colors instead of its own
# palette - so it is Osaka Jade for free, and follows the terminal everywhere.
if command -v bat >/dev/null; then
    export BAT_THEME=ansi
    export MANROFFOPT="-c"
    export MANPAGER="sh -c 'col -bx | bat -l man -p'"
fi

# --- fzf: Ctrl-R history, Ctrl-T files, Alt-C directories --------------------
if command -v fzf >/dev/null; then
    # bg=-1 keeps the terminal background, and with it Ghostty's blur.
    export FZF_DEFAULT_OPTS="
        --height 40% --layout=reverse --border
        --color=fg:#c1c497,bg:-1,hl:#2dd5b7
        --color=fg+:#d6d5bc,bg+:#23372b,hl+:#2dd5b7
        --color=info:#509475,prompt:#63b07a,pointer:#e5c736
        --color=marker:#d2689c,spinner:#509475,header:#53685b
        --color=border:#32473b,gutter:-1"
    source <(fzf --zsh)

    # Pick a file, see it before you commit to it.
    if command -v bat >/dev/null; then
        alias ff="fzf --preview 'bat --style=numbers --color=always {}'"
    else
        alias ff="fzf --preview 'head -100 {}'"
    fi
    alias eff='${EDITOR:-vi} "$(ff)"'
fi

# --- zoxide: cd that remembers where you have been ---------------------------
# A real path still behaves exactly like cd; only an unknown argument is
# handed to zoxide, which jumps to the best match and prints where it landed.
if command -v zoxide >/dev/null; then
    eval "$(zoxide init zsh)"

    zd() {
        if (( $# == 0 )); then
            builtin cd ~ || return
        elif [[ -d $1 ]]; then
            builtin cd "$1" || return
        else
            z "$@" || { echo "Error: Directory not found"; return 1; }
            printf '\U000F17A9 '
            pwd
        fi
    }
    alias cd=zd
fi

# --- Directories -------------------------------------------------------------
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

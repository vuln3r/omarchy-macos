# omarchy-macos - zsh colors (Osaka Jade)
# Sourced from the omarchy-macos block in .zshrc, after oh-my-zsh has loaded its
# plugins. Both arrays are read when a line is drawn, not when the plugin
# loads, so setting them here is late enough.

# zsh-autosuggestions ---------------------------------------------------------
# The default is fg=8, which in this palette is #53685b on #111c18 - under 3:1
# contrast, so the suggestion is technically there and practically invisible.
# Jade sits at 4.9:1: clearly readable, still clearly below the foreground.
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#509475'

# zsh-syntax-highlighting -----------------------------------------------------
# Only touch it when the plugin is actually loaded, otherwise this quietly
# creates a stray array on a machine without it.
if (( ${+ZSH_HIGHLIGHT_STYLES} )); then
    ZSH_HIGHLIGHT_STYLES[command]='fg=#63b07a'
    ZSH_HIGHLIGHT_STYLES[builtin]='fg=#63b07a'
    ZSH_HIGHLIGHT_STYLES[function]='fg=#63b07a'
    ZSH_HIGHLIGHT_STYLES[alias]='fg=#2dd5b7'
    ZSH_HIGHLIGHT_STYLES[precommand]='fg=#2dd5b7'
    ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#ff5345,bold'
    ZSH_HIGHLIGHT_STYLES[path]='fg=#c1c497,underline'
    ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#e5c736'
    ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#e5c736'
    ZSH_HIGHLIGHT_STYLES[redirection]='fg=#d2689c'
    # Default is black,bold - invisible on a near-black background.
    ZSH_HIGHLIGHT_STYLES[comment]='fg=#53685b'
fi

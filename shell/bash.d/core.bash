# Core portable Bash configuration.

_dotfiles_path_prepend() {
    local directory="${1-}"

    [[ -n "$directory" ]] || return 0

    case ":$PATH:" in
        *":$directory:"*) ;;
        *) PATH="$directory${PATH:+:$PATH}" ;;
    esac
}

_dotfiles_path_prepend "$HOME/bin"
_dotfiles_path_prepend "$HOME/.local/bin"
export PATH

if [[ -r /usr/share/fzf/key-bindings.bash ]]; then
    # shellcheck source=/dev/null
    source /usr/share/fzf/key-bindings.bash
fi

if [[ -r /usr/share/fzf/completion.bash ]]; then
    # shellcheck source=/dev/null
    source /usr/share/fzf/completion.bash
fi

if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init bash)"
fi

if command -v lazygit >/dev/null 2>&1; then
    alias lg='lazygit'
fi

if command -v lazydocker >/dev/null 2>&1; then
    alias ld='lazydocker'
fi

if command -v nvim >/dev/null 2>&1; then
    alias vim='nvim'

    nvim() {
        if [[ "${1-}" == "help" && -x "$HOME/bin/nvim-help" ]]; then
            "$HOME/bin/nvim-help"
            return
        fi

        command nvim "$@"
    }
fi

helpme() {
    local shortcuts="$HOME/.dotfiles/SHORTCUTS.md"

    if [[ ! -r "$shortcuts" ]]; then
        printf 'Shortcut belum tersedia: %s\n' "$shortcuts" >&2
        return 1
    fi

    if command -v less >/dev/null 2>&1; then
        less "$shortcuts"
    else
        cat "$shortcuts"
    fi
}

if command -v fastfetch >/dev/null 2>&1 \
    && [[ -z "${DOTFILES_NO_FASTFETCH:-}" ]]; then
    fastfetch
fi

# Default terminal editor
export EDITOR=nvim
export VISUAL=nvim

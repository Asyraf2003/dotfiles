# Development profile.

if [[ -d "$HOME/.npm-global/bin" ]]; then
    _dotfiles_path_prepend "$HOME/.npm-global/bin"
fi

if [[ -d "$HOME/.config/composer/vendor/bin" ]]; then
    _dotfiles_path_prepend "$HOME/.config/composer/vendor/bin"
fi

if command -v go >/dev/null 2>&1; then
    go_path="$(go env GOPATH 2>/dev/null || true)"

    if [[ -n "$go_path" ]]; then
        old_ifs="$IFS"
        IFS=':'
        read -r -a go_paths <<< "$go_path"
        IFS="$old_ifs"

        for path_entry in "${go_paths[@]}"; do
            [[ -n "$path_entry" ]] || continue
            _dotfiles_path_prepend "$path_entry/bin"
        done
    fi

    unset go_path go_paths old_ifs path_entry
fi

export PATH

if command -v dbeaver >/dev/null 2>&1; then
    alias pgui='dbeaver'
fi

if command -v psql >/dev/null 2>&1; then
    alias pgsql='sudo -iu postgres psql'
    alias pgstart='sudo systemctl start postgresql'
    alias pgstop='sudo systemctl stop postgresql'
    alias pgstatus='systemctl status postgresql --no-pager'
fi

#!/usr/bin/env bash

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
DOT="${DOT_COMMAND:-$DOTFILES_DIR/bin/dot}"

mode="--dry-run"
include_aur=0
profiles=()

usage() {
    cat <<'EOF'
Usage:
  ./bootstrap.sh [--dry-run|--apply] [--aur] [PROFILE...]

Default:
  dry-run core

No service is activated automatically.
EOF
}

while (( $# > 0 )); do
    case "$1" in
        --apply)
            mode="--apply"
            ;;
        --dry-run)
            mode="--dry-run"
            ;;
        --aur)
            include_aur=1
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        --*)
            printf 'BOOTSTRAP_OPTION_UNKNOWN=%s\n' "$1" >&2
            exit 64
            ;;
        *)
            profiles+=("$1")
            ;;
    esac

    shift
done

if (( ${#profiles[@]} == 0 )); then
    profiles=(core)
fi

if [[ ! -x "$DOT" ]]; then
    printf 'BOOTSTRAP_DOT_COMMAND=UNAVAILABLE path=%s\n' "$DOT" >&2
    exit 69
fi

"$DOT" doctor || exit $?

arguments=("$mode")

if (( include_aur == 1 )); then
    arguments+=(--aur)
fi

"$DOT" install "${arguments[@]}" "${profiles[@]}" ||
    exit $?

"$DOT" link "$mode" ||
    exit $?

if [[ "$mode" == "--apply" ]]; then
    printf 'BOOTSTRAP_MODE=APPLY\n'
else
    printf 'BOOTSTRAP_MODE=DRY_RUN\n'
fi

printf 'BOOTSTRAP_PROFILES=%s\n' \
    "$(printf '%s\n' "${profiles[@]}" | paste -sd, -)"

printf 'BOOTSTRAP_SERVICE_ACTION=NONE\n'
printf 'BOOTSTRAP=PASS\n'

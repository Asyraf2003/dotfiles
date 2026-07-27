# Display and media profile.

yt() {
    local url="${1-}"

    if ! command -v mpv >/dev/null 2>&1; then
        printf 'yt: mpv tidak tersedia.\n' >&2
        return 127
    fi

    if [[ -z "$url" && -n "${DISPLAY:-}" ]] \
        && command -v xclip >/dev/null 2>&1; then
        url="$(xclip -o -selection clipboard 2>/dev/null || true)"
    fi

    if [[ -z "$url" ]]; then
        printf 'Penggunaan: yt <URL>\n' >&2
        return 2
    fi

    if [[ ! "$url" =~ ^https?:// ]]; then
        printf 'yt: input bukan URL HTTP/HTTPS.\n' >&2
        return 2
    fi

    if [[ -n "${DISPLAY:-}" || -n "${WAYLAND_DISPLAY:-}" ]]; then
        mpv "$url"
    else
        mpv --vo=drm "$url"
    fi
}

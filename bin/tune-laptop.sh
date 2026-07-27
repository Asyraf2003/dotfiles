#!/usr/bin/env bash
set -Eeuo pipefail

readonly SCRIPT_NAME="${0##*/}"
readonly POWER_SERVICE="power-profiles-daemon.service"
readonly STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/tune-laptop"
readonly ROLLBACK_FILE="$STATE_DIR/previous-profile"
readonly -a KNOWN_PROFILES=(performance balanced power-saver)

usage() {
    cat <<USAGE
Usage: $SCRIPT_NAME [COMMAND]

Read-only commands:
  status       Show controller, service, profile, rollback, and battery status.
               This is the default when no command is supplied.

Explicit change commands:
  perf         Set profile to performance.
  balanced     Set profile to balanced.
  save         Set profile to power-saver.
  rollback     Restore the previously saved profile.

Other:
  -h, --help   Show this help and exit successfully.

Safety policy:
  - Profile changes use powerprofilesctl only.
  - No direct CPU sysfs writes are performed.
  - No battery threshold writes are performed.
  - No services are restarted.
USAGE
}

runtime_error() {
    printf 'ERROR=%s\n' "$*" >&2
    exit 1
}

invalid_argument() {
    printf 'ERROR=INVALID_ARGUMENT\n' >&2
    usage >&2
    exit 2
}

require_command() {
    local command_name="$1"

    command -v "$command_name" >/dev/null 2>&1 ||
        runtime_error "REQUIRED_COMMAND_MISSING:$command_name"
}

require_controller_tools() {
    require_command powerprofilesctl
    require_command rg
}

current_profile() {
    powerprofilesctl get 2>/dev/null
}

profiles_listing() {
    powerprofilesctl list 2>/dev/null
}

profile_available() {
    local wanted="$1"
    local listing

    listing="$(profiles_listing)" || return 1

    printf '%s\n' "$listing" |
        rg -q "^[[:space:]]*(\\*)?[[:space:]]*${wanted}:"
}

profile_is_known() {
    case "$1" in
        performance | balanced | power-saver)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

show_service_state() {
    if ! command -v systemctl >/dev/null 2>&1; then
        printf 'POWER_SERVICE_COMMAND=UNAVAILABLE\n'
        return 0
    fi

    printf 'POWER_SERVICE_LOAD=%s\n' \
        "$(systemctl show "$POWER_SERVICE" \
            --property=LoadState --value 2>/dev/null ||
            printf 'unknown')"

    printf 'POWER_SERVICE_ENABLED=%s\n' \
        "$(systemctl show "$POWER_SERVICE" \
            --property=UnitFileState --value 2>/dev/null ||
            printf 'unknown')"

    printf 'POWER_SERVICE_ACTIVE=%s\n' \
        "$(systemctl show "$POWER_SERVICE" \
            --property=ActiveState --value 2>/dev/null ||
            printf 'unknown')"

    printf 'POWER_SERVICE_SUB=%s\n' \
        "$(systemctl show "$POWER_SERVICE" \
            --property=SubState --value 2>/dev/null ||
            printf 'unknown')"
}

show_battery_threshold_status() {
    local -a threshold_paths=()

    shopt -s nullglob
    threshold_paths=(
        /sys/class/power_supply/BAT*/charge_control_end_threshold
    )
    shopt -u nullglob

    if ((${#threshold_paths[@]} == 0)); then
        printf 'BATTERY_THRESHOLD_STATUS=DEFERRED_HARDWARE_UNAVAILABLE\n'
        return 0
    fi

    printf 'BATTERY_THRESHOLD_STATUS=AVAILABLE_NOT_MANAGED\n'
    printf 'BATTERY_THRESHOLD_PATH=%s\n' "${threshold_paths[@]}"
}

show_status() {
    local current
    local profile

    printf 'ACTION=STATUS\n'
    printf 'POWER_PROFILE_CONTROLLER=power-profiles-daemon\n'
    printf 'DIRECT_CPU_SYSFS_WRITES=DISABLED\n'
    printf 'SERVICE_RESTARTS=DISABLED\n'

    show_service_state

    if ! command -v powerprofilesctl >/dev/null 2>&1; then
        printf 'POWERPROFILESCTL=UNAVAILABLE\n'
        show_battery_threshold_status
        return 1
    fi

    printf 'POWERPROFILESCTL=%s\n' "$(command -v powerprofilesctl)"

    if ! command -v rg >/dev/null 2>&1; then
        printf 'RG=UNAVAILABLE\n'
        show_battery_threshold_status
        return 1
    fi

    printf 'RG=%s\n' "$(command -v rg)"

    current="$(current_profile)" ||
        runtime_error 'CURRENT_PROFILE_READ_FAILED'

    printf 'CURRENT_POWER_PROFILE=%s\n' "$current"

    for profile in "${KNOWN_PROFILES[@]}"; do
        if profile_available "$profile"; then
            printf 'AVAILABLE_POWER_PROFILE=%s\n' "$profile"
        fi
    done

    if [[ -r "$ROLLBACK_FILE" ]]; then
        local saved_profile

        IFS= read -r saved_profile < "$ROLLBACK_FILE" || true

        if profile_is_known "$saved_profile"; then
            printf 'ROLLBACK_PROFILE_SAVED=%s\n' "$saved_profile"
        else
            printf 'ROLLBACK_PROFILE_SAVED=INVALID_STATE\n'
        fi
    else
        printf 'ROLLBACK_PROFILE_SAVED=NONE\n'
    fi

    show_battery_threshold_status
}

save_rollback_profile() {
    local profile="$1"
    local temporary_file

    profile_is_known "$profile" ||
        runtime_error "ROLLBACK_PROFILE_INVALID:$profile"

    install -d -m 700 -- "$STATE_DIR"

    temporary_file="$(mktemp "$STATE_DIR/.previous-profile.XXXXXX")"
    chmod 600 -- "$temporary_file"
    printf '%s\n' "$profile" > "$temporary_file"
    mv -f -- "$temporary_file" "$ROLLBACK_FILE"
}

restore_profile_after_failure() {
    local previous="$1"
    local observed=''

    printf 'AUTOMATIC_ROLLBACK_ATTEMPT=%s\n' "$previous" >&2

    if ! powerprofilesctl set "$previous"; then
        printf 'AUTOMATIC_ROLLBACK=FAILED_SET\n' >&2
        return 1
    fi

    observed="$(current_profile 2>/dev/null || true)"

    if [[ "$observed" != "$previous" ]]; then
        printf 'AUTOMATIC_ROLLBACK=FAILED_VERIFY:%s\n' \
            "${observed:-unreadable}" >&2
        return 1
    fi

    printf 'AUTOMATIC_ROLLBACK=PASS\n' >&2
}

set_mapped_profile() {
    local mode="$1"
    local target
    local previous
    local observed=''

    case "$mode" in
        perf)
            target='performance'
            ;;
        balanced)
            target='balanced'
            ;;
        save)
            target='power-saver'
            ;;
        *)
            invalid_argument
            ;;
    esac

    require_controller_tools

    profile_available "$target" ||
        runtime_error "TARGET_PROFILE_UNAVAILABLE:$target"

    previous="$(current_profile)" ||
        runtime_error 'CURRENT_PROFILE_READ_FAILED'

    profile_is_known "$previous" ||
        runtime_error "CURRENT_PROFILE_INVALID:$previous"

    printf 'ACTION=SET_PROFILE\n'
    printf 'REQUESTED_MODE=%s\n' "$mode"
    printf 'TARGET_POWER_PROFILE=%s\n' "$target"
    printf 'PREVIOUS_POWER_PROFILE=%s\n' "$previous"

    if [[ "$previous" == "$target" ]]; then
        printf 'PROFILE_CHANGE=NOOP_ALREADY_ACTIVE\n'
        show_battery_threshold_status
        return 0
    fi

    save_rollback_profile "$previous"
    printf 'ROLLBACK_PROFILE_SAVED=%s\n' "$previous"

    if ! powerprofilesctl set "$target"; then
        printf 'PROFILE_CHANGE=FAILED_SET\n' >&2
        restore_profile_after_failure "$previous" || true
        exit 1
    fi

    observed="$(current_profile 2>/dev/null || true)"

    if [[ "$observed" != "$target" ]]; then
        printf 'PROFILE_CHANGE=FAILED_VERIFY:%s\n' \
            "${observed:-unreadable}" >&2
        restore_profile_after_failure "$previous" || true
        exit 1
    fi

    printf 'CURRENT_POWER_PROFILE=%s\n' "$observed"
    printf 'PROFILE_CHANGE=PASS\n'
    show_battery_threshold_status
}

rollback_profile() {
    local target
    local previous
    local observed=''

    require_controller_tools

    [[ -r "$ROLLBACK_FILE" ]] ||
        runtime_error 'ROLLBACK_STATE_UNAVAILABLE'

    IFS= read -r target < "$ROLLBACK_FILE" ||
        runtime_error 'ROLLBACK_STATE_READ_FAILED'

    profile_is_known "$target" ||
        runtime_error "ROLLBACK_STATE_INVALID:$target"

    profile_available "$target" ||
        runtime_error "ROLLBACK_PROFILE_UNAVAILABLE:$target"

    previous="$(current_profile)" ||
        runtime_error 'CURRENT_PROFILE_READ_FAILED'

    profile_is_known "$previous" ||
        runtime_error "CURRENT_PROFILE_INVALID:$previous"

    printf 'ACTION=ROLLBACK_PROFILE\n'
    printf 'ROLLBACK_TARGET_PROFILE=%s\n' "$target"
    printf 'PREVIOUS_POWER_PROFILE=%s\n' "$previous"

    if [[ "$previous" == "$target" ]]; then
        printf 'PROFILE_ROLLBACK=NOOP_ALREADY_ACTIVE\n'
        show_battery_threshold_status
        return 0
    fi

    if ! powerprofilesctl set "$target"; then
        printf 'PROFILE_ROLLBACK=FAILED_SET\n' >&2
        restore_profile_after_failure "$previous" || true
        exit 1
    fi

    observed="$(current_profile 2>/dev/null || true)"

    if [[ "$observed" != "$target" ]]; then
        printf 'PROFILE_ROLLBACK=FAILED_VERIFY:%s\n' \
            "${observed:-unreadable}" >&2
        restore_profile_after_failure "$previous" || true
        exit 1
    fi

    save_rollback_profile "$previous"

    printf 'ROLLBACK_PROFILE_SAVED=%s\n' "$previous"
    printf 'CURRENT_POWER_PROFILE=%s\n' "$observed"
    printf 'PROFILE_ROLLBACK=PASS\n'

    show_battery_threshold_status
}

main() {
    if (($# > 1)); then
        invalid_argument
    fi

    case "${1:-status}" in
        status)
            show_status
            ;;
        perf | balanced | save)
            set_mapped_profile "$1"
            ;;
        rollback)
            rollback_profile
            ;;
        -h | --help)
            usage
            ;;
        *)
            invalid_argument
            ;;
    esac
}

main "$@"

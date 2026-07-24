#!/usr/bin/env bash
set -euo pipefail

# ASUS E1404F / Arch
# CPU: governor + amd-pstate-epp (EPP)
# Battery: /sys/class/power_supply/BAT0/charge_control_end_threshold
#
# Usage:
#   sudo tune-laptop.sh                 # interactive
#   sudo tune-laptop.sh --mode perf --bat 80
#   sudo tune-laptop.sh --mode save --bat 70
#   sudo tune-laptop.sh --status

BAT_END="/sys/class/power_supply/BAT0/charge_control_end_threshold"

die() { echo "❌ $*" >&2; exit 1; }
info(){ echo "ℹ️  $*"; }
ok()  { echo "✅ $*"; }

require_root() {
  [[ "${EUID}" -eq 0 ]] || die "Run as root: sudo $0"
}

usage() {
  cat <<'EOF'
tune-laptop.sh
  --mode perf|save        CPU mode (perf=performance, save=powersave)
  --bat 40|50|60|70|80|90|98   Battery end threshold (%)
  --status                Show status only
  -h, --help              Help

Examples:
  sudo tune-laptop.sh
  sudo tune-laptop.sh --mode perf --bat 80
  sudo tune-laptop.sh --mode save --bat 70
  sudo tune-laptop.sh --status
EOF
}

CPU_GOV=""
EPP=""
BAT_LIMIT=""
STATUS_ONLY=0

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --mode)
        [[ $# -ge 2 ]] || die "--mode needs value"
        case "$2" in
          perf) CPU_GOV="performance"; EPP="performance" ;;
          save) CPU_GOV="powersave";   EPP="power" ;;
          *) die "Invalid --mode. Use perf|save" ;;
        esac
        shift 2
        ;;
      --bat)
        [[ $# -ge 2 ]] || die "--bat needs value"
        case "$2" in
          40|50|60|70|80|90|98) BAT_LIMIT="$2" ;;
          *) die "Invalid --bat. Allowed: 40 50 60 70 80 90 98" ;;
        esac
        shift 2
        ;;
      --status)
        STATUS_ONLY=1
        shift
        ;;
      -h|--help)
        usage; exit 0
        ;;
      *)
        die "Unknown arg: $1 (use --help)"
        ;;
    esac
  done
}

ask_cpu_mode() {
  echo "CPU mode?"
  echo "  A) performance (max responsiveness, higher power)"
  echo "  B) powersave   (lower power, slower ramp)"
  read -r -p "Choose [A/B]: " c
  c="$(echo "$c" | tr '[:upper:]' '[:lower:]')"
  case "$c" in
    a) CPU_GOV="performance"; EPP="performance" ;;
    b) CPU_GOV="powersave";   EPP="power" ;;
    *) die "Invalid choice. Use A or B." ;;
  esac
}

ask_battery_limit() {
  echo "Battery end threshold?"
  echo "  Options: 40 50 60 70 80 90 98"
  read -r -p "Choose: " v
  case "$v" in
    40|50|60|70|80|90|98) BAT_LIMIT="$v" ;;
    *) die "Invalid value. Allowed: 40 50 60 70 80 90 98" ;;
  esac
}

apply_cpu_governor() {
  info "Setting governor: ${CPU_GOV}"
  local any=0
  for f in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
    [[ -f "$f" ]] || continue
    echo "${CPU_GOV}" > "$f"
    any=1
  done
  [[ "$any" -eq 1 ]] || die "No scaling_governor exposed."
  ok "Governor applied."
}

apply_epp() {
  info "Setting EPP: ${EPP}"
  local any=0
  for f in /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference; do
    [[ -f "$f" ]] || continue
    echo "${EPP}" > "$f"
    any=1
  done
  [[ "$any" -eq 1 ]] || die "EPP sysfs not found (amd-pstate-epp missing?)."
  ok "EPP applied."
}

apply_battery_threshold() {
  [[ -f "$BAT_END" ]] || die "Battery threshold node not found: ${BAT_END}"
  [[ -w "$BAT_END" ]] || die "Battery threshold node not writable: ${BAT_END}"

  info "Setting battery end threshold: ${BAT_LIMIT}%"
  echo "${BAT_LIMIT}" > "$BAT_END"
  ok "Battery threshold applied."
}

reload_services_best_effort() {
  info "Reloading services (best-effort)..."
  systemctl restart cpupower.service 2>/dev/null || true
  systemctl restart tlp.service 2>/dev/null || true
  systemctl restart power-profiles-daemon.service 2>/dev/null || true
  ok "Reload attempted."
}

status() {
  echo
  info "STATUS"
  echo -n "  driver:   "; cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_driver 2>/dev/null || echo "N/A"
  echo -n "  governor: "; cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || echo "N/A"
  echo -n "  epp:      "; cat /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference 2>/dev/null || echo "N/A"
  echo -n "  bat_end:  "; cat "$BAT_END" 2>/dev/null || echo "N/A"
  echo
}

main() {
  parse_args "$@"

  if [[ "$STATUS_ONLY" -eq 1 ]]; then
    status
    exit 0
  fi

  require_root

  # If not provided via args, go interactive
  [[ -n "${CPU_GOV}" && -n "${EPP}" ]] || ask_cpu_mode
  [[ -n "${BAT_LIMIT}" ]] || ask_battery_limit

  echo
  apply_cpu_governor
  apply_epp
  apply_battery_threshold
  reload_services_best_effort
  status
  ok "Done."
}

main "$@"

#!/bin/bash
# ============================================================
#  PiAccess — Network Watcher
#  Runs as a systemd service (pa-netwatcher.service).
#  Checks every 10s if client mode is still connected.
#  If not, brings the AP back up automatically.
# ============================================================

STATE_FILE="/root/.piaccess/ap_state"
HOSTAPD_CONF="/root/.piaccess/hostapd.conf"
DNSMASQ_CONF="/root/.piaccess/dnsmasq.conf"
CHECK_INTERVAL=10  # seconds between checks

log() { echo "[$(date '+%H:%M:%S')] netwatcher: $1"; }

start_ap() {
    source "$STATE_FILE"
    log "Starting AP: ${AP_SSID}"

    pkill hostapd        2>/dev/null || true
    pkill dnsmasq        2>/dev/null || true
    pkill wpa_supplicant 2>/dev/null || true
    sleep 1

    ip link set "$AP_IFACE" up
    ip addr flush dev "$AP_IFACE"
    ip addr add "$AP_IP/24" dev "$AP_IFACE"
    echo 1 > /proc/sys/net/ipv4/ip_forward

    if hostapd "$HOSTAPD_CONF" -B 2>/dev/null; then
        sleep 1
        dnsmasq --conf-file="$DNSMASQ_CONF" 2>/dev/null
        # Update mode in state file
        sed -i "s/^PA_MODE=.*/PA_MODE=ap/" "$STATE_FILE" 2>/dev/null || true
        log "AP is live"
    else
        log "ERROR: hostapd failed to start"
    fi
}

is_client_connected() {
    SSID=$(iwgetid -r 2>/dev/null)
    [ -n "$SSID" ]
}

ap_is_running() {
    pgrep hostapd > /dev/null 2>&1
}

# ── Main loop ─────────────────────────────────────────────────
log "Started"

while true; do
    sleep "$CHECK_INTERVAL"

    # If AP is already running, nothing to do
    if ap_is_running; then
        continue
    fi

    # AP is not running — we're in client mode
    # Check if still connected
    if ! is_client_connected; then
        log "Connection lost — restoring AP"
        start_ap
    fi
done

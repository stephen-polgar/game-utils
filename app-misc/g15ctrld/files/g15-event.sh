#!/bin/sh

READY_FILE="/run/g15-ready"

log() {
    logger -t g15-script "G15 $1"
}

get_init_system() {
    if [ "$(ps -p 1 -o comm= | tr -d ' ')" = "systemd" ]; then
        echo systemd
    elif command -v rc-service >/dev/null 2>&1 && command -v rc-status >/dev/null 2>&1; then
        echo openrc
    else
        echo unknown
    fi
}

start_g15() {
    case "$INIT_SYSTEM" in
        systemd)
            systemctl start ydotool
            systemctl start LCDd
            systemctl start lcdproc
           # systemctl start lcdexec
            systemctl start g15ctrld
            ;;
        openrc)
            rc-service ydotool start
            rc-service LCDd start
            rc-service lcdproc start
           # rc-service lcdexec start
            rc-service g15ctrld start
            ;;
        *)
            return 1
            ;;
    esac
}

stop_g15() {
    case "$INIT_SYSTEM" in
        systemd)
            systemctl stop g15ctrld
            systemctl stop ydotool
            systemctl stop lcdproc
           # systemctl stop lcdexec
            systemctl stop LCDd
            ;;
        openrc)
            rc-service g15ctrld stop
            rc-service ydotool stop
            rc-service lcdproc stop
           # rc-service lcdexec stop
            rc-service LCDd stop
            ;;
        *)
            return 1
            ;;
    esac
}

INIT_SYSTEM="$(get_init_system)"

if [ "$INIT_SYSTEM" = "unknown" ]; then
    log "Unknown init system"
    exit 1
fi

RESULT=0

case "$1" in
    plugged)
        log "connected"
        if [ -f "$READY_FILE" ]; then
            log "started by dbus"
            start_g15
            RESULT=$?
        else
            touch "$READY_FILE"
        fi
        ;;
    unplugged)
        stop_g15
        RESULT=$?
        log "stopped by dbus"
        ;;
    ready)
        if [ -f "$READY_FILE" ]; then
            log "started by g15-autorun"
            start_g15
            RESULT=$?
        else
            touch "$READY_FILE"
        fi
        ;;
    *)
        echo "Usage: $0 {plugged|unplugged|ready}" >&2
        RESULT=1
        ;;
esac

exit "$RESULT"

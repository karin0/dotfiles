alias spsyu="apt update && apt upgrade"

sv-status() {
    sv status "$1"
    tail -n 15 -f "$PREFIX/var/log/sv/$1/current"
}

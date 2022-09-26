#!/bin/bash

if [ "$USER" = root ] || [ -v TERMUX_VERSION ] || ! in_path sudo ; then
  KRR_SUDO=''
else
  KRR_SUDO='sudo'
fi

_pkg_entry() {
  if [ -z "$2" ]; then
    eval "$KRR_SYU"
  else
    $KRR_SUDO "$@"
  fi
}

if in_path pacman; then
  _pacman_autoremove() {
    local s
    if s="$(pacman -Qdtq)" && [ -n "$s" ]; then
      $KRR_SUDO pacman -Rs "$s"
    fi
  }
  KRR_SYU="$KRR_SUDO pacman -Syu && _pacman_autoremove"
  alias pac="_pkg_entry pacman"
  alias add="$KRR_SUDO pacman -S --needed"
  alias autoremove="$KRR_SUDO pacman -Rs \$(pacman -Qdtq)"
elif in_path apt; then
  KRR_SYU="$KRR_SUDO apt update && $KRR_SUDO apt upgrade && $KRR_SUDO apt autoremove"
  alias apt="_pkg_entry apt"
  alias pac="_pkg_entry apt"
  alias add="$KRR_SUDO apt install"
  alias autoremove="$KRR_SUDO apt autoremove"
elif in_path apk; then
  KRR_SYU="$KRR_SUDO apk -U upgrade"
  alias apk="_pkg_entry apt"
  alias pac="_pkg_entry apt"
  alias add="$KRR_SUDO apk add"
else
  unset -f _pkg_entry
fi

if in_path exa; then
  alias ls='exa -a --icons'
  alias ll='exa -alF --git --time-style iso --icons'
else
  alias ls='ls --color=auto -aF'
  alias ll='ls --color=auto -alhF'
fi

in_path trash && alias rm='trash-put -v'

in_path proxychains4 && alias pc=proxychains4

in_path bat && alias cat=bat

# alias ls='lsd -A'
# alias ll='lsd -Al --date "+%F %T"'

BASE16_SHELL="$HOME/clones/base16-shell/"
[ -n "$PS1" ] && \
    [ -s "$BASE16_SHELL/profile_helper.sh" ] && \
        eval "$("$BASE16_SHELL/profile_helper.sh")"

if in_path systemctl; then
  alias sutl='systemctl --user'
  alias jutl='journalctl --user'
  alias sctl=systemctl
  alias jctl=journalctl
fi

_nohup_entry() {
  nohup "$@" >/dev/null 2>&1 & disown
}

in_path clion && alias clion='_nohup_entry clion'
in_path pycharm && alias pycharm='_nohup_entry pycharm'
in_path webstorm && alias webstorm='_nohup_entry webstorm'

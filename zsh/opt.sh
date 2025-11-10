#!/bin/bash

pac() {
  if [ -z "$1" ]; then
    eval "$KRR_SYU"
  else
    $KRR_SUDO "$KRR_PKG" "$@"
  fi
}

if in_path pacman; then
  _pacman_autoremove() {
    local s
    if s="$(pacman -Qdtq)" && [ -n "$s" ]; then
      echo "$s" | $KRR_SUDO pacman -Rs -
    fi
  }
  KRR_PKG=pacman
  if in_path paru; then
    KRR_SYU="$KRR_PX paru -Syu --skipreview && _pacman_autoremove"
    alias paclean="yes | $KRR_PX paru -Scc"
  else
    KRR_SYU="$KRR_SUDO pacman -Syu && _pacman_autoremove"
    alias paclean="yes | $KRR_SUDO pacman -Scc"
  fi
  alias add="$KRR_SUDO pacman -S --needed"
  alias autoremove="$KRR_SUDO pacman -Rs \$(pacman -Qdtq)"
elif in_path apt; then
  KRR_PKG=apt
  KRR_SYU="$KRR_SUDO apt update && $KRR_SUDO apt upgrade && $KRR_SUDO apt autoremove --purge"
  alias add="$KRR_SUDO apt install"
  alias autoremove="$KRR_SUDO apt autoremove --purge"
  alias paclean="$KRR_SUDO apt clean"
elif in_path apk; then
  KRR_PKG=apk
  KRR_SYU="$KRR_SUDO apk -U upgrade"
  alias add="$KRR_SUDO apk add"
elif in_path nix; then
  KRR_SYU=/etc/nixos/update
fi

if in_path eza; then
  alias ls='eza -aF --icons auto'
  alias ll='ls -l --git --time-style iso'
else
  alias ls='ls --color=auto -AF'
  alias ll='ls -hl'
fi
alias lt='command ls -lAhtrF --color=auto'

in_path trash && alias rm='trash-put -v'
in_path proxychains4 && alias pc=proxychains4
in_path bat && alias cat=bat

if [ "$OSTYPE" = linux-gnu ]; then
  if in_path systemctl; then
    alias sutl='systemctl --user'
    alias jutl='journalctl --user'
    alias sctl="$KRR_SUDO systemctl"
    alias jctl="$KRR_SUDO journalctl"
    alias scs='sctl status'
    alias sus='sutl status'
    sur() { systemctl --user start "$1" & journalctl --user -f; }
  fi

  _nohup_entry() {
    nohup "$@" >/dev/null 2>&1 & disown
  }

  in_path clion && alias clion='_nohup_entry clion'
  in_path pycharm && alias pycharm='_nohup_entry pycharm'
  in_path webstorm && alias webstorm='_nohup_entry webstorm'
  in_path netease-cloud-music && alias ncm='_nohup_entry netease-cloud-music --force-device-scale-factor=2'

  _chrome_entry() {
    _nohup_entry "$@" --proxy-server=socks5://127.0.0.1:10807
  }

  in_path cider && alias cider='_chrome_entry cider'
  in_path todoist && alias todoist='_chrome_entry todoist'
fi

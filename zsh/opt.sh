#!/bin/bash

if [ "$USER" = root ] || [ -v TERMUX_VERSION ] || ! in_path sudo ; then
  KRR_SUDO=''
else
  KRR_SUDO='sudo'
fi

if in_path pacman; then
  alias syu="$KRR_SUDO pacman -Syu"
  alias autoremove="$KRR_SUDO pacman -Rs $(pacman -Qdtq)"
elif in_path apt; then
  alias syu="$KRR_SUDO apt update && $KRR_SUDO apt upgrade"
  alias autoremove="$KRR_SUDO apt autoremove"
fi

unset KRR_SUDO

if in_path exa; then
  alias ls='exa -a --icons'
  alias ll='exa -al --git --time-style iso --icons'
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
  alias systemutl='systemctl --user'
  alias journalutl='journalctl --user'
fi

#!/bin/bash

if pacman -V >/dev/null 2>&1; then
  alias syu='sudo pacman -Syu'
  alias autoremove='sudo pacman -Rs $(pacman -Qdtq)'
elif apt -v >/dev/null 2>&1; then
  # sudo is neither necessary nor available in Termux
  if sudo -V >/dev/null 2>&1; then
    SUDO='sudo'
  else
    SUDO=''
  fi
  alias syu="$SUDO apt update && $SUDO apt upgrade"
  alias autoremove="$SUDO apt autoremove"
fi

if exa -v >/dev/null 2>&1; then
  alias ls='exa -a --icons'
  alias ll='exa -al --git --time-style iso --icons'
fi

if trash --version >/dev/null 2>&1; then
  alias rm='trash-put -v'
fi

if proxychains4 true >/dev/null 2>&1; then
  alias pc=proxychains4
fi

if bat -V >/dev/null 2>&1; then
  alias cat=bat
fi

# alias ls='lsd -A'
# alias ll='lsd -Al --date "+%F %T"'

BASE16_SHELL="$HOME/clones/base16-shell/"
[ -n "$PS1" ] && \
    [ -s "$BASE16_SHELL/profile_helper.sh" ] && \
        eval "$("$BASE16_SHELL/profile_helper.sh")"

if zoxide -V >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

if starship --version >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

if systemctl --version >/dev/null 2>&1; then
  alias systemutl='systemctl --user'
  alias journalutl='journalctl --user'
fi


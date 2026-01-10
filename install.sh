#!/usr/bin/env bash
set -e
HERE="$(dirname "$(realpath "$0")")"
cd "$HERE"
. ./utils.bash

in_path zsh && add zsh/zshrc.zsh ~/.zshrc
in_path vim && add home/.vimrc ~/.vimrc
in_path termux-wake-lock && add home/.termux ~/.termux

if in_path byobu; then
  mkdir -p ~/.byobu
  add home/.byobu/.tmux.conf ~/.byobu/.tmux.conf
fi

if [ -f ~/dotsecrets/install.sh ]; then
  HERE=~/dotsecrets
  cd "$HERE"
  . ./install.sh
fi

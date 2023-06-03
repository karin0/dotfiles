#!/bin/bash
set -e
HERE="$(dirname "$(realpath "$0")")"
cd "$HERE"
. ./utils.bash

in_path zsh && add zsh/zshrc.zsh ~/.zshrc
in_path vim && add home/.vimrc ~/.vimrc
in_path tmux && add home/.tmux.conf ~/.tmux.conf
in_path termux-wake-lock && add home/.termux ~/.termux

if [ -f ~/dotsecrets/install.sh ]; then
  HERE=~/dotsecrets
  cd "$HERE"
  . ./install.sh
fi

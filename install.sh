#!/bin/bash
set -e
HERE="$(dirname "$(realpath "$0")")"
cd "$HERE"
. ./utils.bash

in_path zsh && add zsh/zshrc.zsh ~/.zshrc
in_path vim && add vim/vimrc ~/.vimrc
in_path tmux && add tmux/tmux.conf ~/.tmux.conf

if [ -f ~/dotsecrets/install.sh ]; then
  HERE=~/dotsecrets
  cd "$HERE"
  . ./install.sh
fi

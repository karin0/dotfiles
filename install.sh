#!/bin/bash
set -e
HERE="$(dirname "$(realpath "$0")")"
cd "$HERE"
. ./utils.bash

in_path zsh && add zsh/zshrc.zsh ~/.zshrc
in_path vim && add vim/vimrc ~/.vimrc

if [ -f ~/dotsecrets/install.sh ]; then
  HERE=~/dotsecrets
  . ~/dotsecrets/install.sh
fi

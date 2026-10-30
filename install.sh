#!/usr/bin/env bash
set -e
HERE="$(dirname "$(realpath "$0")")"
cd "$HERE"
. ./utils.bash

in_path zsh && add zsh/zshrc.zsh ~/.zshrc && add zsh/zshenv.zsh ~/.zshenv
in_path vim && add home/.vimrc ~/.vimrc

if in_path termux-wake-lock; then
  mkdir -p ~/.termux
  for f in home/.termux/*; do
    add "$f" ~/.termux
  done
  # Termux ignores a termux.properties that is a symlink, so the link is its parent directory at
  # the secondary location.
  mkdir -p ~/.config
  add home/.config/termux ~/.config/termux
fi

if in_path byobu; then
  mkdir -p ~/.byobu
  add home/.byobu/.tmux.conf ~/.byobu/.tmux.conf
fi

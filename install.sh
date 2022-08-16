#!/bin/bash

set -e

HERE="$(dirname "$(realpath "$0")")"

add() {
  source="$HERE/$1"
  file="$2"
  if [ -e "$file" ]; then
    if [ "$file" -ef "$source" ]; then
      echo "$file is already installed."
      return
    fi
    size=$(stat -c%s -- "$file")
    if [ "$size" -eq 0 ]; then
      rm -- "$file"
    else
      echo "$file ($size B) already exists, skipping."
      return
    fi
  fi
  ln -s "$source" -- "$file"
}

zsh --version && add zsh/.zshrc ~/.zshrc

if s=$(vim --version); then
  echo "$s" | head -n1
  add vim/vimrc ~/.vimrc
fi

[ -f ~/dotsecrets/install.sh ] && . ~/dotsecrets/install.sh

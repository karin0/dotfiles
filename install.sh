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
  echo "Installed $file."
}

in_path() {
  type -P "$@"
}

in_path zsh && add zsh/.zshrc ~/.zshrc
in_path vim && add vim/vimrc ~/.vimrc
in_path fish && add fish/config.fish ~/.config/fish/config.fish

if [ -f ~/dotsecrets/install.sh ]; then
  HERE=~/dotsecrets
  . ~/dotsecrets/install.sh
fi

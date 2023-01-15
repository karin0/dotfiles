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
    if ! [ -s "$file" ]; then
      rm -- "$file"
    else
      echo "$file already exists, skipping."
      return
    fi
  fi
  ln -s "$source" -- "$file"
  echo "Installed $file."
}

in_path() {
  type -P "$@"
}

in_path zsh && add zsh/zshrc.zsh ~/.zshrc
in_path vim && add vim/vimrc ~/.vimrc

if [ -f ~/dotsecrets/install.sh ]; then
  HERE=~/dotsecrets
  . ~/dotsecrets/install.sh
fi

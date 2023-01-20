#!/bin/bash
ADD_SUDO=
ADD_LN='ln -sv'

add() {
  src="$1"
  dst="$2"
  if [ -d "$dst" ]; then
    dst="$dst/$(basename "$src")"
  fi
  if [ -e "$dst" ]; then
    if [ "$dst" -ef "$src" ]; then
      echo "$dst is already installed."
      return
    fi
    if ! [ -s "$dst" ]; then
      $ADD_SUDO rm -vf -- "$dst"
    else
      echo "$dst already exists!"
      return 1
    fi
  fi
  $ADD_SUDO $ADD_LN "$(realpath "$src")" -- "$dst"
}

in_path() {
  type -P "$@"
}

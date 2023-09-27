#!/bin/bash
set -e

dst=~/.config/autostart/gnome-keyring-ssh.desktop

if [ -f "$dst" ]; then
  echo "$dst already exists, not overwriting"
else
  mkdir -p ~/.config/autostart/
  cp /etc/xdg/autostart/gnome-keyring-ssh.desktop ~/.config/autostart/
  echo Hidden=true >> $dst
fi

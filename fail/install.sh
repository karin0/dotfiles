#!/bin/bash
set -e
. ../utils.bash

dir=~/.config/systemd/user/service.d
mkdir -p $dir
add fail.conf $dir/fail.conf
systemctl --user daemon-reload

if ! [ -d /opt/dotfiles ]; then
  sudo mkdir /opt/dotfiles
  sudo chown -R "$USER:$USER" /opt/dotfiles
fi
cp -v post-stop /opt/dotfiles/

dir=/etc/systemd/system/service.d
sudo mkdir -p $dir

ADD_SUDO=sudo
ADD_LN='cp -nv'
add fail.conf $dir/fail.conf

sudo systemctl daemon-reload

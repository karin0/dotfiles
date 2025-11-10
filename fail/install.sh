#!/bin/bash
set -e
. ../utils.bash

if ! [ -d /opt/dotfiles ]; then
  echo "Creating /opt/dotfiles ..."
  sudo mkdir /opt/dotfiles
  sudo chown -R "$USER:$USER" /opt/dotfiles
fi

if ! [ -x /opt/dotfiles/kpush ]; then
  echo "Please prepare /opt/dotfiles/kpush!"
  exit 1
fi

dir=~/.config/systemd/user/service.d
mkdir -p $dir
add fail.conf $dir/fail.conf
systemctl --user daemon-reload

cp -v post-stop /opt/dotfiles/

dir=/etc/systemd/system/service.d
sudo mkdir -p $dir

ADD_SUDO=sudo
ADD_LN='cp -nv'
add fail.conf $dir/fail.conf
sudo systemctl daemon-reload

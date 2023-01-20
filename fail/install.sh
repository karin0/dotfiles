#!/bin/bash
set -e
. ../utils.bash

dir=~/.config/systemd/user/service.d
mkdir -p $dir
add fail.conf $dir/fail.conf
systemctl --user daemon-reload

dir=/etc/systemd/system/service.d
sudo mkdir -p $dir /opt/dotfiles
sudo cp -v post-stop ~/bin/kpush /opt/dotfiles/

ADD_SUDO=sudo
ADD_LN='cp -nv'
add sys-fail.conf $dir/sys-fail.conf

sudo systemctl daemon-reload

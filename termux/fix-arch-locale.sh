#!/bin/bash
# Write mirrorlist, run this after ./setupTermuxArch in proot, and relogin.

# pacman -Rsc linux-aarch64

sed -i 's/zh_Hans_CN.UTF-8/zh_CN.UTF-8/g' /etc/locale.conf
sed -i 's/#zh_CN.UTF-8/zh_CN.UTF-8/g' /etc/locale.gen
locale-gen

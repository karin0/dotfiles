#!/bin/bash
# Use after ./setupTermuxArch in proot

sed -i 's/zh_Hans_CN.UTF-8/zh_CN.UTF-8/g' /etc/locale.conf

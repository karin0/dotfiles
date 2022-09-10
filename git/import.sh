#!/bin/bash
set -e

# https://stackoverflow.com/questions/55249773
cat gitconfig |
while read line; do
  git config --global \
    "`echo $line | sed 's/=.\+//'`" \
    "`echo $line | sed 's/^.\+=//'`"
done

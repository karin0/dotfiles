#!/bin/bash
set -e

while read -r line; do
  git config --global "${line/%=?*/}" "${line/#?*=/}"
done < gitconfig

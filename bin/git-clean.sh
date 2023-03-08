#!/bin/bash

set -e

# https://stackoverflow.com/a/33548037/20490060
git fetch -p
f=$(mktemp)
trap 'rm -v "$f"' EXIT

git for-each-ref --format '%(refname) %(upstream:track)' refs/heads \
  | awk '$2 == "[gone]" {sub("refs/heads/", "", $1); print $1}' > "$f"

if [ -s "$f" ]; then
  "${EDITOR:-vi}" "$f"
  while read -r br; do
    git branch -d "$br" || true
  done < "$f"
fi

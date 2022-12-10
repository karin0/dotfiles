#!/bin/bash

err() {
  echo "$1: $2"
  [ -n "$f" ] && rm -v "$f"
  exit "$2"
}

# https://stackoverflow.com/a/33548037/20490060
git fetch -p || err fetch $?
f=$(mktemp) || err mktemp $?

git for-each-ref --format '%(refname) %(upstream:track)' refs/heads \
  | awk '$2 == "[gone]" {sub("refs/heads/", "", $1); print $1}' > "$f" \
  || err awk $?

if [ -s "$f" ]; then
  ed="${EDITOR:-vi}"
  "$ed" "$f" || err "$ed" $?
  while read -r branch; do
    git branch -D "$branch" || echo "$branch: $?" >&2
  done < "$f"
fi

rm -v "$f"

#!/bin/bash
# Yet another `git-revise` with `--committer-date-is-author-date` and `-S`.
set -e

target="$1"
if [ -z "$target" ]; then
  echo "Usage: $0 <commit>"
  exit 1
fi

git commit --fixup "$target"

r=0
GIT_SEQUENCE_EDITOR=: git rebase -i "$target^" \
  --autosquash \
  --autostash \
  --committer-date-is-author-date \
  -S || r=$?

if [ $r -ne 0 ] ; then
  set -x
  git rebase --abort
  git reset --soft HEAD^
  exit $r
fi

#!/bin/bash
# Yet another `git-revise` with `--committer-date-is-author-date` and `-S`.
set -eo pipefail

if [ -z "$1" ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
  echo "Usage: $0 <commit>"
  exit 1
fi

# Resolve the target first so symbolic refs like HEAD or branches
# don't change meaning after we create the fixup commit.
target=$(git rev-parse --verify "$1")

git commit --fixup "$target"

# Use --root if necessary.
if git rev-parse --verify "$target^" >/dev/null 2>&1; then
  upstream="$target^"
else
  upstream="--root"
fi

r=0
GIT_SEQUENCE_EDITOR=: git rebase -i "$upstream" \
  --autosquash \
  --autostash \
  --committer-date-is-author-date \
  -S || r=$?

if [ $r -ne 0 ] ; then
  set -x
  git rebase --abort || true
  git reset --soft HEAD^
  exit $r
fi

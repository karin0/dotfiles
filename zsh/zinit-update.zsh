#!/usr/bin/env zsh
# Updates zinit, which update --all starts with, and the plugins and snippets it has installed.
# The changelogs print without a pager.

source ~/.local/share/zinit/zinit.git/zinit.zsh &&
  ZINIT[NO_PAGER]=1 &&
  zinit update --all -q -p

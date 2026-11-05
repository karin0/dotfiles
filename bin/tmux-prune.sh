#!/bin/bash
# Kill every detached tmux session whose panes all hold a shell with no child process, so a
# session running any program, even in the background, survives.

set -eu

tmux list-sessions -F '#{session_name}' -f '#{==:#{session_attached},0}' |
  while IFS= read -r session; do
    idle=1
    while read -r pid; do
      case $(ps -o comm= -p "$pid") in
        bash | zsh | sh | fish) ;;
        *) idle=0 ;;
      esac
      if [ -n "$(ps -o pid= --ppid "$pid")" ]; then
        idle=0
      fi
    done < <(tmux list-panes -s -t "=$session" -F '#{pane_pid}')
    if [ "$idle" = 1 ]; then
      echo "$session"
      tmux kill-session -t "=$session"
    fi
  done

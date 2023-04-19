#!/bin/bash

alias cp='cp -iv'
alias mv='mv -iv'
alias ip='ip -c'

px_vars="$(eval echo {HTTP,HTTPS,ALL}_PROXY='\$KRR_PROXY' {http,https,all}_proxy='\$KRR_PROXY' {NO_PROXY,no_proxy}=\''localhost,127.0.0.1,10.0.0.*'\')"
alias px="$px_vars"
alias epx='[ -n "$KRR_PROXY" ] && export '"$px_vars"
alias unepx='unset {HTTP,HTTPS,ALL,NO}_PROXY {http,https,all,no}_proxy'
unset px_vars

alias mnt2="$KRR_SUDO"' mount -t ntfs3 -o ro,uid=$UID,gid=$GID'
alias mnt3="$KRR_SUDO"' mount -t ntfs3 -o rw,uid=$UID,gid=$GID'

alias gc='git commit'
alias gcm='git commit -m'
alias gcam='git commit -am'
alias gs='git status'
alias gsw='git switch'
alias gd='git diff'
alias ga='git add'

reload() {
  KRR_RELOAD=1 exec ${1:-zsh}
}

alias reload='reload "${0#-}"'

pwd() {
	if [ -n "$1" ] && [[ "$1" != -* ]]; then
		realpath "$@"
	else
		command pwd "$@"
	fi
}

mkcd () {
  mkdir -p -- "$1" && \
  cd -P -- "$1"
}

sva() {
	local base="${1:-.}"
	if [ -x "$base/bin/python" ]; then
		. "$base/bin/activate"
	elif [ -x "$base/venv/bin/python" ]; then
		. "$base/venv/bin/activate"
	elif [ -x "$base/.vent/bin/python" ]; then
		. "$base/.vent/bin/activate"
	else
		return 1
	fi
}

pycclean() {
	find . -regex '^.*\(__pycache__\|\.py[co]\)$' -o -name .git -prune -name venv -prune -name .vent -prune
}

disable-xinput-dev() {
  local s="$1"
  if [ -z "$s" ]; then
    echo "Usage: disable-xinput-dev <device name>"
    return 1
  fi
  local id
  if ! id=$(xinput list | sed -n 's/.*'"$1"'.*id=\([0-9][0-9]*\).*/\1/p'); then
    return $?
  fi
  if [ -z "$id" ]; then
    echo "$s is not found"
    return 2
  fi
  xinput disable "$id" && echo "Disabled $id"
}

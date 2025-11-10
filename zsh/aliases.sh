#!/bin/bash

alias cp='cp -iv'
alias mv='mv -iv'
alias ip='ip -c'

if [ -n "$KRR_PROXY" ]; then
  px_vars="$(eval echo {HTTP,HTTPS,ALL}_PROXY='\$KRR_PROXY' {http,https,all}_proxy='\$KRR_PROXY' {NO_PROXY,no_proxy}=\''localhost,127.0.0.1,10.0.0.*,192.168.*.*,terabyte.cc,dl.google.com'\')"
  alias px="$px_vars"
  alias epx='[ -n "$KRR_PROXY" ] && export '"$px_vars"
  alias unepx='unset {HTTP,HTTPS,ALL,NO}_PROXY {http,https,all,no}_proxy'
  KRR_PX=px
  unset px_vars
else
  unset KRR_PROXY
fi

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
  for d in '' venv .venv .vent; do
    if [ -x "$base/$d/bin/python" ]; then
      echo "$base/$d"
      . "$base/$d/bin/activate"
      return
    fi
  done
  return 1
}

pycclean() {
	find . -regex '^.*\(__pycache__\|\.py[co]\)$' -o -name .git -prune -name venv -prune -name .vent -prune
}

. "$HERE"/opt.sh

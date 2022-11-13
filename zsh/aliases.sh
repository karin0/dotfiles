#!/bin/bash

alias cp='cp -iv'
alias mv='mv -iv'

alias lt='ls -lAhtr'

alias px='HTTP_PROXY=$KRR_PROXY HTTPS_PROXY=$KRR_PROXY ALL_PROXY=$KRR_PROXY'
alias epx='[ -n "$KRR_PROXY" ] && export HTTP_PROXY=$KRR_PROXY HTTPS_PROXY=$KRR_PROXY ALL_PROXY=$KRR_PROXY'
alias unepx='unset HTTP_PROXY HTTPS_PROXY ALL_PROXY'

alias gcm='git commit -m'
alias gcam='git commit -am'
alias gs='git status'
alias gd='git diff'
alias ga='git add'
# alias gaa='git status && read && git add .'

alias mnt2="$KRR_SUDO"' mount -t ntfs3 -o ro,uid=$UID,gid=$GID'
alias mnt3="$KRR_SUDO"' mount -t ntfs3 -o rw,uid=$UID,gid=$GID'

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

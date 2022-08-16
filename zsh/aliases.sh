#!/bin/bash

alias cp='cp -iv'
alias mv='mv -iv'

alias lt='ls -lAhtr'

PROXY=http://127.0.0.1:10807

alias px="HTTP_PROXY=$PROXY HTTPS_PROXY=$PROXY ALL_PROXY=$PROXY"
alias epx="export HTTP_PROXY=$PROXY HTTPS_PROXY=$PROXY ALL_PROXY=$PROXY"
alias unepx='unset HTTP_PROXY HTTPS_PROXY ALL_PROXY'

alias gcm='git commit -m'
alias gcam='git commit -am'
alias gs='git status'
alias gd='git diff'
alias ga='git add'
alias gaa='git status && read && git add .'

mkcd () {
    mkdir -p -- "$1" && \
    cd -P -- "$1"
}

sva() {
	if [ -n "$1" ]; then
		base="$1"
	else
		base=.
	fi
	if [ -x "$base/venv/bin/python" ]; then
		. "$base/venv/bin/activate"
	elif [ -x "$base/.vent/bin/python" ]; then
		. "$base/.vent/bin/activate"
	fi
}

pycclean() {
	find . -regex '^.*\(__pycache__\|\.py[co]\)$' $* -name site-packages -prune -name .git -name venv
}

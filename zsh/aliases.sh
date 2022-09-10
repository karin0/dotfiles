#!/bin/bash

alias cp='cp -iv'
alias mv='mv -iv'

alias lt='ls -lAhtr'

alias px='HTTP_PROXY=$KRR_PROXY HTTPS_PROXY=$KRR_PROXY ALL_PROXY=$KRR_PROXY'
alias epx='[ -n "$KRR_PROXY" ] && export HTTP_PROXY=$KRR_PROXY HTTPS_PROXY=$KRR_PROXY ALL_PROXY=$KRR_PROXY'
alias unepx='unset HTTP_PROXY HTTPS_PROXY ALL_PROXY'

alias gc='git commit -m'
alias gca='git commit -am'
alias gs='git status'
alias gd='git diff'
alias ga='git add'
# alias gaa='git status && read && git add .'

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

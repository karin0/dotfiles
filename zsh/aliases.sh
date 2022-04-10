#!/bin/bash

alias cp='cp -iv'
alias mv='mv -iv'

alias lt='ls -lAhtr'

PROXY=http://127.0.0.1:10808

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

# gac() {
#     LOG="$*"
#     git diff --name-only && \
#     read -n 1 && \
#     git add . && \
#     git commit -m "$LOG" && \
#     read -n 1
# }

# gacp() {
#     gac "$*" && git push
# }

# pgacp() {
#     gac "$*" && proxychains4 git push
# }

sva() {
	if [ -n $1 ]; then
		. "$1/venv/bin/activate"
	else
		. "venv/bin/activate"
	fi
}

pycclean() {
	local a="$(find . -regex '^.*\(__pycache__\|\.py[co]\)$' $* -name site-packages -prune -name .git -name venv)"
    echo $a
}

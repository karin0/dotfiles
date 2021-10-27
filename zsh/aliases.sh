alias cp='cp -iv'
alias mv='mv -iv'

# alias pc="proxychains4 -f ~/dotfiles/etc/proxychains.conf"
alias pc=proxychains4

alias lt='ls -lAhtr'
# alias ls='lsd -A'
# alias ll='lsd -Al --date "+%F %T"'

alias px='HTTP_PROXY=http://127.0.0.1:10808 HTTPS_PROXY=http://127.0.0.1:10808 ALL_PROXY=http://127.0.0.1:10808'

alias epx='export HTTP_PROXY=http://127.0.0.1:10808 HTTPS_PROXY=http://127.0.0.1:10808 ALL_PROXY=http://127.0.0.1:10808'

alias enpx='export HTTP_PROXY= HTTPS_PROXY= ALL_PROXY='

alias tldr='pc -q tldr'

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

sv() {
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

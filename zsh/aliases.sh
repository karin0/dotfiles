alias cp='cp -iv'
alias mv='mv -iv'
alias rm='trash-put -v'

# alias pc="proxychains4 -f ~/dotfiles/etc/proxychains.conf"
alias pc=proxychains4

alias lt='ls -lAhtr'
# alias ls='lsd -A'
alias ls='exa -a --icons'
alias ll='exa -al --git --time-style iso --icons'
# alias ll='lsd -Al --date "+%F %T"'

alias spsyu='sudo pacman -Syu'

# alias ncm='sudo node ~/clones/UnblockNeteaseMusic/app.js -f 59.111.181.38 -p 80:443 &; netease-cloud-music --ignore-certificate-errors'
alias ncm='netease-cloud-music --ignore-certificate-errors'

alias px='HTTP_PROXY=http://127.0.0.1:10808 HTTPS_PROXY=http://127.0.0.1:10808 ALL_PROXY=http://127.0.0.1:10808'

alias epx='export HTTP_PROXY=http://127.0.0.1:10808 HTTPS_PROXY=http://127.0.0.1:10808 ALL_PROXY=http://127.0.0.1:10808'

alias enpx='export HTTP_PROXY= HTTPS_PROXY= ALL_PROXY='

alias tldr='pc -q tldr'

mkcd () {
    mkdir -p -- "$1" && \
    cd -P -- "$1"
}

gac() {
    LOG="$*"
    git diff --name-only && \
    read -n 1 && \
    git add . && \
    git commit -m "$LOG" && \
    read -n 1
}

gacp() {
    gac "$*" && git push
}

pgacp() {
    gac "$*" && proxychains4 git push
}

sv() {
	if [ -n $1 ]; then
		. "$1/venv/bin/activate"
	else
		. "venv/bin/activate"
	fi
}

mntd() {
    sudo mount /dev/nvme0n1p4 /mnt/d
}

pycclean() {
	local a="$(find . -regex '^.*\(__pycache__\|\.py[co]\)$' $* -name site-packages -prune -name .git -name venv)"
    echo $a
}

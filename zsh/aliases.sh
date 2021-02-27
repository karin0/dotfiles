alias pc=proxychains4
alias cp='cp -i'
alias mv='mv -i'
alias lt='ls -lAhtr'
alias rm='trash-put -v'

alias spsyu='sudo pacman -Syu'

# alias ncm='sudo node ~/clones/UnblockNeteaseMusic/app.js -f 59.111.181.38 -p 80:443 &; netease-cloud-music --ignore-certificate-errors'

alias px='HTTP_PROXY=http://127.0.0.1:10808 HTTPS_PROXY=http://127.0.0.1:10808 ALL_PROXY=http://127.0.0.1:10808'

mkcd () {
    mkdir -p -- "$1" &&
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

gacpo() {
    gac "$1" && git push --set-upstream $2 master
}


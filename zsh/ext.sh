alias ls='exa -a --icons'
alias ll='exa -al --git --time-style iso --icons'
alias rm='trash-put -v'

alias spsyu='sudo pacman -Syu'

# alias ncm='sudo node ~/clones/UnblockNeteaseMusic/app.js -f 59.111.181.38 -p 80:443 &; netease-cloud-music --ignore-certificate-errors'
# alias ncm='netease-cloud-music --ignore-certificate-errors'

mntd() {
    sudo mount /dev/nvme0n1p4 /mnt/d
}

BASE16_SHELL="$HOME/clones/base16-shell/"
[ -n "$PS1" ] && \
    [ -s "$BASE16_SHELL/profile_helper.sh" ] && \
        eval "$("$BASE16_SHELL/profile_helper.sh")"

eval "$(zoxide init zsh)"

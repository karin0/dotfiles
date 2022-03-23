if exa -v >/dev/null 2>&1; then
  alias ls='exa -a --icons'
  alias ll='exa -al --git --time-style iso --icons'
fi

if trash --version >/dev/null 2>&1; then
  alias rm='trash-put -v'
fi

alias spsyu='sudo pacman -Syu'

# alias ncm='sudo node ~/clones/UnblockNeteaseMusic/app.js -f 59.111.181.38 -p 80:443 &; netease-cloud-music --ignore-certificate-errors'
# alias ncm='netease-cloud-music --ignore-certificate-errors'

alias mntd="sudo mount /dev/nvme0n1p4 /mnt/d"
alias mntc="sudo mount /dev/nvme0n1p2 /mnt/c"

if zoxide -V >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

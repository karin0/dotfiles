alias tls=trash-list
alias vim=nvim

alias ncm='sudo node ~/clones/UnblockNeteaseMusic/app.js -f 59.111.181.38 -p 80:443 &; netease-cloud-music --ignore-certificate-errors'
alias ncm='netease-cloud-music --ignore-certificate-errors'

wmnt() {
    sudo mount /dev/nvme0n1p3 /mnt/d
    sudo mount /dev/sdb2 /mnt/f
}

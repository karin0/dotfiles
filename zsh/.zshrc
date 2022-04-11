#!/bin/zsh

export KRR_HERE="$HOME/dotfiles/zsh"
HERE="$KRR_HERE"

source "$HERE/common.sh"
source "$HERE/aliases.sh"

if [ -f ~/aliases.sh ]; then
    source ~/aliases.sh
fi

if echo "$PREFIX" | grep -o "com.termux" >/dev/null 2>/dev/null; then
  export KRR_TMX=1
  export STARSHIP_CONFIG="$HERE/starship_tmx.toml"
else
  export STARSHIP_CONFIG="$HERE/starship.toml"

  if [ "$USERNAME" = "root" ]; then
    alias epx=
  fi
fi

HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000000
SAVEHIST=10000000

rationalise-dot() {
  local MATCH # keep the regex match from leaking to the environment
  if [[ $LBUFFER =~ '(^|/| |      |'$'\n''|\||;|&)\.\.$' ]]; then
    LBUFFER+=/
    zle self-insert
    zle self-insert
  else
    zle self-insert
  fi
}
zle -N rationalise-dot
bindkey . rationalise-dot
bindkey -M isearch . self-insert

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=9'

### Added by Zinit's installer
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit
### End of Zinit's installer chunk

zinit ice lucid wait
zinit light zsh-users/zsh-completions

zinit ice lucid wait atinit='zpcompinit'

if fzf --version >/dev/null 2>&1; then
  zinit light Aloxaf/fzf-tab
fi

zinit light zdharma-continuum/fast-syntax-highlighting

zinit ice lucid wait atload='_zsh_autosuggest_start'
zinit light zsh-users/zsh-autosuggestions

# zinit ice depth=1
# zinit light denysdovhan/spaceship-prompt
# zinit light romkatv/powerlevel10k

if [ -z $KRR_TMX ]; then
  epx
  zinit ice svn
  zinit snippet OMZ::plugins/extract
  unepx
fi

if KRR_DEV=$(cat ~/dotfiles/devid 2>/dev/null); then
  RC=~/dotfiles/dev/$KRR_DEV/zshrc
  [ -f "$RC" ] && . "$RC"
fi

source "$HERE/opt.sh"

#!/bin/zsh

HERE="$HOME/dotfiles/zsh"

HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000000
SAVEHIST=10000000

alias in_path='whence -p >/dev/null'

. "$HERE/common.sh"

export STARSHIP_CONFIG="$HERE/starship.toml"

if DEV=$(cat ~/dotfiles/devid 2>/dev/null); then
  RC=~/dotfiles/dev/$DEV/zshrc
  [ -f "$RC" ] && . "$RC"
  RC=~/dotsecrets/dev/$DEV/zshrc
  [ -f "$RC" ] && . "$RC"
fi

. "$HERE/aliases.sh"

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

if in_path fzf; then
  zinit light Aloxaf/fzf-tab
fi

zinit light zdharma-continuum/fast-syntax-highlighting

zinit ice lucid wait atload='_zsh_autosuggest_start'
zinit light zsh-users/zsh-autosuggestions

# zinit ice depth=1
# zinit light denysdovhan/spaceship-prompt
# zinit light romkatv/powerlevel10k

if in_path svn; then
  epx
  zinit ice svn
  zinit snippet OMZ::plugins/extract
  zinit snippet OMZ::lib/history.zsh
  unepx
fi

. "$HERE/opt.sh"

in_path zoxide && eval "$(zoxide init zsh)"
in_path starship && eval "$(starship init zsh)"

#!/bin/zsh

if DEV=$(cat ~/dotfiles/devid 2>/dev/null); then
  RC=~/dotfiles/dev/$DEV/zshrc
  [ -f "$RC" ] && . "$RC"
fi

check_battery() {
  local bat="$(upower -e | grep -m 1 BAT)"
  bat="$(upower -i $bat | grep state: -m 1 | tr -s ' ' | cut -d' ' -f3)"
  if [ "$bat" != charging ] && [ "$bat" != fully-charged ]; then
    echo "\033[0;31m\033[1mBATTERY NOT CHARGING: $bat\033[0m"
  fi
}

alias in_path='whence -p >/dev/null'
in_path upower && check_battery

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

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
cache="${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
if [[ -r "$cache" ]]; then
  source "$cache"
fi

HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000000
SAVEHIST=10000000

if in_path vim; then
  export VISUAL=vim
  export EDITOR=vim
elif in_path vi; then
  export VISUAL=vi
  export EDITOR=vi
fi

export PATH="$HOME/bin:$HOME/lark/bin:$HOME/dotsecrets/bin:$HOME/dotfiles/bin:$HOME/.cargo/bin:$HOME/.yarn/bin:$HOME/.local/bin:$PATH"

export LANG=zh_CN.UTF-8
export LANGUAGE=zh_CN:zh_TW:en_US

# Allow overridden by environment
if [ ! -v KRR_PROXY ]; then
  KRR_PROXY=http://127.0.0.1:10807
fi
export KRR_PROXY

if [ "$USER" = root ] || [ -v TERMUX_VERSION ] || ! in_path sudo ; then
  KRR_SUDO=''
else
  KRR_SUDO='sudo'
fi

HERE="$HOME/dotfiles/zsh"

. "$HERE/aliases.sh"
. "$HERE/opt.sh"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
. "$HERE/p10k.zsh"
zinit ice depth=1
zinit light romkatv/powerlevel10k

KRR_COMP=
if [ -n $KRR_PKG ]; then
  KRR_COMP+="; compdef pac=$KRR_PKG"
fi
if in_path kubectl; then
  KRR_COMP+='; source <(kubectl completion zsh)'
fi
if in_path zoxide; then
  KRR_COMP+='; eval "$(zoxide init zsh)"'
fi

zinit wait lucid for \
 atinit"ZINIT[COMPINIT_OPTS]=-C; zicompinit; zicdreplay$KRR_COMP" \
    zdharma-continuum/fast-syntax-highlighting \
 blockf \
    zsh-users/zsh-completions \
 atload"!_zsh_autosuggest_start" \
    zsh-users/zsh-autosuggestions

if in_path fzf; then
  zinit light Aloxaf/fzf-tab
fi

if in_path svn; then
  zinit ice svn
  zinit snippet OMZ::plugins/extract
fi

zinit snippet OMZ::lib/history.zsh
zinit light MichaelAquilina/zsh-you-should-use
zinit light zsh-users/zsh-history-substring-search

zinit ice depth=1
zinit light jeffreytse/zsh-vi-mode

ZSH_AUTOSUGGEST_STRATEGY=match_prev_cmd
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=9'
YSU_MESSAGE_POSITION=after
YSU_MODE=ALL

bindkey '^F' forward-word
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

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

if [ -n DEV ]; then
  RC=~/dotsecrets/dev/$DEV/zshrc
  [ -f "$RC" ] && . "$RC"
fi
unset DEV RC

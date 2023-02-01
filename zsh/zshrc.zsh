#!/bin/zsh

BASE16_SHELL="$HOME/clones/base16-shell"
if [[ -n "$PS1" && -s "$BASE16_SHELL/profile_helper.sh" ]]; then
  . "$BASE16_SHELL/profile_helper.sh"
fi

alias in_path='whence -p >/dev/null'

if [[ $- == *i* && ! -v TMUX && "$(</proc/$PPID/cmdline)" =~ "terminal" ]] && in_path tmux; then
  exec tmux -f ~/dotfiles/tmux/tmux.conf
fi

if in_path upower; then
  () {
    local bat="$(upower -e | grep -m 1 BAT)"
    bat="$(upower -i $bat | grep state: -m 1 | tr -s ' ' | cut -d' ' -f3)"
    if [ "$bat" != charging ] && [ "$bat" != fully-charged ]; then
      echo "\033[0;31m\033[1mBATTERY NOT CHARGING: $bat\033[0m"
    fi
  }
fi

if [ -v TERMUX_VERSION ] && in_path gpg-connect-agent; then
  export GPG_TTY=$(tty)
  export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
  KRR_PROXY=
fi

if [ -z "$KRR_RELOAD" ]; then
  # Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
  # Initialization code that may require console input (password prompts, [y/n]
  # confirmations, etc.) must go above this block; everything else may go below.
  cache="${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
  if [ -r "$cache" ]; then
    source "$cache"
  fi
  unset cache
else
  unset KRR_RELOAD
fi

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

HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000000
SAVEHIST=10000000

export PATH="$HOME/bin:$HOME/lark/bin:$HOME/dotsecrets/bin:$HOME/dotfiles/bin:$HOME/.cargo/bin:$HOME/.yarn/bin:$HOME/.local/bin:$PATH"

if in_path nvim; then
  export VISUAL=nvim EDITOR=nvim
elif in_path vim; then
  export VISUAL=vim EDITOR=vim
elif in_path vi; then
  export VISUAL=vi EDITOR=vi
fi

export LANG=zh_CN.UTF-8
export LANGUAGE=zh_CN:zh_TW:en_US

# Allow overridden by environment
if [ ! -v KRR_PROXY ]; then
  if in_path nc; then
    if nc -z 127.0.0.1 10808; then
      KRR_PROXY=http://127.0.0.1:10808
    elif nc -z 127.0.0.1 10807; then
      KRR_PROXY=http://127.0.0.1:10807
    fi
  else
    KRR_PROXY=http://127.0.0.1:10807
  fi
fi
export KRR_PROXY

if [ "$USER" != root ] && ! [ -v TERMUX_VERSION ] && in_path sudo; then
  KRR_SUDO='sudo'
fi

HERE="$HOME"/dotfiles/zsh
. "$HERE"/aliases.sh
. "$HERE"/opt.sh

ZSH_AUTOSUGGEST_STRATEGY=(match_prev_cmd completion)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=9'
YSU_MESSAGE_POSITION=after
YSU_MODE=ALL
ZINIT[COMPINIT_OPTS]=-C

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
. "$HERE"/p10k.zsh

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

_post_plugin() {
  bindkey '^F' forward-word
  bindkey '^[[A' history-substring-search-up
  bindkey '^[[B' history-substring-search-down

  zle -N rationalise-dot
  bindkey . rationalise-dot
  bindkey -M isearch . self-insert
}

zinit light-mode depth=1 for \
  romkatv/powerlevel10k \
  zdharma-continuum/fast-syntax-highlighting \
  zsh-users/zsh-completions \
  zsh-users/zsh-autosuggestions \
  zsh-users/zsh-history-substring-search \
  MichaelAquilina/zsh-you-should-use \
  jeffreytse/zsh-vi-mode

zicompinit; zicdreplay
[ -n $KRR_PKG ] && compdef pac=$KRR_PKG
in_path kubectl && source <(kubectl completion zsh)
in_path zoxide && eval "$(zoxide init zsh)"
_zsh_autosuggest_start

zinit ice lucid depth=1 has='fzf'
zinit light Aloxaf/fzf-tab

zinit ice svn depth=1 has='svn'
zinit snippet OMZP::extract

zinit ice depth=1 wait='0' atinit='_post_plugin'
zinit snippet OMZ::lib/history.zsh

HERE="${XDG_CONFIG_HOME:=$HOME/.config}/dotfiles/zsh.d"
if [ -d "$HERE" ]; then
  for i in "$HERE"/*; do
    . "$i"
  done
fi
unset HERE

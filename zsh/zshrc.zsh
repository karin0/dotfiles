#!/bin/zsh

alias in_path='whence -p >/dev/null'

if in_path upower; then
  () {
    local bat="$(upower -e | grep -m 1 BAT)"
    if [ -n "$bat" ]; then
      bat="$(upower -i $bat | grep state: -m 1 | tr -s ' ' | cut -d' ' -f3)"
      if [ "$bat" != charging ] && [ "$bat" != fully-charged ]; then
        echo "\033[0;31m\033[1mBATTERY NOT CHARGING: $bat\033[0m"
      fi
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

if [ "$OSTYPE" = msys ]; then
  export MSYS=winsymlinks:native
  . ~/.ssh-pageant-out >/dev/null 2>&1
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

# No CJK in Linux console
if [ "$TERM" != linux ]; then
  export LANG=zh_CN.UTF-8
  export LANGUAGE=zh_CN:zh_TW:en_US
fi

# Allow overridden by environment
if [ ! -v KRR_PROXY ]; then
  export KRR_PROXY=http://127.0.0.1:10807
fi

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
  bindkey '^[[1;2C' forward-word
  bindkey '^[[1;2D' backward-word

  bindkey '^[[1;3C' forward-word
  bindkey '^[[1;3D' backward-word

  bindkey '^[[1;5C' forward-word
  bindkey '^[[1;5D' backward-word

  bindkey '^F' forward-word
  bindkey '^[[A' history-substring-search-up
  bindkey '^[[B' history-substring-search-down

  zle -N rationalise-dot
  bindkey . rationalise-dot
  bindkey -M isearch . self-insert
}

_post_comp() {
  [ -n $KRR_PKG ] && compdef pac=$KRR_PKG
}

zinit wait lucid light-mode for \
  atinit"zicompinit; zicdreplay; _post_comp" \
      zdharma-continuum/fast-syntax-highlighting \
  atload"_zsh_autosuggest_start" \
      zsh-users/zsh-autosuggestions \
  blockf atpull'zinit creinstall -q .' \
      zsh-users/zsh-completions

zinit light-mode depth=1 for \
  romkatv/powerlevel10k \
  zsh-users/zsh-history-substring-search \
  MichaelAquilina/zsh-you-should-use \
  jeffreytse/zsh-vi-mode \
  has'make' as"program" pick"$ZPFX/bin/git-*" src"etc/git-extras-completion.zsh" make"PREFIX=$ZPFX" \
    tj/git-extras \
  if'[[ -v TERMUX_VERSION || "$(</proc/$PPID/cmdline)" =~ "terminal|login" ]] 2>/dev/null' \
    chriskempson/base16-shell

# https://github.com/zdharma-continuum/zinit/discussions/651
setopt RE_MATCH_PCRE   # _fix-omz-plugin function uses this regex style

# Workaround for zinit issue#504: remove subversion dependency. Function clones all files in plugin
# directory (on github) that might be useful to zinit snippet directory. Should only be invoked
# via zinit atclone"_fix-omz-plugin"
_fix-omz-plugin() {
  if [[ ! -f ._zinit/teleid ]] then return 0; fi
  if [[ ! $(cat ._zinit/teleid) =~ "^OMZP::.*" ]] then return 0; fi
  local OMZP_NAME=$(cat ._zinit/teleid | sed -n 's/OMZP:://p')
  git clone --quiet --no-checkout --depth=1 --filter=tree:0 https://github.com/ohmyzsh/ohmyzsh
  cd ohmyzsh
  git sparse-checkout set --no-cone plugins/$OMZP_NAME
  git checkout --quiet
  cd ..
  local OMZP_PATH="ohmyzsh/plugins/$OMZP_NAME"
  local file
  for file in $(ls -a ohmyzsh/plugins/$OMZP_NAME); do
    if [[ $file == '.' ]] then continue; fi
    if [[ $file == '..' ]] then continue; fi
    if [[ $file == '.gitignore' ]] then continue; fi
    if [[ $file == 'README.md' ]] then continue; fi
    if [[ $file == "$OMZP_NAME.plugin.zsh" ]] then continue; fi
    cp $OMZP_PATH/$file $file
  done
  rm -rf ohmyzsh
}

zinit wait lucid for \
  atclone"_fix-omz-plugin" \
    OMZP::extract

in_path kubectl && source <(kubectl completion zsh)
in_path zoxide && eval "$(zoxide init zsh)"

zinit ice lucid depth=1 has='fzf'
zinit light Aloxaf/fzf-tab

zinit ice depth=1 wait='0' atinit='_post_plugin'
zinit snippet OMZ::lib/history.zsh

HERE="${XDG_CONFIG_HOME:=$HOME/.config}/dotfiles/zsh.d"
if [ -d "$HERE" ]; then
  for i in "$HERE"/*; do
    . "$i"
  done
fi
unset HERE

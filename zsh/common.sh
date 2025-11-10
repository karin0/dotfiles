#!/bin/bash

export PATH="$HOME/bin:$HOME/lark/bin:$HOME/dotsecrets/bin:$HOME/dotfiles/bin:$HOME/.cargo/bin:$HOME/.venv/bin:$HOME/.local/bin:/opt/dotfiles:$PATH"

if in_path gpg-connect-agent; then
  if [ -v TERMUX_VERSION ]; then
    export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
  fi

  if ! [ -v MSYSTEM ] && _krr_tty=$(tty 2>&1); then
    gtty() {
      export GPG_TTY="$_krr_tty"
      gpg-connect-agent UPDATESTARTUPTTY /bye >/dev/null
    }
  fi
fi

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
# if [ ! -v KRR_PROXY ]; then
#   export KRR_PROXY=http://127.0.0.1:10807
# fi

if [ "$USER" != root ] && ! [ -v TERMUX_VERSION ] && ! [ -v MSYSTEM ] && in_path sudo; then
  KRR_SUDO='sudo'
fi

. "$HERE"/aliases.sh
. "$HERE"/opt.sh

if [ -f ~/dotsecrets/zsh/common.sh ]; then
  . ~/dotsecrets/zsh/common.sh
fi

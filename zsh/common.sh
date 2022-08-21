#!/bin/bash

if in_path vim; then
  export VISUAL="vim"
  export EDITOR="vim"
elif in_path vi; then
  export VISUAL="vi"
  export EDITOR="vi"
fi

export PATH=$HOME/dotfiles/bin:$HOME/lark/bin:$HOME/bin:$HOME/.local/bin:$HOME/.yarn/bin:$PATH

export LANG=zh_CN.UTF-8
export LANGUAGE=zh_CN:zh_TW:en_US

# Allow overridden by environment
if [ ! -v KRR_PROXY ]; then
  export KRR_PROXY=http://127.0.0.1:10807
fi

#!/bin/bash

if in_path vim; then
  export VISUAL="vim"
  export EDITOR="vim"
elif in_path vi; then
  export VISUAL="vi"
  export EDITOR="vi"
fi

export PATH=$HOME/dotfiles/bin:$HOME/lark/bin:$HOME/bin:$HOME/.local/bin:$HOME/.yarn/bin:$PATH

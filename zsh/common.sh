#!/bin/bash

if vim --version >/dev/null 2>&1; then
  export VISUAL="vim"
  export EDITOR="vim"
elif vi --version >/dev/null 2>&1; then
  export VISUAL="vi"
  export EDITOR="vi"
fi

export PATH=$HOME/dotfiles/bin:$HOME/lark/bin:$HOME/bin:$HOME/.local/bin:$HOME/.yarn/bin:$PATH

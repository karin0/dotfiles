HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000000
SAVEHIST=10000000

alias ls="ls --color=always"

export VISUAL="vim"
export EDITOR="vim"
export PATH=$HOME/lark/bin:$HOME/bin:$HOME/.local/bin:$PATH

autoload -U is-at-least

source ~/.zsh-plugins.sh

source ~/dotfiles/zsh/spaceship.sh

BASE16_SHELL="$HOME/clones/base16-shell/"
[ -n "$PS1" ] && \
    [ -s "$BASE16_SHELL/profile_helper.sh" ] && \
        eval "$("$BASE16_SHELL/profile_helper.sh")"

autoload -Uz compinit
compinit

eval $(thefuck --alias)

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=9'
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# export PATH="$PATH:$(yarn global bin)"

source ~/dotfiles/zsh/aliases.sh

if [ -f ~/aliases.sh ]; then
    source ~/aliases.sh
fi

export RUSTUP_DIST_SERVER=https://mirrors.tuna.tsinghua.edu.cn/rustup

eval "$(zoxide init zsh)"


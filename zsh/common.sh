export VISUAL="vim"
export EDITOR="vim"
export PATH=$HOME/lark/bin:$HOME/bin:$HOME/.local/bin:$HOME/.yarn/bin:$PATH

source "$KRR_HERE/aliases.sh"

if [ -f ~/aliases.sh ]; then
    source ~/aliases.sh
fi

BASE16_SHELL="$HOME/clones/base16-shell/"
[ -n "$PS1" ] && \
    [ -s "$BASE16_SHELL/profile_helper.sh" ] && \
        eval "$("$BASE16_SHELL/profile_helper.sh")"

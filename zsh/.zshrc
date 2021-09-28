HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000000
SAVEHIST=10000000

export VISUAL="vim"
export EDITOR="vim"
export PATH=$HOME/lark/bin:$HOME/bin:$HOME/.local/bin:$PATH

BASE16_SHELL="$HOME/clones/base16-shell/"
[ -n "$PS1" ] && \
    [ -s "$BASE16_SHELL/profile_helper.sh" ] && \
        eval "$("$BASE16_SHELL/profile_helper.sh")"

# autoload -U is-at-least

# source ~/.zsh-plugins.sh

# autoload -Uz compinit
# compinit

# export PATH="$PATH:$(yarn global bin)"

eval "$(zoxide init zsh)"

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

source ~/dotfiles/zsh/aliases.zsh
if [ -f ~/aliases.sh ]; then
    source ~/aliases.sh
fi

epx

### Added by Zinit's installer
if [[ ! -f $HOME/.zinit/bin/zinit.zsh ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing %F{33}DHARMA%F{220} Initiative Plugin Manager (%F{33}zdharma/zinit%F{220})…%f"
    command mkdir -p "$HOME/.zinit" && command chmod g-rwX "$HOME/.zinit"
    command git clone https://github.com/zdharma/zinit "$HOME/.zinit/bin" && \
        print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \
        print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi

source "$HOME/.zinit/bin/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zinit-zsh/z-a-rust \
    zinit-zsh/z-a-as-monitor \
    zinit-zsh/z-a-patch-dl \
    zinit-zsh/z-a-bin-gem-node

### End of Zinit's installer chunk

zinit ice lucid wait atinit='zpcompinit'
zinit light zdharma/fast-syntax-highlighting

zinit ice lucid wait atload='_zsh_autosuggest_start'
zinit light zsh-users/zsh-autosuggestions

zinit ice lucid wait
zinit light zsh-users/zsh-completions

zinit ice depth=1
zinit light denysdovhan/spaceship-prompt
# zinit light romkatv/powerlevel10k

zinit ice svn
zinit snippet OMZ::plugins/extract

enpx

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
# if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#   source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
# fi

# # To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
# [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

source ~/dotfiles/zsh/spaceship.zsh

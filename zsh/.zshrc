HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000000
SAVEHIST=10000000

export VISUAL="vim"
export EDITOR="vim"
export PATH=$HOME/lark/bin:$HOME/bin:$HOME/.local/bin:$HOME/.yarn/bin:$PATH

BASE16_SHELL="$HOME/clones/base16-shell/"
[ -n "$PS1" ] && \
    [ -s "$BASE16_SHELL/profile_helper.sh" ] && \
        eval "$("$BASE16_SHELL/profile_helper.sh")"

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

source ~/dotfiles/zsh/aliases.sh

if ! echo "$PREFIX" | grep -o "com.termux" >/dev/null 2>/dev/null; then
    source ~/dotfiles/zsh/ext_aliases.sh
fi

if [ -f ~/aliases.sh ]; then
    source ~/aliases.sh
fi

epx

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

# zinit ice lucid wait atinit='zpcompinit'
# zinit light zdharma/fast-syntax-highlighting
zinit light zdharma-continuum/fast-syntax-highlighting

zinit ice lucid wait atload='_zsh_autosuggest_start'
zinit light zsh-users/zsh-autosuggestions

zinit ice lucid wait
zinit light zsh-users/zsh-completions

# zinit ice depth=1
# zinit light denysdovhan/spaceship-prompt
# zinit light romkatv/powerlevel10k

# proxychains may be needed

zinit ice svn
zinit snippet OMZ::plugins/extract

enpx

# source ~/dotfiles/zsh/spaceship.sh

export STARSHIP_CONFIG=~/dotfiles/zsh/starship.toml
eval "$(starship init zsh)"

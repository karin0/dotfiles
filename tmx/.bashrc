export EDITOR=vim
export VISUAL=vim

. ~/dotfiles/zsh/aliases.sh

export STARSHIP_CONFIG=~/dotfiles/zsh/starship_tmx.toml
eval "$(starship init bash)"

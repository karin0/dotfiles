# zsh reads this file in every shell, including the non-interactive ones that run a command over
# ssh, so those commands find the same programs as a terminal.
typeset -U path PATH
. ~/dotfiles/zsh/path.sh

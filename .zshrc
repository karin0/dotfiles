HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000000
SAVEHIST=10000000

alias ls="ls --color=always"

mkcd () {
    mkdir -p -- "$1" &&
    cd -P -- "$1"
}

if echo $PREFIX | grep -o "com.termux" >/dev/null
then
    alias pc="proxychains4 -f ~/dotfiles/proxychains-tm.conf"
else
    alias pc=proxychains4
fi

gacp() {
    git add . && git commit -am ">_<" && pc git push
}

# alias rt='trash-put -v'
alias cp='cp -i'
alias mv='mv -i'
# alias tls=trash-list
# alias vim=nvim
alias lt='ls -lAhtr'

wmnt() {
    sudo mount /dev/nvme0n1p3 /mnt/d
    sudo mount /dev/sdb2 /mnt/f
}

export VISUAL="vim"
export EDITOR="vim"

export PATH=$HOME/lark/bin:$HOME/bin:$HOME/.local/bin:$PATH

autoload -U is-at-least

source ~/dotfiles/zsh_plugins.sh

SPACESHIP_PROMPT_ORDER=(
  dir           # Current directory section
  user          # Username section
  host          # Hostname section
  time          # Time stamps section
  git           # Git section (git_branch + git_status)
  hg            # Mercurial section (hg_branch  + hg_status)
  package       # Package version
  node          # Node.js section
  ruby          # Ruby section
  elixir        # Elixir section
  xcode         # Xcode section
  swift         # Swift section
  golang        # Go section
  php           # PHP section
  rust          # Rust section
  haskell       # Haskell Stack section
  julia         # Julia section
  docker        # Docker section
  aws           # Amazon Web Services section
  venv          # virtualenv section
  conda         # conda virtualenv section
  pyenv         # Pyenv section
  dotnet        # .NET section
  ember         # Ember.js section
#  kubecontext   # Kubectl context section
  terraform     # Terraform workspace section
  exec_time     # Execution time
  battery       # Battery level and status
  vi_mode       # Vi-mode indicator
  jobs          # Background jobs indicator
  exit_code     # Exit code section
  line_sep      # Line break
  char          # Prompt character
)

SPACESHIP_TIME_SHOW=true
SPACESHIP_USER_SHOW=always
SPACESHIP_HOST_SHOW=always
SPACESHIP_CHAR_SYMBOL='$'
SPACESHIP_CHAR_SUFFIX=' '
SPACESHIP_VENV_GENERIC_NAMES=()
SPACESHIP_VENV_COLOR=red

if ! cat /etc/hostname | grep -q 'vm'
then
    BASE16_SHELL="$HOME/clones/base16-shell/"
    [ -n "$PS1" ] && \
        [ -s "$BASE16_SHELL/profile_helper.sh" ] && \
            eval "$("$BASE16_SHELL/profile_helper.sh")"
fi

autoload -Uz compinit
compinit

alias rm='trash-put -v'

alias ncm='sudo node ~/clones/UnblockNeteaseMusic/app.js -f 59.111.181.38 -p 80:443 &; netease-cloud-music --ignore-certificate-errors'

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=9'

alias px='HTTP_PROXY=http://127.0.0.1:10808 HTTPS_PROXY=http://127.0.0.1:10808 ALL_PROXY=http://127.0.0.1:10808'


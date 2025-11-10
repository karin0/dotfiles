#!/bin/zsh

alias in_path='whence -p >/dev/null'

if in_path upower; then
  () {
    local bat="$(upower -e | grep -m 1 BAT)"
    if [ -n "$bat" ]; then
      bat="$(upower -i $bat | grep state: -m 1 | tr -s ' ' | cut -d' ' -f3)"
      if [ "$bat" != charging ] && [ "$bat" != fully-charged ]; then
        echo "\033[0;31m\033[1mBATTERY NOT CHARGING: $bat\033[0m"
      fi
    fi
  }
fi

if [ -z "$KRR_RELOAD" ]; then
  # Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
  # Initialization code that may require console input (password prompts, [y/n]
  # confirmations, etc.) must go above this block; everything else may go below.
  cache="${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
  if [ -r "$cache" ]; then
    source "$cache"
  fi
  unset cache
else
  unset KRR_RELOAD
fi

if [ "$MSYSTEM" = MSYS ]; then
  export MSYS=winsymlinks:native
  eval "$(ssh-pageant -r -a \"$temp\ssh-pageant.socket\")" >/dev/null
  # https://github.com/jeffreytse/zsh-vi-mode/issues/159
  setopt re_match_pcre
fi

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

HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000000
SAVEHIST=10000000

export PATH="$HOME/bin:$HOME/lark/bin:$HOME/dotsecrets/bin:$HOME/dotfiles/bin:$HOME/.cargo/bin:$HOME/.venv/bin:$HOME/.local/bin:/opt/dotfiles:$PATH"

if in_path gpg-connect-agent; then
  if [ -v TERMUX_VERSION ]; then
    export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
  fi

  if ! [ -v MSYSTEM ] && _krr_tty=$(tty 2>&1); then
    gtty() {
      export GPG_TTY="$_krr_tty"
      gpg-connect-agent UPDATESTARTUPTTY /bye >/dev/null
    }
  fi
fi

if in_path nvim; then
  export VISUAL=nvim EDITOR=nvim
elif in_path vim; then
  export VISUAL=vim EDITOR=vim
elif in_path vi; then
  export VISUAL=vi EDITOR=vi
fi

# No CJK in Linux console
if [ "$TERM" != linux ]; then
  export LANG=zh_CN.UTF-8
  export LANGUAGE=zh_CN:zh_TW:en_US
fi

# Allow overridden by environment
# if [ ! -v KRR_PROXY ]; then
#   export KRR_PROXY=http://127.0.0.1:10807
# fi

if [ "$USER" != root ] && ! [ -v TERMUX_VERSION ] && ! [ -v MSYSTEM ] && in_path sudo; then
  KRR_SUDO='sudo'
fi

HERE="$HOME"/dotfiles/zsh
. "$HERE"/aliases.sh

ZSH_AUTOSUGGEST_STRATEGY=(match_prev_cmd completion)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=9'
YSU_MESSAGE_POSITION=after
YSU_MODE=ALL
ZINIT[COMPINIT_OPTS]=-C

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
. "$HERE"/p10k.zsh

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

_post_plugin() {
  bindkey '^[[1;2C' forward-word
  bindkey '^[[1;2D' backward-word

  bindkey '^[[1;3C' forward-word
  bindkey '^[[1;3D' backward-word

  bindkey '^[[1;5C' forward-word
  bindkey '^[[1;5D' backward-word

  bindkey '^F' forward-word
  bindkey '^[[A' history-substring-search-up
  bindkey '^[[B' history-substring-search-down

  zle -N rationalise-dot
  bindkey . rationalise-dot
  bindkey -M isearch . self-insert

  function _do_intr {
    if [[ -n $BUFFER ]]; then
      zle .send-break
    fi
  }

  zle -N _do_intr

  bindkey '^C' _do_intr
  for m in emacs viins vicmd; do
    if bindkey -M $m >/dev/null 2>&1; then
      bindkey -M $m '^C' _do_intr
    fi
  done

  function _enable_intr {
    stty intr '^C'
  }

  function _disable_intr {
    stty intr ''
  }

  autoload -U add-zsh-hook
  add-zsh-hook preexec _enable_intr
  add-zsh-hook precmd _disable_intr
  _disable_intr
}

_post_comp() {
  [ -v $KRR_PKG ] && compdef pac=$KRR_PKG
}

zinit wait lucid light-mode for \
  atinit"zicompinit; zicdreplay; _post_comp" \
      zdharma-continuum/fast-syntax-highlighting \
  atload"_zsh_autosuggest_start" \
      zsh-users/zsh-autosuggestions \
  blockf atpull'zinit creinstall -q .' \
      zsh-users/zsh-completions

zinit light-mode depth=1 for \
  romkatv/powerlevel10k \
  zsh-users/zsh-history-substring-search \
  MichaelAquilina/zsh-you-should-use \
  jeffreytse/zsh-vi-mode \
  has'make' as"program" pick"$ZPFX/bin/git-*" src"etc/git-extras-completion.zsh" make"PREFIX=$ZPFX" \
    tj/git-extras \
  if'[[ -v TERMUX_VERSION || "$(</proc/$PPID/cmdline)" =~ "terminal|login" ]] 2>/dev/null' \
    chriskempson/base16-shell

in_path kubectl && source <(kubectl completion zsh)
in_path zoxide && eval "$(zoxide init zsh)"

zinit ice lucid depth=1 has='fzf'
zinit light Aloxaf/fzf-tab

zinit ice depth=1 wait='0' silent=1
zinit snippet 'https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/refs/heads/master/plugins/extract/extract.plugin.zsh'

zinit ice depth=1 wait='0' atinit='_post_plugin' silent=1
zinit snippet OMZ::lib/history.zsh

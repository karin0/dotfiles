syntax on
set mouse=a
set hi=1000
set nu
set ru
set ar
set ic
set si
set sta
set et
set sw=4
set ts=4
set sts=4
nmap ; :
imap {<CR> {<ESC>o}<ESC>O

let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

let g:onedark_termcolors=16
let g:airline_theme='onedark'

call plug#begin()
Plug 'joshdick/onedark.vim'
Plug 'jreybert/vimagit'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
call plug#end()

colorscheme onedark

" https://vi.stackexchange.com/a/28284
if &term =~ "screen"
  let &t_BE = "\e[?2004h"
  let &t_BD = "\e[?2004l"
  exec "set t_PS=\e[200~"
  exec "set t_PE=\e[201~"
endif

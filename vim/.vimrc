" Reasign leader key
let mapleader = " "

" UI
set relativenumber
set number

" Minimal number of screen lines to keep above and below the cursor.
" set scrolloff=10

" Disable compatibility with vi which can cause unexpected issues.
set nocompatible

" Enable type file detection. Vim will be able to try to detect the type of file in use.
filetype on

" Enable plugins and load plugin for the detected file type.
filetype plugin on

" Load an indent file for the detected file type.
filetype indent on

" Turn syntax highlighting on.
syntax on

" Set shift width to 2 spaces
set shiftwidth=2

" Set tab width to 2 columns
set tabstop=2

" Use space characters instead of tabs
set expandtab

" Ignore capital letters during search.
set ignorecase

" Override the ignorecase option if searching for capital letters.
" This will allow you to search specifically for capital letters.
set smartcase

" Show partial command you type in the last line of the screen.
set showcmd

" Show matching words during a search.
set showmatch

" Use highlighting when doing a search.
set hlsearch

" Enable auto completion menu after pressing TAB.
set wildmenu

" There are certain files that we would never want to edit with Vim.
" Wildmenu will ignore files with these extensions.
set wildignore=*.docx,*.jpg,*.png,*.gif,*.pdf,*.pyc,*.exe,*.flv,*.img,*.xlsx

" STATUS LINE ------------------------------------------------------------ {{{

  " Clear status line when vimrc is reloaded.
  set statusline=

  " Status line left side.
  set statusline+=\ %F\ %M\ %Y\ %R

  " Use a divider to separate the left side from the right side.
  set statusline+=%=

  " Status line right side.
  set statusline+=\ line:\ %l\ percent:\ %p%%

  " Show the status on the second to last line.
  set laststatus=2

" }}}

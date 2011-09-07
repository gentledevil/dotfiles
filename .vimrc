set nocompatible
set backupdir=~/.cache/vim
set smartcase
set hlsearch
" set number
syntax on
filetype plugin on
" remember last position
autocmd BufReadPost *
  \ if line("'\"") > 0 && line("'\"") <= line("$") |
  \   exe "normal! g`\"" |
  \ endif

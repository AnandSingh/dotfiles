call plug#begin('~/.vim/plugged')

Plug 'vim-autoformat/vim-autoformat'
Plug 'tmhedberg/SimpylFold'
Plug 'preservim/nerdtree'
Plug 'itchyny/lightline.vim'
Plug 'zxqfl/tabnine-vim'
Plug 'tpope/vim-commentary'
Plug 'christoomey/vim-tmux-navigator'
Plug 'jiangmiao/auto-pairs'
Plug 'machakann/vim-highlightedyank'
Plug 'morhetz/gruvbox'
Plug 'brookhong/cscope.vim'
Plug 'ycm-core/YouCompleteMe'
" Plug 'rhysd/vim-clang-format'

call plug#end()

set shell=/bin/zsh

let g:python3_host_prog="/usr/bin/python3"

" Setting the leader
let mapleader="\<Space>"

" Easier writing/quitting
nnoremap <Leader>w :w<CR>
nnoremap <Leader>x :x<CR>
nnoremap <Leader>q :q<CR>

" set the clipboard
set clipboard=unnamed

" Copy to the system clipboard
vnoremap <Leader>y "+y

" Code formatting with black
" Apply formatter on save
au BufWrite * :Autoformat

" strips whitespace when saving file
autocmd FileType c,cpp,h,java,py autocmd BufWritePre <buffer> %s/\s\+$//e


" Disable fallback to vim's indent file, retabbing and removing trailing whitespace
let g:autoformat_autoindent = 0
let g:autoformat_retab = 0
let g:autoformat_remove_trailing_spaces = 0

" Use better code folding
let g:SimpylFold_docstring_preview = 1

" Use black formatter
let g:formatters_python=['black']

" Vim pane switching
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l

" Hybrid line numbers
:set number relativenumber

:augroup numbertoggle
:  autocmd!
:  autocmd BufEnter,FocusGained,InsertLeave * set relativenumber
:  autocmd BufLeave,FocusLost,InsertEnter   * set norelativenumber
:augroup END

" Searching within a file
set hlsearch  " highlight search results 
set incsearch " show search results as you type
nnoremap <silent> <CR> :nohlsearch<Bar>:echo<CR> " Clear search results with enter

" Nerdtree open/close toggle
map <C-n> :NERDTreeToggle<CR>


" Tab spacing
set tabstop=4 
set softtabstop=4 
set shiftwidth=4
set smarttab
set expandtab                            

" Color
let g:gruvbox_contrast_dark = 'hard'
if exists('+termguicolors')
    let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
    let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
endif
let g:gruvbox_invert_selection='0'
syntax enable
silent! colorscheme gruvbox
set background=dark

" Additional vim options
set encoding=utf-8                       " Set encoding
set ruler                                " Show line, column number
set viminfo='20,<1000                    " Increase the copy/paste-buffer
set noerrorbells visualbell t_vb=        " Get rid of bell sound on error
set nowrap                               " Turn off text wrapping
set colorcolumn=88                       " Column number for vertical line
set cursorline                           " Highlight the line of the cursor
set t_Co=256                             " Required for vim colorscheme show up in tmux

:imap kj <Esc>

" clang-format
"

" Auto enabling auto-formating
" autocmd FileType c ClangFormatAutoEnable
" 
" let g:clang_format#style_options = {
"             \ "AccessModifierOffset" : -4,
"             \ "AllowShortIfStatementsOnASingleLine" : "true",
"             \ "AlwaysBreakTemplateDeclarations" : "true",
"             \ "Standard" : "C++11"}
" 
" " map to <Leader>cf in C++ code
" autocmd FileType c,cpp,objc nnoremap <buffer><Leader>cf :<C-u>ClangFormat<CR>
" autocmd FileType c,cpp,objc vnoremap <buffer><Leader>cf :ClangFormat<CR>
" " if you install vim-operator-user
" autocmd FileType c,cpp,objc map <buffer><Leader>x <Plug>(operator-clang-format)
" " Toggle auto formatting:
" nmap <Leader>C :ClangFormatAutoToggle<CR>
" 


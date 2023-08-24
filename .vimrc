" Policy
"   nvim と異なりリモート環境などでの使用を想定しているので極力シンプルに。
"   plugin も使わない。

colorscheme desert

set backspace=indent,eol,start
noremap!  
set scrolloff=2

set ruler
set fenc=utf-8
set nobackup
set noswapfile
set autoread
set hidden
set showcmd

set whichwrap=b,s,<,>,[,]

set number
set virtualedit=block
set autoindent
set smartindent
set showmatch
set laststatus=2
set wildmode=list:longest
nnoremap j gj
nnoremap k gk


set list listchars=tab:\▸\-
set expandtab
set tabstop=4
set shiftwidth=0  " if 0 then use the value of tabstop.

set ignorecase
set smartcase
set incsearch
set wrapscan
set hlsearch


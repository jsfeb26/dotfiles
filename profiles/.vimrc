let mapleader=","

" Plug bundle manager {{{
    " specify a directory for plugins
    call plug#begin('~/.vim/plugged')

    " Syntax
    Plug 'tpope/vim-git'
    Plug 'moll/vim-node'
    Plug 'pangloss/vim-javascript'

    Plug 'othree/html5.vim', { 'for': ['htm'] }
    Plug 'leshill/vim-json'
    Plug 'mxw/vim-jsx'

    " Plug 'briancollins/vim-jst'
    " Plug 'ElmCast/elm-vim'
    " Plug 'tpope/vim-markdown'
    " Plug 'fatih/vim-go'
    " Plug 'elixir-lang/vim-elixir'
    " Plug 'posva/vim-vue'
    " Plug 'Quramy/tsuquyomi'
    "
    " " Actual Plugs
    Plug 'tpope/vim-surround'
    Plug 'christoomey/vim-tmux-navigator'
    Plug 'vim-airline/vim-airline'
    Plug 'vim-airline/vim-airline-themes'
    Plug 'tpope/vim-fugitive'
    Plug 'tpope/vim-eunuch'
    Plug 'tpope/vim-repeat'
    Plug 'editorconfig/editorconfig-vim'
    Plug 'rking/ag.vim'
    Plug 'scrooloose/nerdtree'
    Plug 'jistr/vim-nerdtree-tabs'
    " Plug 'tpope/vim-commentary'
    " Plug 'tpope/vim-ragtag'
    " Plug 'AndrewRadev/splitjoin.vim'
    " Plug 'tpope/vim-unimpaired'
    " Plug 'gorkunov/smartpairs.vim'
    " Plug 'thinca/vim-visualstar'
    " Plug 'christoomey/vim-tmux-runner'
    " Plug 'thoughtbot/vim-rspec'
    Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
    Plug 'junegunn/fzf.vim'
    " Plug 'jordwalke/VimAutoMakeDirectory'
    " Plug 'w0rp/ale'
    " Plug 'tpope/vim-vinegar'
    " Plug 'SirVer/ultisnips'
    " Plug 'Valloric/YouCompleteMe', { 'do': './install.py --tern-completer' }
    "
    " Plug 'junegunn/goyo.vim'
    "
    " " Colours
    Plug 'ajh17/Spacegray.vim'
    Plug 'altercation/vim-colors-solarized'
    Plug 'jackfranklin/Smyck-Color-Scheme'

    call plug#end()
"}}}

" General {{{
    set nocompatible
" }}}

" Colors {{{
    syntax enable " enable syntax processing
    " set background=dark
    " colorscheme solarized

    " smyck theme
    set background=dark
    colorscheme smyck

    " spacegray theme
    " colorscheme spacegray
    " highlight CursorLine ctermbg=235
    " highlight ColorColumn ctermbg=235
" }}}

" Spaces & Tabs {{{
    set history=10000
    set tabstop=4 " number of visual spaces per TAB
    set softtabstop=4 " number of spaces in tab when editing
    set expandtab " tabs are spaces
    set autoindent " indents when entering edit mode
    set modelines=1 " tells vim to check the final line of files for modelines. These are lines that have special setting for just that file
    filetype plugin indent on
" }}}

" UI Layout {{{
    set number " show line numbers
    set showcmd " show command in bottom bar
    filetype indent on " load filetype specific indent files. e.g ~/.vim/indent/python.vim gets loaded everytime a *.py file is opened
    set wildmenu " visual autocomplete for command menu
    set lazyredraw " redraw only when we need to
    set showmatch " highlight matching [{(}]
    " Make it obvious where 100 characters is
    set textwidth=100
    set colorcolumn=120
    set cursorline " highlight current line
    hi cursorline cterm=none term=none
    autocmd WinEnter * setlocal cursorline
    autocmd WinLeave * setlocal nocursorline
    set scrolloff=5 " scrolls to make sure there are 5 lines below and above cursor
    " clear highlights by hitting ESC
    " " or by hitting enter in normal mode
    nnoremap <CR> :noh<CR><CR>
    " Stop Vim dying if there's massively long lines.
    set synmaxcol=500
" }}}

" NerdTree {{{
    autocmd VimEnter * NERDTree | wincmd p
    " map tab key to typing in :NERDTreeTabsToggle [Enter]
    map <Tab> :NERDTreeTabsToggle<CR>
    " show hidden files
    let NERDTreeShowHidden=1
" }}}

" Searching {{{
    set incsearch " search as characters are entered
    set hlsearch " highlight matches
    " turn off search highlight
    nnoremap <leader><space> :nohlsearch<CR>
    " FZF.vim
    imap <c-x><c-o> <plug>(fzf-complete-line)
    nnoremap <leader>t :Files<cr>
    nnoremap <leader>b :Buffers<cr>

    nmap <leader><tab> <plug>(fzf-maps-n)
    xmap <leader><tab> <plug>(fzf-maps-x)
    omap <leader><tab> <plug>(fzf-maps-o)

    let g:fzf_prefer_tmux = 1
" }}}

" Folding {{{
    set foldenable " enable folding
    set foldlevelstart=10 " open most folds by default when opening a new buffer (0 all would be folded and 99 none would be folded)
    set foldnestmax=10 " 10 nested fold max. guards against too many folds
    " map space key to fold/unfold
    nnoremap <space> za
    set foldmethod=indent " folds based on indent
" }}}

" Movement {{{
    " moves up/down visual lines. Meaning really long lines that wrap
    nnoremap j gj
    nnoremap k gk
    " move to the beginning/end of lines. Remove ?????
    nnoremap B ^
    nnoremap E $
    " highlight last inserted text
    nnoremap gV `[V`]
" }}}

" Leader Shortcuts {{{
    " maps <leader> to ,
    " jk is escape
    " inoremap jk <esc>
    " map shortcut for Gundo (a visual represenation of undo tree) to ,u
    nnoremap <leader>u :GundoToggle<CR>
    " save session the way your windows were setup
    nnoremap <leader>s :mksession<CR>
    " open ack.vim, which uses the silver searcher tool to search
    nnoremap <leader>f :Ack!<space>
    " CrlP settings
    let g:ctrlp_match_window='bottom,order:ttb'
    let g:ctrlp_switch_buffer=0
    let g:ctrlp_working_path_mode=0
    let g:ctrlp_custom_ignore = '\vbuild/|node_modules/|dist/|venv/|target/|\.(o|swp|pyc|egg)$'
    let g:ctrlp_map = '<c-p>'
    let g:ctrlp_cmd = 'CtrlP'
" }}}

" Airline & Fugitive {{{
    set laststatus=2 " makes airline appear all the time
    let g:airline_theme = 'zenburn'
    let g:airline_left_sep = ''
    let g:airline_left_sep = ''
    let g:airline_right_sep = ''
    let g:airline_right_sep = ''
    " status bar
    set statusline=%F%m%r%h%w\  "fullpath and status modified sign
    set statusline+=\ %y "filetype
    set statusline+=\ %{fugitive#statusline()}
" }}}

" Backups {{{
    "If you leave a Vim process open in which you've changed file, Vim creates a "backup" file.
    " Then, when you open the file from a different Vim session, Vim knows to complain at you for trying to edit a file that is already being edited.
    " The "backup" file is created by appending a ~ to the end of the file in the current directory.
    " This can get quite annoying when browsing around a directory, so I applied the following settings to move backups to the /tmp folder.
    " backup and writebackup enable backup support. As annoying as this can be, it is much better than losing tons of work in an edited-but-not-written file.
    set backup
    set backupdir=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp
    set backupskip=/tmp/*,/private/tmp/*
    set directory=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp
    set writebackup
" }}}

" vim:foldmethod=marker:foldlevel=0

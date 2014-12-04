set nocompatible               " be iMproved
filetype off

if has('vim_starting')
  set runtimepath+=~/.vim/bundle/neobundle.vim
  call neobundle#begin(expand('~/.vim/bundle/'))
  NeoBundleFetch 'Shougo/neobundle.vim'
  call neobundle#end()
endif
" originalrepos on github
NeoBundle 'Shougo/neobundle.vim'
NeoBundle 'Shougo/vimproc', {
  \ 'build' : {
    \ 'windows' : 'make -f make_mingw32.mak',
    \ 'cygwin' : 'make -f make_cygwin.mak',
    \ 'mac' : 'make -f make_mac.mak',
    \ 'unix' : 'make -f make_unix.mak',
  \ },
\ }
NeoBundle 'Shougo/vimshell'
NeoBundle 'Shougo/unite.vim'
NeoBundle 'Shougo/neomru.vim'
NeoBundle 'scrooloose/nerdtree'
NeoBundle "Shougo/neocomplete.vim"
NeoBundle "jiangmiao/simple-javascript-indenter"
NeoBundle 'tpope/vim-fugitive'
NeoBundle 'nono/vim-handlebars'
NeoBundle 'szw/vim-tags'
NeoBundle 'kannokanno/previm'
NeoBundle 'tyru/open-browser.vim'
NeoBundle 'tpope/vim-endwise'
NeoBundle 'scrooloose/syntastic'
NeoBundle 'h1mesuke/unite-outline'
NeoBundle 'tpope/vim-surround'
NeoBundle 'kana/vim-operator-replace.git'
NeoBundle 'kana/vim-operator-user.git'
NeoBundle 'kana/vim-submode'
NeoBundle 'terryma/vim-multiple-cursors'
NeoBundle 'othree/html5.vim'
NeoBundle 'h1mesuke/vim-alignta'
NeoBundle 'itchyny/calendar.vim'
NeoBundle 'mhinz/vim-signify'

filetype plugin indent on     " required!
filetype indent on
syntax on

" 引数無しの時はNERDTreeをONに
let file_name = expand("%")
if has('vim_starting') &&  file_name == ""
    autocmd VimEnter * NERDTree ./
endif

" カーソルが外れているときは自動的にnerdtreeを隠す
function! ExecuteNERDTree()
    "b:nerdstatus = 1 : NERDTree 表示中
    "b:nerdstatus = 2 : NERDTree 非表示中

    if !exists('g:nerdstatus')
        execute 'NERDTree ./'
        let g:windowWidth = winwidth(winnr())
        let g:nerdtreebuf = bufnr('')
        let g:nerdstatus = 1

    elseif g:nerdstatus == 1
        execute 'wincmd t'
        execute 'vertical resize' 0
        execute 'wincmd p'
        let g:nerdstatus = 2
    elseif g:nerdstatus == 2
        execute 'wincmd t'
        execute 'vertical resize' g:windowWidth
        let g:nerdstatus = 1

    endif
endfunction
noremap <c-e> :<c-u>:call ExecuteNERDTree()<cr>

" neocomplete用設定
let g:neocomplete#enable_at_startup = 1
let g:neocomplete#enable_ignore_case = 1
let g:neocomplete#enable_smart_case = 1
if !exists('g:neocomplete#keyword_patterns')
	let g:neocomplete#keyword_patterns = {}
endif
let g:neocomplete#keyword_patterns._ = '\h\w*'
inoremap <expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<S-TAB>"
let neocomplete#enable_insert_char_pre=1 "インサートモード時のカーソル移動で補完されないようにする。

" 行番号を表示
set number

" vimの文字列コピー時にクリップボードに値を入れる
set clipboard+=unnamed

"" js用インデント
" この設定入れるとshiftwidthを1にしてインデントしてくれる
let g:SimpleJsIndenter_BriefMode = 1
" この設定入れるとswitchのインデントがいくらかマシに
let g:SimpleJsIndenter_CaseIndentLevel = -1

" hbsファイルにhtmlのシンタックスが効くように設定
""au BufNewFile,BufRead *.hbs set filetype=html

" html5に対応
let g:html5_event_handler_attributes_complete = 1
let g:html5_rdfa_attributes_complete = 1
let g:html5_microdata_attributes_complete = 1
let g:html5_aria_attributes_complete = 1

" インデントの設定
set tabstop=4
set shiftwidth=4
set expandtab
augroup vimrc
    autocmd! FileType perl setlocal shiftwidth=2 tabstop=2 softtabstop=2
    autocmd! FileType html setlocal shiftwidth=2 tabstop=2 softtabstop=2
    autocmd! FileType css  setlocal shiftwidth=2 tabstop=2 softtabstop=2
    autocmd! FileType ruby setlocal shiftwidth=2 tabstop=2 softtabstop=2
    autocmd! FileType eruby setlocal shiftwidth=2 tabstop=2 softtabstop=2
    autocmd! FileType yaml setlocal shiftwidth=2 tabstop=2 softtabstop=2
    autocmd! FileType javascript setlocal shiftwidth=2 tabstop=2 softtabstop=2
augroup END

set imdisable

scriptencoding utf-8
" 行末の空白文字を可視化
highlight WhitespaceEOL term=underline ctermbg=red guibg=red
au BufWinEnter * let w:m1 = matchadd("WhitespaceEOL", '\s\+$')
au WinEnter * let w:m1 = matchadd("WhitespaceEOL", '\s\+$')

" 行頭のTAB文字を可視化
highlight TabString ctermbg=red guibg=red
au BufWinEnter * let w:m2 = matchadd("TabString", '^\t+')
au WinEnter * let w:m2 = matchadd("TabString", '^\t+')

" 全角スペースの表示
highlight ZenkakuSpace term=underline ctermbg=LightMagenta guibg=LightMagenta
au BufWinEnter * let w:m3 = matchadd("ZenkakuSpace", '　')
au WinEnter * let w:m3 = matchadd("ZenkakuSpace", '　')

source $VIMRUNTIME/macros/matchit.vim

let g:vim_tags_project_tags_command = "/Applications/MacVim.app/Contents/MacOS/ctags -R {OPTIONS} {DIRECTORY} 2>/dev/null"
let g:vim_tags_gems_tags_command = "/Applications/MacVim.app/Contents/MacOS/ctags -R {OPTIONS} `bundle show --paths` 2>/dev/null"

set backupdir=$HOME/.vim-backup
set directory=$HOME/.vim-backup
set noswapfile

let g:netrw_nogx = 1 " disable netrw's gx mapping.
nmap gx <Plug>(openbrowser-smart-search)
vmap gx <Plug>(openbrowser-smart-search)


let g:unite_enable_start_insert=1
let g:unite_source_history_yank_enable =1
let g:unite_source_file_mru_limit = 200
nnoremap <silent> ,uy :<C-u>Unite history/yank<CR>
nnoremap <silent> ,ub :<C-u>Unite buffer<CR>
"nnoremap <silent> ,uf :<C-u>UniteWithBufferDir -buffer-name=files file<CR>
"nnoremap <silent> ,ur :<C-u>Unite -buffer-name=register register<CR>
nnoremap <silent> ,uu :<C-u>Unite file_mru buffer<CR>
nnoremap <silent> ,ur :<C-u>Unite file_rec/async<CR>

let g:syntastic_mode_map = { 'mode': 'active',
            \ 'active_filetypes': ['ruby'] }
let g:syntastic_ruby_checkers = ['rubocop']
" let g:syntastic_quiet_messages = {'level': 'warnings'}
"
augroup PrevimSettings
    autocmd!
    autocmd BufNewFile,BufRead *.{md,mdwn,mkd,mkdn,mark*} set filetype=markdown
augroup END

" 挿入モードでのカーソル移動
inoremap <C-j> <Down>
inoremap <C-k> <Up>
inoremap <C-h> <Left>
inoremap <C-l> <Right>
inoremap <C-a> <HOME>
inoremap <C-e> <END>

let g:unite_split_rule = 'botright'
noremap ,u <ESC>:Unite -vertical -winwidth=40 outline<Return>

"clipboardに入らないようにする
"use black hole register
noremap c "_c
noremap C "_C

" ESC2回でハイライトを消す
set hlsearch
nmap <Esc><Esc> :nohlsearch<CR>

nnoremap ; :

" yankした文字をテキストオブジェクトを使ってリプレイスできるようにする
map R  <Plug>(operator-replace)

" Window Sizeの変更モードを定義
call submode#enter_with('winsize', 'n', '', '<C-w>L', '<C-w>>')
call submode#enter_with('winsize', 'n', '', '<C-w>H', '<C-w><')
call submode#enter_with('winsize', 'n', '', '<C-w>J', '<C-w>+')
call submode#enter_with('winsize', 'n', '', '<C-w>K', '<C-w>-')
call submode#map('winsize', 'n', '', 'L', '<C-w>>')
call submode#map('winsize', 'n', '', 'H', '<C-w><')
call submode#map('winsize', 'n', '', 'J', '<C-w>+')
call submode#map('winsize', 'n', '', 'K', '<C-w>-')

" grepにptを使う
nnoremap <silent> ,g :<C-u>Unite grep:. -buffer-name=search-buffer -no-quit -winheight=10<CR>
if executable('pt')
  let g:unite_source_grep_command = 'pt'
  let g:unite_source_grep_default_opts = '--nogroup --nocolor'
  let g:unite_source_grep_recursive_opt = ''
endif

let g:calendar_google_calendar = 1
let g:calendar_google_task = 1

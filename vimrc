set nocompatible               " be iMproved
filetype off


if has('vim_starting')
  set runtimepath+=~/.vim/bundle/neobundle.vim
  call neobundle#rc(expand('~/.vim/bundle/'))
endif
" originalrepos on github
NeoBundle 'Shougo/neobundle.vim'
NeoBundle 'Shougo/vimproc'
NeoBundle 'Shougo/vimshell'
NeoBundle 'Shougo/unite.vim'
NeoBundle 'scrooloose/nerdtree'
NeoBundle "Shougo/neocomplete.vim"
NeoBundle "jiangmiao/simple-javascript-indenter"
NeoBundle 'tpope/vim-fugitive'
NeoBundle 'nono/vim-handlebars'
NeoBundle 'szw/vim-tags'
NeoBundle 'kannokanno/previm'
NeoBundle 'tyru/open-browser.vim'
NeoBundle 'tpope/vim-endwise'

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

" インデントの設定
set tabstop=4
set shiftwidth=4
set expandtab

augroup vimrc
    autocmd! FileType perl setlocal shiftwidth=4 tabstop=2 softtabstop=2
    autocmd! FileType html setlocal shiftwidth=2 tabstop=2 softtabstop=2
    autocmd! FileType css  setlocal shiftwidth=4 tabstop=2 softtabstop=2
    autocmd! FileType ruby setlocal shiftwidth=2 tabstop=2 softtabstop=2
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

let g:netrw_nogx = 1 " disable netrw's gx mapping.
nmap gx <Plug>(openbrowser-smart-search)
vmap gx <Plug>(openbrowser-smart-search)

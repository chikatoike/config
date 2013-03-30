" vim:ts=8 sts=2 sw=2 tw=0 foldmethod=marker:

if !has('gui') " GVim only
  finish
endif

if has('gui') && !has('unix')
  set encoding=utf-8
  set termencoding=cp932
endif

" http://d.hatena.ne.jp/thinca/20090806/1249492331
scriptencoding utf-8
set shellslash

"
" NOTE: このファイルは .vim ディレクトリと同じ階層に配置すること
"
augroup MyAutoCmd
  autocmd!
augroup END

" emacs {{{
command! EmacsOpen silent execute '! start' expand('~/software/emacs/bin/emacsclientw.exe') '-n +' . line('.') expand('%:p')
" }}}

" Sublime Text2 {{{
command! SublimeOpen silent execute '! start "" "' . expand('$PROGRAMFILES/Sublime Text 2/sublime_text.exe') . '"' expand('%:p') . ':' . line('.')
nnoremap [Screen]<C-z> :<C-u>SublimeOpen<CR>
" }}}

command! -nargs=* Start silent ! start .
command! -nargs=1 BackupSVN execute '!python' expand('$DROPBOX_PATH/home/tools/hot-backup.py') '--num-backups=16 --archive-type=zip' <q-args> 'D:/backup'

" Windows command {{{
command! -nargs=* Mount execute '!subst Y:' (<q-args> !=# '' ? <q-args> : getcwd())
command! -nargs=* Unmount execute '!subst /D' (<q-args> !=# '' ? <q-args> : fnamemodify(getcwd(), repeat(':h', 32)))
command! -nargs=* NetMount !net use S: <args>
command! -nargs=* NetUnmount !net use <args>: /delete
" }}}

" Setup {{{
if has('vim_starting')
  let g:default_env_path = $PATH
endif

let s:is_win = has('win32') || has('win64')
let s:config_dir = 0

let $TMP = $TMP !=# '' ? $TMP : '/tmp'
let $DROPBOX_PATH = $DROPBOX_PATH !=# '' ? $DROPBOX_PATH : expand('$HOME/Dropbox')

let $DOTVIM = expand('<sfile>:p:h') . '/.vim'
let $CONFIG = expand('$DOTVIM/config')
let $VIMHOME = expand('<sfile>:p:h')
let $VIMTEMP = expand('~/tmp/vim')

if s:is_win
  let $LANG = 'ja_JP.utf8' " Avoid Ruby encoding error 'invalid byte sequence in Windows-31J'
  let $CYGWIN = 'nodosfilewarning'
  " let $CYGWIN .= ' error_start=dumper'
  let $CHERE_INVOKING = 1 " Make starting bash with Vim's current directory.
endif

function! s:ordered_uniq(list)
  let list = a:list
  let i = 0
  while i < (len(list) - 1)
    let a = list[i]
    let list = list[: i] + filter(list[i + 1 :], 'v:val !=# a')
    let i += 1
  endwhile
  return list
endfunction

" Windows用設定 {{{
if s:is_win
  let path = [$PATH]

  let path = ['C:/MinGW/bin'] + path
  let path = ['C:/MinGW/msys/1.0/bin'] + path
  let path = ['C:/Program Files/Git/bin'] + path
  let path += ['C:/Python27']
  let path += ['C:/Python27/Scripts']
  let path += ['C:/Ruby193/bin']
  let path += ['C:/Program Files/Microsoft SDKs/Windows/v7.0A/bin']
  let path += ['C:/Program Files/Microsoft F#/v4.0']
  let path += ['C:/Program Files/Growl for Windows']
  let path += ['C:/Windows/Microsoft.NET/Framework/v4.0.30319']
  " let path += [expand('$USERPROFILE/AppData/Roaming/Sublime Text 2/Packages/SublimeClang')]
  let path += [expand('$DROPBOX_PATH/windows/software/bin')]
  let path += [expand('$DROPBOX_PATH/windows/software/bin/bat')]

  let $PATH = join(path, ';')

  " migemo.dllへのパスを$PATHに追加
  let $PATH .= ';' . join(split(globpath(&runtimepath, 'plugin/migemo.vim'), '\n'), ';')

  let $PATH = join(s:ordered_uniq(split($PATH, ';')), ';')
endif
" }}}

command! -nargs=+ -bang VimrcStarting
      \  if <bang>has('vim_starting')
      \|  execute <q-args>
      \| endif

" }}}

" Disable plugins {{{
" Kaoriya版対策
if has('kaoriya')
  let g:plugin_autodate_disable  = 1 " $VIMRUNTIME/plugin/autodate.vim
  let g:plugin_dicwin_disable = 1 "$VIMRUNTIME/plugin/dicwin.vim
endif

let g:loaded_alternateFile = 1
" }}}

" runtimepath {{{
if has('vim_starting')
  set runtimepath^=$DOTVIM
  set runtimepath+=$DOTVIM/after
  " .vim/configは.vim/bundleより優先する
  set runtimepath^=$DOTVIM/config
  set runtimepath+=$DOTVIM/config/after

  if !s:is_win " helpfile for linux.
    set runtimepath+=$DROPBOX_PATH/windows/software/vim73-kaoriya-win32/plugins/vimdoc-ja
  endif
endif
" }}}

" neobundle.vim {{{
filetype off
if has('vim_starting')
  set runtimepath+=$DOTVIM/vundle/neobundle.vim
endif
call neobundle#rc(expand('$DOTVIM/vundle/'))

" bundles {{{
NeoBundle 'Shougo/neobundle.vim'
" NeoBundleLocal $DOTVIM/bundle
" NeoBundleLocal $DOTVIM/dev

" test
NeoBundleLazy 'tyru/eskk.vim'
NeoBundleLazy 'tyru/skk.vim'
NeoBundleLazy 'thinca/vim-painter'

" filetype
NeoBundle 'ciaranm/detectindent'
" NeoBundle 'Rykka/riv.vim' " NOTE: <C-e>をprefixに使っている
NeoBundle 'ifdef-highlighting'
" NeoBundle 'Rip-Rip/clang_complete'
NeoBundleLazy 'davidhalter/jedi-vim'

" filetypes
NeoBundleLazy 'osyo-manga/vim-watchdogs'
NeoBundleLazy 'osyo-manga/shabadou.vim'
NeoBundleLazy 'scrooloose/syntastic'

" colorschemes
NeoBundle 'marcus/vim-mustang'
NeoBundle 'tomasr/molokai'
NeoBundle 'gilsondev/vim-monokai'

" textobj-user
NeoBundle 'kana/vim-textobj-user'
NeoBundle 'kana/vim-operator-user'
NeoBundle 'kana/vim-surround'
" NeoBundle 'thinca/vim-textobj-between'
NeoBundleLazy 'thinca/vim-textobj-comment', {
      \ 'autoload': {'mappings': '<Plug>(textobj-comment-'}
      \ }
omap ic <Plug>(textobj-comment-i)
xmap ic <Plug>(textobj-comment-i)
omap ac <Plug>(textobj-comment-a)
xmap ac <Plug>(textobj-comment-a)

NeoBundle 'kana/vim-textobj-function'
NeoBundle 'kana/vim-textobj-indent'
" NeoBundle 'kana/vim-textobj-syntax'
NeoBundle 'sgur/vim-textobj-parameter'
NeoBundle 'http://www.sopht.jp/repos/hgweb.cgi/vim-textobj-xbrackets/', {'type': 'hg'}

" motion
" NeoBundle 'deris/parajump'
NeoBundle 'ujihisa/camelcasemotion'

" jump
NeoBundle 'kana/vim-altr'

" edit
" NeoBundle 'kana/vim-smartchr'
NeoBundle 'kana/vim-smartinput'
NeoBundle 'h1mesuke/vim-alignta'
" NeoBundle 'taku-o/vim-vis'
NeoBundle 'thinca/vim-partedit'
NeoBundle 'thinca/vim-qfreplace'
NeoBundle 'thinca/vim-visualstar'
NeoBundle 'tpope/vim-repeat'
NeoBundle 'tpope/vim-endwise'
NeoBundle 'tyru/caw.vim'
" NeoBundle 'tyru/operator-camelize.vim'
NeoBundleLazy 'scrooloose/nerdcommenter'

" completion
NeoBundle 'Shougo/neosnippet'

" Vim script
NeoBundle 'thinca/vim-ambicmd'
NeoBundleLazy 'thinca/vim-editvar'
NeoBundle 'thinca/vim-prettyprint'
NeoBundle 'thinca/vim-quickrun'
NeoBundleLazy 'mattn/webapi-vim'

" special buffer
NeoBundle 'mattn/vim-metarw'
NeoBundleLazy 'Shougo/vinarise'
NeoBundleLazy 'Shougo/vimfiler'

" utility
NeoBundleLazy 'tyru/restart.vim'
NeoBundle 'tyru/open-browser.vim'

" appearance
NeoBundle 'Lokaltog/vim-powerline'
NeoBundle 'Shougo/echodoc'

" ctrlp.vim
NeoBundleLazy 'kien/ctrlp.vim'

" unite sources
NeoBundle 'Shougo/unite.vim'
NeoBundle 'Shougo/unite-session'
NeoBundle 'Shougo/unite-outline'
" NeoBundle 'pasela/unite-webcolorname'
" NeoBundle 'aereal/unite-strftime_format'

NeoBundle 'MasterKey/OmniCppComplete' " modified
NeoBundle 'Shougo/fakecygpty'
NeoBundle 'Shougo/neocomplcache'
NeoBundle 'Shougo/vimshell'
NeoBundle 'Shougo/unite-build' " modified
NeoBundle 'fuenor/qfixhowm' " modified
NeoBundleLazy 'jceb/vim-orgmode'
" NeoBundle 'https://github.com/mattn/vimplenote-vim' " modified
NeoBundle 'thinca/vim-localrc' " modified
NeoBundle 'vim-jp/vital.vim'
NeoBundle 'Shougo/vimproc'

command! -nargs=* UpdateBundle1 FrequentlyUpdatedBundles Unite2 -no-start-insert neobundle
command! -nargs=* UpdateBundle2 FrequentlyUpdatedBundles Unite2 -no-start-insert neobundle/update:!
command! -nargs=* FrequentlyUpdatedBundles <args>
      \:vital.vim
      \:vimshell
      \:neocomplcache
      \:unite.vim
      \:unite-session
      \:neobundle.vim
      \:vim-quickrun
      \:syntastic
      \:vim-powerline
      \:vim-smartinput
      \:ctrlp.vim
      \:vimfiler
      \:vim-watchdogs
      \:shabadou.vim
" }}}

filetype plugin indent on     " required!

if has('vim_starting')
  syntax on
  " runtime! ftdetect/*.vim " TODO filetype plugin on してもなぜか読み込まれない
endif

" function! s:is_sourced(bundle_name)
"   return neobundle#is_sourced(a:bundle_name)
" endfunction
" }}}

" Common variables {{{
let g:vimrc_noteft = 'org'
" http://unsigned.g.hatena.ne.jp/Trapezoid/20110203/1296718907
let g:vimrc_prompt_shell = '✘╹◡╹✘> '

set suffixes&
set suffixes-=.h
set suffixes+=~
set suffixes+=ETAGS
set suffixes+=.shc,.shg
set suffixes+=.o,.exe,.dll,.bak,.swp,.swo
set suffixes+=.lnk,.bak,.obj,.gcno,.gcda,.pyc,.i,.svn-base,.omc,.plist
set wildignore=

let g:vimrc_file_ignore_pattern = join([
      \'\%(^\|/\)\.\.\?$',
      \'\%(' . join(split(escape(&suffixes, '~.'), ','), '\|') . '\)$',
      \'vital/_\x\+',
      \ ], '\|')

" mru ignore
set suffixes+=.jax,.gcov

let g:vimrc_directory_mru_ignore_pattern =
      \'\%(^\|/\)\.\%(git\|bzr\|svn\)\%($\|/\)' .
      \'\|^\%(\\\\\|/mnt/\|/media/\|/temp/\|/tmp/\|/private/var/folders/\)'

let g:vimrc_file_mru_ignore_pattern = join([
      \'\%(' . join(split(escape(&suffixes, '~.'), ','), '\|') . '\)$',
      \ g:vimrc_directory_mru_ignore_pattern,
      \ ], '\|')

let &grepprg = executable('jvgrep') ? 'jvgrep' : 'grep -n'
let g:vimrc_grep_command = 'C:/cygwin/bin/grep.exe' " TODO: jvgrepで再帰grepできない
let g:vimrc_grep_ignore_pattern = join([
      \ g:vimrc_file_ignore_pattern,
      \'\.designer\|@\d\+',
      \'\%(^\|/\)tags\%(-\a*\)\?$',
      \ ], '\|')
      " \'\~$\|\.\%(o\|exe\|dll\|bak\|sw[po]\)$\|' .
      " \'\%(^\|/\)\.\%(hg\|git\|bzr\|svn\)\%($\|/\)\|' .

set suffixes+=.h " restore

let g:unite_data_directory = expand('~/.unite')
let g:vimshell_temporary_directory = expand('~/.vimshell')
"}}}

" vital.vim {{{
function! s:vital(module)
  return vital#of('vital').import(a:module)
endfunction

function! s:uniq(list, ...)
  let list = a:0 ? map(copy(a:list), printf('[v:val, %s]', a:1)) : copy(a:list)
  let i = 0
  let seen = {}
  while i < len(list)
    let key = string(a:0 ? list[i][1] : list[i])
    if has_key(seen, key)
      call remove(list, i)
    else
      let seen[key] = 1
      let i += 1
    endif
  endwhile
  return a:0 ? map(list, 'v:val[0]') : list
endfunction

" Force set when exist key.
function! s:set_dictionary(variable, keys, pattern)"{{{
  for key in split(a:keys, ',')
    let a:variable[key] = a:pattern
  endfor
endfunction"}}}

function! s:extend_dictionary(variable, keys, pattern)"{{{
  for key in split(a:keys, ',')
    if !has_key(a:variable, key)
      let a:variable[key] = a:pattern
    else
      call extend(a:variable[key], a:pattern, 'force')
    endif
  endfor
endfunction"}}}
" }}}

" Utility functions {{{
" vital#__latest__#set_default はスクリプトローカル変数には使用できない(__latest__.vimのスクリプトローカル変数になってしまう)
function! s:set_default(var, val)  "{{{
  if !exists(a:var) || type({a:var}) != type(a:val)
    let {a:var} = a:val
  endif
endfunction"}}}

function! s:create_dict(var)
  call s:set_default(a:var, {})
endfunction

function! s:ignore_c(expr)
  execute a:expr
  redraw
  return "g\<ESC>"
endfunction

" }}}

" 文字コードの自動認識 {{{
" http://www.kawaz.jp/pukiwiki/?vim#cb691f26
if !has('kaoriya')
  if &encoding !=# 'utf-8'
    set encoding=japan
    set fileencoding=japan
  endif
  if has('iconv')
    let s:enc_euc = 'euc-jp'
    let s:enc_jis = 'iso-2022-jp'
    " iconvがeucJP-msに対応しているかをチェック
    if iconv("\x87\x64\x87\x6a", 'cp932', 'eucjp-ms') ==# "\xad\xc5\xad\xcb"
      let s:enc_euc = 'eucjp-ms'
      let s:enc_jis = 'iso-2022-jp-3'
      " iconvがJISX0213に対応しているかをチェック
    elseif iconv("\x87\x64\x87\x6a", 'cp932', 'euc-jisx0213') ==# "\xad\xc5\xad\xcb"
      let s:enc_euc = 'euc-jisx0213'
      let s:enc_jis = 'iso-2022-jp-3'
    endif
    " fileencodingsを構築
    if &encoding ==# 'utf-8'
      let s:fileencodings_default = &fileencodings
      let &fileencodings = s:enc_jis .','. s:enc_euc .',cp932'
      let &fileencodings = &fileencodings .','. s:fileencodings_default
      unlet s:fileencodings_default
    else
      let &fileencodings = &fileencodings .','. s:enc_jis
      set fileencodings+=utf-8,ucs-2le,ucs-2
      if &encoding =~# '^\(euc-jp\|euc-jisx0213\|eucjp-ms\)$'
        set fileencodings+=cp932
        set fileencodings-=euc-jp
        set fileencodings-=euc-jisx0213
        set fileencodings-=eucjp-ms
        let &encoding = s:enc_euc
        let &fileencoding = s:enc_euc
      else
        let &fileencodings = &fileencodings .','. s:enc_euc
      endif
    endif
    " 定数を処分
    unlet s:enc_euc
    unlet s:enc_jis
  endif
  " 日本語を含まない場合は fileencoding に encoding を使うようにする
  if has('autocmd')
    function! AU_ReCheck_FENC()
      if &fileencoding =~# 'iso-2022-jp' && search("[^\x01-\x7e]", 'n') == 0
        let &fileencoding=&encoding
      endif
    endfunction
    autocmd MyAutoCmd BufReadPost * call AU_ReCheck_FENC()
  endif
  " 改行コードの自動認識
  if has('win32')
    set fileformats=dos,unix,mac
  else
    set fileformats=unix,dos,mac
  endif
  " □とか○の文字があってもカーソル位置がずれないようにする
  if exists('&ambiwidth')
    set ambiwidth=double
  endif
endif
" }}}

" オプション設定
"general
set hidden
setglobal path&
setglobal tags&
setglobal tags+=tags;,tags.ext;*/norti/tags;
set winaltkeys=no
nnoremap <silent> <M-Space> :simalt ~<CR>

"mouse->visual
set selectmode=key

"edit
set ignorecase
set smartcase
set showmatch
set tabstop=4 " TODO setglobalだと反映されない？
set shiftwidth=4
setglobal shiftwidth=4
"8進数を無効にする。<C-a>,<C-x>などに影響する。
setglobal nrformats-=octal
"日本語の行の連結時には空白を入力しない。
setglobal formatoptions+=mM
setglobal autoindent
setglobal smartindent
set backspace=eol,start,indent

"visual, appearance
if has('vim_starting') " Keep window size on reloading .vimrc
  set guioptions&
endif
if !has("unix")
  set guioptions-=a " Disable autoselect
endif
set guioptions-=t
set guioptions-=T " Disable toolbar
set guioptions-=e " Enable tabline.
" set guioptions+=l " Enable left scrollbar
" set guioptions-=L
" set guioptions-=r
" set guioptions-=R
" Disable GUI menu.
set guioptions-=m
let did_install_default_menus = 1
let did_install_syntax_menu = 1

set showtabline=2
set number
set nowrap
set showcmd
set cursorline
set laststatus=2
set scrolloff=3
set ruler
set display=lastline
set listchars=trail:_,extends:>,precedes:<
" set listchars+=tab:\ \
set listchars+=tab:»\
set listchars+=eol:↲ "eol:¬
let &showbreak = '>>>'
"set linebreak
" set cpoptions+=n
set cmdheight=2

" set redrawtime=2000
set updatetime=1000
let g:vimrc_updatetime = &updatetime
let g:unite_update_time = 300
" let g:vimshell_interactive_update_time = 400
" let g:neocomplcache_cursor_hold_i_time = 200

nnoremap zz <C-l>
noremap <C-l> zz

" search
set incsearch
set hlsearch

" 補完・履歴
set viminfo='1000,<50,s10,h
set viminfo+=:200,/500,@500
" let &viminfo .= ','.join(map(split('AB' . 'EFGHIJKLMNOPQRSTUVWXYZ', '\zs'), "printf('r%s:', v:val)"), ',')
set history=1000
set wildignorecase
set wildmenu
set wildmode=full
set wildoptions=tagfile
" set noshowfulltag
set completeopt=menu

" folding
set foldcolumn=2
set foldenable
set foldlevelstart=99
set foldmethod=marker
nnoremap zb zA

" history/backup
" TODO enable backup. http://d.hatena.ne.jp/yuitowest/20111117/1321539711
set nobackup
set nowritebackup
set backupdir-=.
set directory-=.
setglobal noswapfile

if has('persistent_undo') && has('vim_starting')
  setglobal undofile
  set undodir=$VIMTEMP
endif

if s:is_win
  " Swap file name using full path.
  set directory=$VIMTEMP//
endif

" defferedswap {{{
augroup vimrc-defferedswap
  autocmd!
  autocmd BufRead * setlocal noswapfile
  autocmd BufLeave,CursorHold * call s:swap_check()
augroup END

function! s:swap_check()
  " TODO: Don't enable &swapfile if buffer is big (:h swapfile)
  if !&swapfile
    if &modified
      setlocal swapfile
    endif
  endif
endfunction
" }}}

" Clean files created by tempname()
" Only on exiting last vim.
if s:is_win
  autocmd! MyAutoCmd VimLeave *
        \  if len(split(serverlist(), '\n')) == 1
        \|  silent !del \%TMP\%\VI*.tmp*
        \| endif
endif

autocmd MyAutoCmd Syntax * call VimrcSyntaxAfter()
function! VimrcSyntaxAfter()
  "change cursor color on ime on
  if has('multi_byte_ime')
    highlight CursorIM guifg=NONE guibg=Purple
  endif

  " if g:colors_name ==# 'monokai'
  "   " hi Normal ctermfg=231 ctermbg=235 cterm=NONE guifg=#E8E8E8 guibg=#272822
  "   highlight SpecialKey guifg=#49483e guibg=#272822 gui=NONE
  " endif
endfunction

" GUI options {{{
autocmd MyAutoCmd GUIEnter * set visualbell t_vb=

" http://vim-users.jp/2011/10/hack234/
if exists('&transparency') "&& has('vim_starting')
  augroup vimrc-transparency
    autocmd!
    autocmd FocusGained,GUIEnter * set transparency=245
    autocmd FocusLost * set transparency=150
  augroup END
endif
" }}}

" session/unite-session/restart.vim {{{
set sessionoptions=winsize,slash,unix,tabpages ",buffers
let g:restart_sessionoptions = &sessionoptions
let g:unite_source_session_options = &sessionoptions
let g:unite_source_session_enable_beta_features = 1

nnoremap <Leader>sl :UniteSessionLoad<CR>
command! -bang Restart2
      \  let $PATH = g:default_env_path
      \| NeoBundleSource restart.vim
      \| Restart<bang>
command! -bang RestartClean let g:restart_sessionoptions = '' | Restart2<bang>
command! -bang RestartCurrentTabPage let g:restart_sessionoptions = 'winsize,slash,unix' | Restart2<bang>
command! -nargs=* SessionSave execute 'UniteSessionSave <args>'

" save session on leaving vim, but not save when execute :Restart
autocmd! MyAutoCmd VimLeavePre *
      \  if count(map(range(1, bufnr('$')), 'bufexists(v:val)'), 1) >= 2
      \|  execute 'SessionSave' 'default'
      \|  execute 'SessionSave' strftime('%Y%m%d_%H%M%S')
      \| endif

" Restore recent colorscheme.
set viminfo+=!
runtime plugin/colorschemeafter.vim
command! SessionColorScheme
      \  let s:list = get(g:, 'SESSION_COLORS_NAME', [g:colors_name, &background])
      \| if g:colors_name !=# s:list[0]
      \|  let &background = s:list[1]
      \|  execute 'colorscheme' s:list[0]
      \| endif
" TODO 起動時の.gvimrcに上書きされる？
autocmd! MyAutoCmd ColorScheme * if !has('vim_starting') | let g:SESSION_COLORS_NAME = [g:colors_name, &background] | endif
" NOTE VimEnterの時点でviminfoのg:SESSION_COLORS_NAMEは復元されている
autocmd! MyAutoCmd VimEnter * nested SessionColorScheme
" }}}

" $VIMRUNTIME/mswin.vim から抜粋 {{{
vnoremap <C-x> "+x
vnoremap <C-c> "+y
nnoremap <C-v> "+P
vnoremap <C-v> "+gP

vnoremap <S-Del>    "+x
vnoremap <C-Insert> "+y
noremap  <S-Insert> "+P

noremap! <C-v>      <C-r>+
noremap! <S-Insert> <C-r>+

" Use CTRL-Q to do what CTRL-V used to do
noremap <C-q> <C-v>
nnoremap <C-s> :update<CR>
" }}}

" FileType setting {{{
" runtime/filetype.vim option
let g:ft_ignore_pat = '\.\(Z\|gz\|bz2\|zip\|tgz\|vb\|fs\|fsx\|glsl\|frag\|vert\)$'
autocmd! filetypedetect BufNewFile,BufRead *.fs,*.cls

augroup FileTypeDetect
  autocmd!
augroup END

autocmd FileTypeDetect BufNewFile,BufRead *.sublime-* setfiletype javascript
autocmd FileTypeDetect BufNewFile,BufRead *.vb,*.bas,*.cls setfiletype vb
autocmd FileTypeDetect BufNewFile,BufRead *.frag,*.vert,*.fp,*.vp,*.glsl setfiletype glsl
autocmd FileTypeDetect BufNewFile,BufRead *.fs,*.fsx setfiletype fs
autocmd FileTypeDetect BufNewFile,BufRead SCons* setlocal filetype=scons expandtab
autocmd FileTypeDetect BufNewFile *.vim setlocal fileformat=unix fileencoding=utf-8

autocmd MyAutoCmd FileType * DetectIndent
let g:detectindent_preferred_expandtab = 1

autocmd MyAutoCmd BufNewFile,BufRead * call s:set_readonly()
autocmd MyAutoCmd BufNewFile,BufRead $PROGRAMFILES/* setlocal readonly nomodifiable
autocmd MyAutoCmd BufNewFile,BufRead *@\d\+.* setlocal readonly nomodifiable
autocmd MyAutoCmd BufNewFile,BufRead *.Designer.*,*.resx setlocal readonly nomodifiable

function! s:set_readonly()
  let path = expand('<afile>:p')
  if !filereadable(path)
    return
  endif

  if !filewritable(path)
    setlocal nomodifiable
  elseif path =~? g:vimrc_grep_ignore_pattern
    setlocal readonly nomodifiable
  elseif findfile('ﾌﾞﾘｰﾌｹｰｽ ﾃﾞｰﾀﾍﾞｰｽ', '.;') !=# ''
    setlocal readonly nomodifiable
  " elseif len(localrc#search(['コピー \((\d) \)\=～']))
  "   setlocal readonly nomodifiable
  endif
endfunction
" }}}

" plugin setting {{{
source $VIMRUNTIME/macros/matchit.vim

" c.vim
let g:c_gnu = 1
unlet! g:c_no_if0
let g:c_space_errors2 = 1
let g:c_comment_strings = 1

" doxygen.vim
let g:load_doxygen_syntax = 1
" let g:doxygen_enhanced_color = 1
" let g:doxygen_end_punctuation = '[.。]'

" syntax/scheme.vim
" http://e.tir.jp/wiliki?vim%3ascheme.vim#H-xl1p5w
let g:is_gauche = 1

" syntax/sh.vim
let g:is_bash = 1

" syntax/xml.vim
let g:xml_namespace_transparent = 1
let g:xml_syntax_folding = 1

" ftplugin/html.vim
" let g:html_indent_strict = 1

" qfreplace.vim
autocmd MyAutoCmd FileType qfreplace nnoremap <buffer> <C-s> :NeoComplCacheTemporaryDisableIncludeCache update<CR>
command! -nargs=* NeoComplCacheTemporaryDisableIncludeCache
      \  let s:str = g:neocomplcache_ctags_program
      \| let g:neocomplcache_ctags_program = ''
      \| execute <q-args>
      \| let g:neocomplcache_ctags_program = s:str

" powerline.vim
let g:Powerline_theme = 'default'
let g:Powerline_colorscheme = 'default'
call Pl#Theme#InsertSegment('charcode', 'after', 'filetype')
call Pl#Theme#InsertSegment('ws_marker', 'after', 'lineinfo')
" " }}}

" Key mappings {{{
"buffer control
command! ToggleReadOnly
      \  if !&modifiable || &readonly
      \|  set modifiable noreadonly
      \| else
      \|  set nomodifiable readonly
      \| endif
nnoremap <silent> [Space]<C-q> :ToggleReadOnly<CR>
nnoremap <silent> [Space]x :sbmodified<CR>
nnoremap <silent> [Space]k :call <SID>vimrc_delete_buffer()<CR>
function! s:vimrc_delete_buffer(...) abort "{{{
  let bufnr = get(a:000, 0, bufnr('%'))
  call vimshell#util#alternate_buffer()
  execute 'bdelete' bufnr
endfunction"}}}

" next/previous move in buffer {{{
nnoremap <silent> <Plug>(next_location) :<C-u>lnext<CR>
nnoremap <silent> <Plug>(prev_location) :<C-u>lprevious<CR>
nnoremap <silent> <Plug>(next_section)  :<C-u>cnfile<CR>
nnoremap <silent> <Plug>(prev_section)  :<C-u>cpfile<CR>
nnoremap <silent> <Plug>(next_list)     :<C-u>cnewer<CR>
nnoremap <silent> <Plug>(prev_list)     :<C-u>colder<CR>
nnoremap <silent> <Plug>(next_tag)      :<C-u>tnext<CR>
nnoremap <silent> <Plug>(prev_tag)      :<C-u>tprevious<CR>
nmap     <silent> <Plug>(next_heading) ]]
nmap     <silent> <Plug>(prev_heading) [[

nmap <M-n>      <Plug>(next_location)
nmap <M-p>      <Plug>(prev_location)
nmap <M-S-n>    <Plug>(next_section)
nmap <M-S-p>    <Plug>(prev_section)
" nmap <M-r>      <Plug>(next_list)
" nmap <M-s>      <Plug>(prev_list)
nmap <M-g><M-n> <Plug>(next_tag)
nmap <M-g><M-p> <Plug>(prev_tag)

" keymap from grep-a-lot.el
nnoremap <M-g>= :QfOpen<CR>
nnoremap <M-g>- :lclose<CR>
nnoremap <M-g>_ :Cclose<CR>
nmap <M-g>]     <Plug>(next_list)
nmap <M-g>[     <Plug>(prev_list)

nnoremap <M-Left> <C-o>
nnoremap <M-Right> <C-i>
nmap <expr><M-Up>   &diff ? "[c" : "[["
nmap <expr><M-Down> &diff ? "]c" : "]]"
"}}}

" Rectangle {{{
noremap <expr> <S-M-^>     <SID>ignore_c('set virtualedit=all')
noremap <expr> <S-M-Left>  <SID>ignore_c('set virtualedit=all') . "\<Left>"
noremap <expr> <S-M-Right> <SID>ignore_c('set virtualedit=all') . "\<Right>"
noremap <expr> <S-M-Up>    <SID>ignore_c('set virtualedit=all') . "\<Up>"
noremap <expr> <S-M-Down>  <SID>ignore_c('set virtualedit=all') . "\<Down>"
" }}}

" window/tabpage {{{
noremap <silent> <C-w>q     :<C-u>close<CR>
noremap <silent> <C-w><C-q> :<C-u>close<CR>

" split window
" Keeping current window and current location-list-window.
" windowを分割した後に戻って、ウィンドウと現在表示されているlocation-list-windowが紐付けされた状態にする
nnoremap <silent> <C-w>s :belowright split \| wincmd p<CR>
nnoremap <silent> <C-w>v :belowright vsplit \| wincmd p<CR>
nmap     <C-w><C-s> <C-w>s
nmap     <C-w><C-v> <C-w>v

" vertical gf/tab gf
nmap     <C-w><C-t> <C-w>gF
nnoremap <C-w><C-b> :vertical wincmd f<CR>

" タブ移動
nnoremap <silent> zh :tabprevious<CR>
nnoremap <silent> zl :tabnext<CR>
nnoremap <silent> zH :<C-u>execute 'tabmove' range(tabpagenr('$'))[tabpagenr() - 2]<CR>
nnoremap <silent> zL :<C-u>execute 'tabmove' (tabpagenr() % tabpagenr('$'))<CR>
nnoremap <silent> Zl zl
nnoremap <silent> Zh zh
nnoremap <silent> ZL zL
nnoremap <silent> ZH zH

" close tabpage
" NOTE: qが閉じる機能に割り当てられているとき、そのウィンドウをすべて閉じる。
" WARNING: windoでウィンドウを閉じてはいけないが、大丈夫だ、問題ない。
" nnoremap Q :windo normal q<CR>:tabprevious \| execute 'tabclose' ((tabpagenr() + 1) % (tabpagenr('$') + 1))<CR>
"}}}

"command line emacs keymap {{{
cnoremap <C-a> <Home>
cnoremap <C-f> <Right>
cnoremap <C-b> <Left>
cnoremap <M-b> <S-Left>
cnoremap <M-f> <S-Right>
cnoremap <C-k> <C-\>e(strpart(getcmdline(), 0, getcmdpos() - 1))<CR>
"}}}

" 検索パターン自動エスケープ
cnoremap <expr> /  getcmdtype() == '/' ? '\/' : '/'
cnoremap <expr> ?  getcmdtype() == '?' ? '\?' : '?'

" Command line edit.
cmap <expr> <M-w> getcmdtype() == '@' ? "\<M-B>" : "\<M-W>"
cnoremap <M-B> <C-\>e(getcmdline() =~# '^\\[b<]' ?  getcmdline()[2 : -3] : '\b' . getcmdline() . '\b')<CR>
cnoremap <M-W> <C-\>e(getcmdline() =~# '^\\[b<]' ?  getcmdline()[2 : -3] : '\<' . getcmdline() . '\>')<CR>
cnoremap <M-q> <C-\>e(getcmdline() =~# '^[\"']'  ?  getcmdline()[1 : -2] : '"' . getcmdline() . '"')<CR>
cnoremap <M-q> <C-\>e(text#surround('', "[\"']\r[\"']", getcmdline()))<CR>
cnoremap <M-r> <C-\>e(getcmdline() =~# '^\\V' ? substitute(getcmdline(), '^\\V', '', '') : '\V' . getcmdline())<CR>

" NOTE: <M-w>は "÷"と一致してしまう(&encoding依存)
" }}}

" diff {{{
nnoremap <silent> du :diffupdate<CR>
nnoremap <silent> dq :if &diff \| diffoff! \| execute 'windo let &l:foldcolumn = &g:foldcolumn' \| endif<CR>

" partedit/diff.vim
vnoremap <Leader>d1 :ParteditDiff1<CR>
vnoremap <Leader>d2 :ParteditDiff2<CR>

" partedit.vim
vnoremap <Leader>d3 :VScratch<CR>
command! -nargs=? -complete=filetype TypeScratch new | setlocal buftype=nofile noswf filetype=<args> | let b:cmdex_scratch = 1
command! -range VScratch
      \  if visualmode() ==# 'V'
      \|   <line1>,<line2>Partedit | setlocal bufhidden= | let &modifiable = getbufvar('#', '&modifiable')
      \| else
      \|   execute 'normal! gvy' | execute 'TypeScratch' getbufvar('#', '&filetype') | execute 'put! "'
      \| endif
" }}}

" Ex commands {{{
command! -nargs=? -complete=filetype SetFileType unlet! b:did_ftplugin | execute 'set filetype='.(len(<q-args>) ? <q-args> : &filetype)
" command! WriteTime execute 'write' (expand('%:t') . strftime('-%Y%m%d%H%M%S.') . expand('%:e'))
" }}}

" action {{{
command! -nargs=* -complete=file -bang Rename call unite#kinds#file#do_rename(expand('%:p'), expand(<q-args>))
" " trashした時にバッファを削除する？
" command! -nargs=* -complete=file -bang Trash call vimproc#delete_trash(expand(<q-args> !=# '' ? <q-args> : '%:p'))

command! -nargs=* -complete=customlist,unite#kinds#openable_scheme#complete
      \ Protocol lcd / | edit `='<args>:' . expand('%:p')`

" Netrw like actions
noremap  <silent> mm m
nnoremap <silent> me :<C-u>Start<CR>
nnoremap <silent> ms :<C-u>source %<CR>
nnoremap <silent> cd :<C-u>VimShell<CR>

" }}}

" Auto change current directory {{{
" NOTE: 以下のカレントディレクトリの設定を上書きするには :lcd を使用する。
autocmd MyAutoCmd BufEnter,FocusGained [^\[]* call CdBufferDir(expand("%:p:h"))
function! CdBufferDir(path)
  let path = a:path
  " TODO support scheme:/path/to/file
  " let meta_path = matchstr(path, '[^:]\{2,}:.*')
  if &buftype !=# '' && &buftype !=# 'help'
    return
  endif
  if path =~# '^\\\\.*'
    return
  endif
  if path =~# '^//.*'
    return
  endif
  if path =~# '^[F-Z]:/.*'
    return
  endif
  " if haslocaldir()
  "   return
  " endif
  if isdirectory(path)
    " TODO ローカルにする必要はないのでcdを使いたい
    " cd `=path`
    lcd `=path`
  endif
endfunction
"}}}

" grep file pattern {{{
" TODO: 整理する
" TODO: g:vimrc_grep_ignore_patternからパターンを設定する？
autocmd MyAutoCmd BufEnter * let g:MyGrep_FilePattern = s:grep_file_pattern()
function! s:grep_file_pattern()
  if get(g:, 'SessionLoad', 0)
    return
  endif
  if &buftype ==# 'nofile' || &buftype ==# 'quickfix'
    return g:MyGrep_FilePattern
  endif
  let ext = expand('%:e')
  let filetype = &filetype
  if ext ==# ''
    " return g:MyGrep_FilePattern
    if filetype ==# ''
      return '*'
    else
      let ext = filetype
    endif
  endif
  let l:ext_list = [ext]
  " call extend(l:ext_list, neocomplcache#get_source_filetypes(vimrc#filetype(1)))
  " if !has_key(g:neocomplcache_same_filetype_lists, filetype)
  "   " call extend(l:ext_list, split(g:neocomplcache_same_filetype_lists[filetype], ','), 'keep')
  "   return '*'
  " endif
  " if has_key(g:alternateExtensionsDict, ext)
  "   call extend(l:ext_list, split(g:alternateExtensionsDict[ext], ','), 'keep')
  " "   call extend(l:ext_list, split(g:alternateExtensionsDict[filetype], ','), 'keep')
  " endif
  let l:ext_list = s:uniq(l:ext_list)
  return join(map(l:ext_list, '"*." . v:val'), ' ')
endfunction
" }}}

" vinarise.vim {{{
" command! -nargs=? -complete=customlist,vinarise#complete VinariseBufferEncoding execute 'Vinarise -encoding=' . &fileencoding . ' <args>'
" }}}

" display setting {{{
" 検索ハイライト解除（Windows以外では起動時に"2c"が入力された状態になってしまう→と思ったけどそんなことはなかった）
nnoremap <silent> <Esc> :<C-u>nohlsearch \| set virtualedit=block<CR>
autocmd MyAutoCmd BufLeave * set virtualedit=block
set virtualedit=block

augroup vimrc-disp-mode
  autocmd!
  if s:is_win
    autocmd InsertEnter * if s:is_list_buf() | setlocal nocursorline | endif
    " autocmd InsertLeave * if s:is_list_buf() | setlocal cursorline | endif
    autocmd InsertLeave * let &cursorline = s:is_list_buf()
    autocmd WinEnter    * let &cursorline = s:is_list_buf()
    autocmd WinLeave    * if !&previewwindow | setlocal nocursorline | endif
  else
    setlocal nocursorline
    setglobal nocursorline
  endif
  " TODO: 長い桁数の行を含む場合はnocursorline固定にする

  if &listchars !~# 'eol:'
    set list " always set list when no eol char
  else
    set nolist
    autocmd InsertEnter * if s:is_list_buf() | call s:set_list_insert_mode() | endif
    autocmd InsertLeave * if s:is_list_buf() | setlocal nolist | endif
    autocmd CursorMoved,CursorHold * call s:set_list(1)
    autocmd BufLeave * call s:set_list(0)
    vnoremap <silent> <Esc> <Esc>:<C-u>call <SID>set_list(0)<CR>
  endif
augroup END

function! s:is_list_buf()
  return &buftype ==# '' || &buftype ==# 'acwrite'
endfunction

function! s:set_list_insert_mode()
  let line = winline()
  setlocal list

  " set listによって折り返しが発生した場合はキャンセル
  if line != winline()
    setlocal nolist
  endif
endfunction

let s:list_prevmode = ''
function! s:set_list(enable)
  " Note: CursorMovedの度にset listするとカーソル桁位置が保存されない
  if !a:enable || !s:is_list_buf()
    let s:list_prevmode = ''
    setlocal nolist
    return
  endif

  let mode = mode()
  if s:list_prevmode != mode
    " echo s:list_prevmode mode
    let s:list_prevmode = mode
    let visual = match("vV\<C-v>", mode) >= 0
    let &l:list = visual
  endif
endfunction
" }}}

" Prefix mapping {{{
map  <Space> [Space]
map [Space] <Nop>
nmap s [unite]
nmap [unite] <Nop>

nmap <M-w> [Window]
nnoremap [Window]: :
nnoremap [Window]n :tab split<CR>
nnoremap [Window]l :tabonly<CR>
nnoremap [Window]w :ls<CR>
nnoremap [Window]c :windo normal q<CR>:tabclose<CR>
nnoremap [Window]r :setlocal wrap! \| setlocal wrap?<CR>
nmap [Window]<M-n> [Window]n

" <C-z>(Screen) {{{
noremap <C-z>    <Nop>
nmap    <C-z>    [Screen]
noremap [Screen] <Nop>

nnoremap [Screen]m :Out :messages<CR>
nmap     [Screen]k     Q
nnoremap <silent> [Screen]H     :call util#tab_close(range(1, tabpagenr() - 1))<CR>
nnoremap <silent> [Screen]L     :call util#tab_close(range(tabpagenr() + 1, tabpagenr('$')))<CR>
"}}}

" <C-h> {{{
let g:QFixHowm_Key  = "[Howm]"
let g:QFixHowm_KeyB = ''
map      <C-h>     [Grep]
map      [Grep]    [Howm]
nnoremap [Howm][Howm] <Nop>
"}}}

" <C-k> {{{
nmap <C-k>     [CtrlK]
nmap [CtrlK] <Nop>
nnoremap [CtrlK]<C-b> :NeoComplCacheEditSnippets<CR>
nnoremap <silent> [CtrlK]<C-x> :<C-u>Unite snippet<CR>
" " insert method stub.
" nnoremap [CtrlK]<C-m> :<C-u>Unite snippet -input=function -immediately<CR>
"}}}
"}}}

" Function key mapping {{{
nnoremap <F1>  :help <C-r>=expand("<cword>")<CR>
inoremap <F1>  <Nop>
nmap     <F12> :Tag <C-r>=expand("<cword>")<CR>
cnoremap <F12> <C-u>Gtags -r <C-r>=expand("<cword>")<CR>

nnoremap <F9>  :Cclose<CR>
nnoremap <F10> :QfOpen<CR>
nnoremap <S-F10> :COpen<CR>

nmap <F5>   <Plug>(command-run)
nmap <F6>   <Plug>(command-compile)
nmap <F7>   <Plug>(command-compile)
nmap <C-F7> <Plug>(command-compile2)
nmap <S-F7> <Plug>(command-compile3)
nmap <S-F6> <Plug>(command-clean)
" nmap <S-F7> <Plug>(command-clear)

nmap     <Plug>(command-run)      <Plug>(quickrun)
nmap     <Plug>(command-compile)  <Plug>(command-compile)
nmap     <Plug>(command-compile2) <Plug>(command-compile)
nnoremap <Plug>(command-clean)    <Nop>
" }}}

" Search {{{
" Jump to blank line.
nnoremap <silent> [<Space> :call search('^[[:space:]{}()<>\|]*$', 'wb')<CR>
nnoremap <silent> ]<Space> :call search('^[[:space:]{}()<>\|]*$', 'w')<CR>

" Swap behavior only tag matched.
nnoremap <silent> g<C-]> :tags<CR>g]
nnoremap <silent> g]     g<C-]>
nnoremap <silent> g[     :tag<CR>
"}}}

" substitute {{{
nmap z/ :%substitute/\M<C-R>///g<left><left>
nmap <expr> c/  <SID>substitute_expr(@/, expand('<cword>'), 'gI')

function! s:substitute_expr(pattern, sub, flags)
  " help :s_flags
  return printf(":\<C-u>\<C-f>%%substitute/%s/%s/%s", a:pattern, a:sub, a:flags) . repeat("\<Left>", len(a:flags) + 1)
endfunction
"}}}

" global commands {{{
noremap  gr <Nop>

vnoremap <Tab>   :retab!<CR>
vnoremap <S-Tab> :<C-u>set expandtab! \| '<,'>retab! \| set expandtab!<CR>

" minimal implementation of grex.vim
noremap grd qaq:global//delete A<CR>
noremap gry qaq:global//yank A<CR>

noremap grD :Greg! delete<CR>
noremap grY :GreY<CR>

noremap grg :Greg<CR>
noremap grs :Gres<CR>
noremap grS :GreS<CR>
noremap gr+ :Gree @+<CR>
noremap grr :Gree getreg(v:register)<CR>
noremap gro :Gres \r<CR>
noremap grO :Gres \0\r<CR>

map     gr= :Gren<Space>

nmap <M-&> :%substitute///<Left>
vmap <M-&> :substitute///<Left>

command! -range=% DeleteTrailingWhitespace <line1>,<line2>substitute/[[:space:]　]\+$//
noremap  gr$ :DeleteTrailingWhitespace<CR>

noremap  gr, :substitute/,/\0\r/g<CR>
nnoremap gr- :SplitWithSearchPattern<CR>

command! -bang -nargs=* SplitWithSearchPattern
            \  while search(@/, 'c', line('.')) > 0
            \|  if <bang>1
            \|    execute "normal! v"
            \|    call search(@/, 'ce', line('.'))
            \|    execute "normal! c\<CR>"
            \|  else
            \|    execute "normal! i\<CR>"
            \|  endif
            \| endwhile

" command! -bang -bar -nargs=0 -range=% Gres <line1>,<line2>substitute//\0\r/g
command! -bang -bar -nargs=* -range=% Gres <line1>,<line2>substitute//<args>/g
command! -bang -bar -nargs=* -range=% Gree <line1>,<line2>substitute//\=<args>/g
" command! -bang -bar -nargs=* -range=% GreS execute '<line1>,<line2>global<bang>//substitute/.*\(' . @/ . '\).*/\1/g'
command! -bang -bar -nargs=* -range=% GreS <line1>,<line2>global<bang>//call setline(line('.'), matchstr(getline('.'), @/))
" command! -bang -bar -nargs=* -range=% GreY let @y = '' | <line1>,<line2>global<bang>//execute "normal! v:call search(@/)\<CR>\"Yy"
command! -bang -bar -nargs=* -range=% GreY let s:list = [] | <line1>,<line2>global<bang>//call add(s:list, matchstr(getline('.'), @/)) | let @+ = join(s:list, "\n")
command! -bang -bar -nargs=* -range=% Grev execute '<line1>,<line2>vimgrep/' . @/ . '/j<args> %'
command! -bang -bar -nargs=* -range=% Greg <line1>,<line2>global<bang>//<args>
command! -bang -bar -nargs=* -range=% Gren <line1>,<line2>global<bang>//execute 'normal' "<args>"
"}}}

" Range edit {{{
vnoremap grp :RangePaste<CR>
nnoremap @- :<C-u>CountNormal <C-r>=v:count1<CR><Space>
vnoremap @- :<C-u>CountNormal <C-r>=line("'>") - line("'<") + 1<CR><Space>

command! -range -nargs=* -bang RangeExecute let s:str = @/ | execute '<line1>,<line2>global<bang>/./<args>' | let @/ = s:str
command! -range -nargs=* -bang RangeNormal  <line1>,<line2>RangeExecute normal<bang> <args>
command! -range -nargs=* -bang RangePaste   <line1>,<line2>RangeExecute put +

command! -nargs=* ReverseExecute
            \  let [@a, s:str] = [join(reverse(split(eval(<q-args>), '\n')), "\n"), @a]
            \| @a
            \| let @a = s:str

" TODO @aと@=で動作が異なる？(surround.vimが@=で使えない)
command! -count=1 -nargs=* CountNormal
            \  let [@a, s:str] = [<q-args>, @a]
            \| execute "normal! <count>@a\<CR>"
            \| let @a = s:str

vmap g: :normal<C-q><Space>
" Execute visual mode command each lines.
vmap <expr> g<Bar> ":normal\<C-q>\<Space>" . (mode() ==# "\<C-v>" ? printf('%s\|', col('.')) : "0vg_")

" command! -range -nargs=* -bang RangeIndex let s:list = range(<line2> - <line1> + 1)
"       \| execute '<line1>,<line2>RangeExecute<bang> let [g:count; s:list] = s:list | <args>'
" command! -range -nargs=* -bang RangeRegister let s:list = split(@+, '\n')
"       \| execute '<line1>,<line2>RangeExecute<bang> let [@"; s:list] = s:list | <args>'
" command! -range -nargs=* -bang RangeRegisterNormal <line1>,<line2>RangeRegister normal<bang> <args>

" 順序を保ったuniq. (順序を保たなくて良いなら :sort u)
command! -bang -bar -nargs=* -range=% Uniq <line1>,<line2>delete | put! =s:uniq(split(@\", '\n'))
command! -bang -bar -nargs=* -range=% UniqWithPattern <line1>,<line2>delete
      \| put! =s:uniq(split(@\", '\n'), 'matchstr(v:val, @/) !=# \"\" ? matchstr(v:val, @/) : v:val')

command! -bang -bar -range=% Reverse <line1>,<line2>global<bang>/./execute 'move' (<line1> - 1) | let @/ = ''

" }}}

" Other edit command {{{
vmap gz :B HzjaConvert<C-q><Space>
" }}}

" Command-line window {{{
autocmd MyAutoCmd CmdwinEnter * call s:on_cmdwin_enter(expand('<afile>'))
autocmd MyAutoCmd CmdwinLeave : call histadd('cmd', getline('$'))

if has('gui_running')
  noremap <expr> : ':' . <SID>command_line_enter()
  cnoremap <expr> <Plug>(enter_cmdwin) <SID>enter_cmdwin()
  inoremap <expr> <Plug>(enter_cmdwin) ''
endif

function! s:command_line_enter()
  if !has('vim_starting')
    call feedkeys("\<Plug>(enter_cmdwin)", 'm')
  endif
  return ''
endfunction

function! s:enter_cmdwin()
  if getcmdtype() ==# ':'
    " TODO: コマンドヒストリの行が多い場合重くなる
    return "\<C-f>" . (getcmdpos() - 1) . '|a'
  else
    return ''
  endif
endfunction

let s:sourced_ambicmd = len(globpath(&runtimepath, 'autoload/ambicmd.vim'))

function! s:on_cmdwin_enter(cmdwin_char)
  let b:cmdtype = a:cmdwin_char

  nnoremap <buffer> <F1> yiw<C-c><C-\>e'help ' . @"<CR><End>
  nnoremap <buffer> q :quit<CR>
  inoremap <buffer><expr> <C-c> pumvisible() ? "\<Esc>" : "\<Esc>\<C-c>\<Right>"
  inoremap <buffer><silent> <C-g> <Esc>:quit<CR>
  nnoremap <buffer><silent> <C-g> :quit<CR>

  inoremap <buffer><silent> <C-p> <Up><End>
  inoremap <buffer><silent> <C-n> <Down><End>

  inoremap <buffer><expr><Tab>  pumvisible() ? "\<C-n>" : neocomplcache#start_manual_complete('vim_complete')
  inoremap <buffer><expr> <CR> pumvisible() ? neocomplcache#close_popup()."\<CR>" : "\<CR>"
  inoremap <buffer><silent> <C-d> <C-x><C-v><C-p>

  map <buffer> <Del> :CmdwinHistoryDelete<CR>

  if s:sourced_ambicmd
    inoremap <buffer> <expr> <Space> ambicmd#expand("\<Space>")
    inoremap <buffer> <expr> <CR>    ambicmd#expand("\<CR>")
    inoremap <buffer> <expr> !       ambicmd#expand("!")
  endif

  if exists(':NeoComplCacheAutoCompletionLength') == 2
    NeoComplCacheAutoCompletionLength 4
  endif

  " Avoid :append command syntax highlight.
  syntax sync clear
endfunction

command! -range CmdwinHistoryDelete
        \  for s:i in getline(<line1>, <line2>)
        \|  call histdel(b:cmdtype, '\V' . escape(s:i, '\'))
        \| endfor
        \| <line1>,<line2>delete _
"}}}

if has('gui_running') && len(globpath(&runtimepath, 'autoload/ambicmd.vim'))
  cnoremap <expr> <Space> ambicmd#expand("\<Space>")
  cnoremap <expr> <CR>    ambicmd#expand("\<CR>")
endif

" open-browser.vim {{{
let g:openbrowser_open_filepath_in_vim = 0
let g:vimrc_filetype_keyword = {
      \ 'autohotkey': 'AutoHotkey',
      \ 'vb': 'vb',
      \ 'c': 'C言語',
      \ 'cpp': 'C++',
      \ 'scheme': 'gauche',
      \ 'vim': 'vim',
      \ 'help': 'vim',
      \ 'python': '-python',
      \ 'tweetvim': '-twitter-search',
      \ g:vimrc_noteft : '-alc',
      \ }

vmap g<CR> <Plug>(openbrowser-open)
vmap <F2>  <Plug>(openbrowser-search)
vmap g<F2> <Plug>(openbrowser-smart-search)
nnoremap <F2> :OpenBrowserSearch <C-r>=get(g:vimrc_filetype_keyword, vimrc#filetype(1), '') . ' ' . expand("<cword>")<CR>
nnoremap <S-F2> :OpenBrowserSearch -alc <C-r>=expand("<cword>")<CR>
" }}}

" quickrun.vim {{{
call s:create_dict('g:quickrun_config')
let g:quickrun_config['_'] = {
      \   'outputter/buffer/split': '%{winwidth(0) * 2 < winheight(0) * 5 ? "topleft" . (&lines / 3) : "vertical"}',
      \   'hook/output_encode/encoding': '&termencoding',
      \ }

" Avoid conflict mapping align.vim and quickrun.vim
map <silent> <Plug>DummyForRestoreWinPosn <Plug>RestoreWinPosn

" Note: quickrun.vim won't map when already mapped to another key.
map <Leader>r <Plug>(quickrun)

command! -nargs=* QuickRunSessionNormalized
      \  let g:session = quickrun#new(<q-args>)
      \| call g:session.setup()
      \| PP g:session
command! -nargs=* QuickRunSessionLast PP g:{g:quickrun_config._.debug}

"}}}

" quickfix {{{
command! -bar Cclose
      \  let s:win = winnr()
      \| windo lclose | cclose
      \| execute s:win 'wincmd w'
command! -bar QfOpen OpenQFixWin
command! -bar COpen execute g:QFix_CopenCmd 'copen'
" }}}

" QFixGrep {{{
let g:mygrepprg = g:vimrc_grep_command
let g:MyGrepcmd_recursive = '-R'
let g:QFix_UseLocationList = 1
"let g:QFix_PreviewEnableLock = 1
"let g:QFix_DefaultPreview = 0
let g:QFix_PreviewEnable = 0
let g:QFix_Height = 10
let g:QFix_CopenCmd = 'botright'
let g:QFix_CursorLine = 0
let g:MyGrep_FilePattern = '*'
let g:MyGrep_ExcludeReg = g:vimrc_grep_ignore_pattern

"}}}

let g:QFix_DefaultUpdatetime = &updatetime
let g:QFix_PreviewUpdatetime = 0 " quickfix preview disable?

" QFixHowm"{{{
" let g:howm_fileencoding = 'cp932' " for Evernote import folder
let g:howm_fileencoding = 'utf-8'
let g:howm_fileformat   = 'dos'
let g:howm_filename = '%Y-%m/%Y-%m-%d-%H%M%S.org'
let g:QFixHowm_SearchHowmFile = '**/*.org'

let s:notedirs = [
      \ expand('$DROPBOX_PATH/unsync1/note/howm'),
      \ expand('$DROPBOX_PATH/note/howm'),
      \ ]
let g:vimrc_notedir = get(filter(copy(s:notedirs), 'isdirectory(v:val)'), 0, expand('$USERPROFILE/Desktop/note'))
let g:howm_dir = g:vimrc_notedir

" org-mode
let g:QFixHowm_FileType = 'org'
" http://sites.google.com/site/fudist/Home/qfixhowm/tips/vimwiki#TOC-Ver.3-
let g:QFixHowm_Title = '*'
let g:QFixHowm_Template = ["* %TAG%"]

let g:QFixHowm_SaveTime = -1
let g:QFixHowm_Folding = 0
let g:QFixHowm_OpenURIcmd = 'OpenBrowser %s'

" qfixmru.vim
let g:QFixMRU_IgnoreFile = '.*' " all disable QFixMRU
"}}}

" text-objects {{{
" textobj-xbrackets.vim
let g:textobj_xbrackets_surround = 0
" }}}

" textobj-lastchange {{{
call textobj#user#plugin('lastchange', {
      \   '-': {
      \     'select-a': ';' ,  '*select-a-function*': 'TextObjLastchangeA',
      \     'select-i': 'g;',  '*select-i-function*': 'TextObjLastchangeI',
      \   },
      \ })

function! TextObjLastchangeI()
  " TODO: visualmode()が必ずvになる?
  let end = getpos("']")
  let end[2] = end[2] - 1
  return [strpart(getregtype(), 0, 1), getpos("'["), end]
endfunction

function! TextObjLastchangeA()
  " TODO: visualmode()が必ずvになる?
  return [strpart(getregtype(), 0, 1), getpos("'["), getpos("']")]
endfunction
" }}}

" operator-user.vim {{{
" http://labs.timedia.co.jp/2012/10/vim-more-useful-blockwise-insertion.html
vnoremap <expr> I  <SID>force_blockwise_visual('I')
vnoremap <expr> A  <SID>force_blockwise_visual('A')

function! s:force_blockwise_visual(next_key)
  if mode() ==# 'v'
    return "\<C-v>" . a:next_key
  elseif mode() ==# 'V'
    return "\<C-v>^o$" . a:next_key
  else  " mode() ==# "\<C-v>"
    return a:next_key
  endif
endfunction
" }}}

" search {{{
nnoremap / :<C-u>set imsearch=0<CR>/<C-r>=histget("search", -v:prevcount)<CR>
" カウント指定された場合のみ別の動作にする
nnoremap <silent><expr> t (v:count == 0) ? 't' : ":<C-u>execute 'normal' (v:count * 10) . '%'\<CR>"
" }}}

" dsfcg.vim {{{
" Doxygen comment format
let g:dsfcg_enable_mapping = 1
let g:dsfcg_format_header = "/**********************************************************************/\n/**"
let g:dsfcg_format_footer = ' */'
let g:dsfcg_is_alignment_c = 0
let g:dsfcg_is_alignment_cpp = 0
let g:dsfcg_element_order = 'DAR'
let g:dsfcg_comment_words = [ ['/*', '*/'], ['//', '\n'] ]
let g:dsfcg_user_keywords = {
      \ 'defaultmsg' : " * @brief\t<"."`0`>.\n *",
      \ 'date' : strftime("%Y-%m-%d"),
      \ }
let g:dsfcg_template_argument = " * @param%inout\t%name\t%description<"."`1`>"
let g:dsfcg_template_return = " *\n * @return\t\t%description<"."`2:result`>"
let g:dsfcg_regexp_argument = '.*?[\\@]param(.+?)\s+(.+?)\s+(.*)$'
let g:dsfcg_regexp_return = '.*?[\\@]return\s*(.*)$'
"}}}

" Comment. {{{
imap <M-;> <Plug>(insert-comment)
imap <M-/> <Plug>(insert-comment2)
imap <M-?> <Plug>(insert-comment3)
map  <M-;> <Plug>(operator-comment)
omap <expr> <M-;> <SID>syntax_is_comment() ? "\<Plug>(textobj-comment-a)" : "ip"

function! s:syntax_cursor(pattern)
  let col = mode() !=# 'i' ? col('.') : max([col('.') - 1, 1])
  for id in synstack(line('.'), col)
    if synIDattr(id, 'name') =~# a:pattern
      return 1
    elseif synIDattr(synIDtrans(id), 'name') =~# a:pattern
      return 1
    endif
  endfor
  return 0
endfunction

function! s:syntax_is_comment()
  return s:syntax_cursor('.*Comment')
endfunction

inoremap <silent> <Plug>(insert-comment)  /*<Space><Space>*/<Left><Left><Left>
inoremap <silent> <Plug>(insert-comment2) /**<Space><Space>*/<Left><Left><Left>
inoremap <silent> <Plug>(insert-comment3) /**<lt><Space><Space>*/<Left><Left><Left>

command! -range QuoteSwap <line1>,<line2>substitute/["']/\=submatch(0) !=# '"' ? '"' : "'"/g

" C/C++ comment style
command! -range=% SCpp2c <line1>,<line2>substitute+//\(.*\)+/\*\1 \*/+
vnoremap <Leader>e/ y:let @" = escape(@", '/')<CR>gvp
vnoremap <Leader>e\ y:let @" = escape(@", '\')<CR>gvp
" vnoremap <Leader>r/ y:let @" = substitute(@", '\\/', '/', 'g')<CR>gvp
" vnoremap <Leader>r\ y:let @" = substitute(@", '\\\\', '\', 'g')<CR>gvp
vnoremap <Leader>s/ y:let @" = substitute(@", '\/', '\\', 'g')<CR>gvp

vmap <silent><expr> gcl "\<Plug>"."NERDCommenterAlignLeft"

" The NERD Commenter {{{
let g:NERDSpaceDelims = 1
let g:NERDMenuMode = 0
" let g:NERDLPlace = '/*'
" let g:NERDRPlace = ''
let g:NERDUsePlaceHolders = 1

call s:create_dict('g:NERDCustomDelimiters')
call s:extend_dictionary(g:NERDCustomDelimiters, g:vimrc_noteft, { 'left': '//', 'leftAlt': repeat("\t", 4).'//'})
call s:extend_dictionary(g:NERDCustomDelimiters, 'c,cpp,java', { 'left': '/**', 'right': '*/', 'leftAlt': '//', 'rightAlt': '' }) " javadoc style
" }}}

" caw.vim
let g:caw_a_sp_left = " "
let g:caw_a_sp_right = " "
let g:caw_i_align = 1
let g:caw_i_skip_blank_line = 0
let g:caw_wrap_align = 1
let g:caw_wrap_skip_blank_line = 0

" comment-out operator. {{{
" See also http://relaxedcolumn.blog8.fc2.com/blog-entry-154.html
call operator#user#define('comment', 'OperatorComment')
function! OperatorComment(motion_wiseness)
  let v = operator#user#visual_command_from_wise_name(a:motion_wiseness)
  execute 'normal! `[' . v . "`]\<Esc>"
  if a:motion_wiseness ==# 'char'
    if line("'[") == line("']")
      call NERDComment(1, 'norm')
    else
      call caw#keymapping_stub('v', 'i', 'toggle')
    endif
  elseif a:motion_wiseness ==# 'line'
    call caw#keymapping_stub('v', 'i', 'toggle')
  elseif a:motion_wiseness ==# 'block'
    call NERDComment(1, 'norm')
  endif
  " TODO
  " silent call repeat#set("\<Plug>Dsurround".char,scount) " make repeatable if repeat.vim exists.
endfunction
" }}}
" }}}

" Switching header <-> source. {{{
" vim-altr
" call altr#reset()
" echo altr#_rule_table()
nmap <M-o> <Plug>(altr-forward)
nnoremap gh <Nop>

if len(globpath(&runtimepath, 'autoload/altr.vim'))
  call altr#define('autoload/*/*/%.vim', 'plugin/*/*/%.vim')
  " call altr#define('autoload/unite/sources/%.vim', 'autoload/unite/kinds/%.vim', 'autoload/unite/filters/%.vim', 'plugin/unite/%.vim')
  call altr#define('autoload/vital/__latest__/%.vim', 'doc/vital-%.txt', 'spec/%.vim')
  call altr#define('autoload/vital/__latest__/*/%.vim', 'doc/vital-*-%.txt', 'spec/*/%.vim')
  call altr#define('doc/%.jax', '../../vim73/doc/%.txt')
  call altr#define('%.h', '%.h.rej', '%.c', '%.c.rej', '%.cpp', '%.cpp.rej')
endif
" }}}

" echodoc.vim
let g:echodoc_enable_at_startup = 1

" vimfiler.vim {{{
" TODO: vimfilerがハンドリングしてしまうパスとしないパスがある。
" 例: view://path/to/file.h
let g:vimfiler_as_default_explorer = 0 " 有効にすると起動時間が若干増える
let g:vimfiler_enable_auto_cd = 1
let g:unite_kind_file_use_trashbox = 1
"}}}

" unite.vim {{{
nmap <silent> <C-@> [unite]u

" Resume last unite.
nnoremap <silent> [unite]r :<C-u>UniteResume -no-start-insert<CR>
nnoremap <silent> [unite]R :<C-u>UniteResume -no-start-insert default2<CR>

" TODO
let s:unite_last_buffer = 0
" autocmd MyAutoCmd TabLeave *
" autocmd MyAutoCmd BufLeave \[unite\]*
autocmd MyAutoCmd BufLeave [[]unite[]]*
      \ let s:unite_last_buffer = exists('t:unite.last_unite_bufnr') ? t:unite.last_unite_bufnr : 0
autocmd MyAutoCmd TabEnter *
      \ if !exists('t:unite') | let t:unite = {'last_unite_bufnr' : s:unite_last_buffer} | endif

" nnoremap <silent> [unite]r :<C-u>execute 'UniteResume -no-start-insert' gettabvar(tabpagenr(), 'unite_last_buffer')<CR>
" autocmd MyAutoCmd BufEnter \[unite\]* let t:unite_last_buffer = s:get_unite_last_buffer()
"
" function! s:get_unite_last_buffer()
"   let last = gettabvar(tabpagenr(), 'unite_last_buffer')
"   if unite#get_context().temporary && last isnot ''
"     return last
"   endif
"   let source = get(unite#get_current_unite().sources, 0, {})
"   if get(source, 'name', '') =~# 'neobundle\/install\|neobundle\/update'
"     return last
"   endif
"   return unite#get_current_unite().buffer_name
"   " return unite#get_current_unite().bufnr
" endfunction

command! -nargs=+ -complete=customlist,unite#complete_source Unite2 UniteUserPrompt -buffer-name=default2 -profile-name=default <args>
command! -nargs=+ -complete=customlist,unite#complete_source UniteCtrlP UniteUserPrompt -update-time=100 -direction=botright -auto-resize <args>
command! -nargs=+ UniteUserPrompt execute 'Unite -prompt=' . escape(g:vimrc_prompt_shell, ' ') <q-args>

call unite#set_profile('action', 'context', {'start_insert' : 1})

autocmd MyAutoCmd FileType unite call s:filetype_unite()
function! s:filetype_unite()
  setlocal winfixheight

  nnoremap <silent><buffer><expr> <C-l> unite#do_action('tabopen')
  inoremap <silent><buffer><expr> <C-l> unite#do_action('tabopen')

  augroup vimrc-filetype-unite
    autocmd! CursorMovedI <buffer> echo getline(unite#get_current_unite().prompt_linenr)
  augroup END

  " let context = unite#get_context()
  " if context.buffer_name ==# 'action'
  "   let context.start_insert = 1
  " endif
endfunction

" unite mappings.
nnoremap <silent> [unite]f :<C-u>Unite -buffer-name=file file file/new<CR>
" nnoremap <silent> [unite]F :<C-u>UniteWithProjectDir -buffer-name=file file_rec/async<CR>
nnoremap <silent> [unite]b :<C-u>UniteCtrlP -buffer-name=buffers buffer_tab buffer<CR>
nnoremap <silent> [unite]u :<C-u>UniteCtrlP -buffer-name=recent file_mru directory_mru file file/new<CR>

" nnoremap <silent> [unite]h :<C-u>UniteWithHowmToday -buffer-name=file file file/new file_mru<CR>
nnoremap <silent> [unite]y :<C-u>Unite  -no-start-insert -buffer-name=migemo -max-multi-lines=10 history/yank register<CR>
" nnoremap <silent> [unite]l :<C-u>Unite  -buffer-name=migemo line<CR>
nnoremap <silent> [unite]n :<C-u>Unite  -buffer-name=neobundle neobundle/lazy neobundle file<CR>
nnoremap <silent> [unite]N :<C-u>Unite  -buffer-name=neobundle_log neobundle/log2<CR>
nnoremap <silent> [unite]L :<C-u>Unite  -buffer-name=neobundle neobundle/lazy<CR>
nnoremap <silent> [unite]; :<C-u>Unite2 change jump<CR>

nmap [unite]: :Unite2<C-q><Space>
nnoremap [unite]?  :Unite -buffer-name=mapping-help -input=@\  mapping output:AllMaps\ <buffer><CR>
nnoremap [unite]s? :Unite -buffer-name=mapping-help -input=!@\  output:AllMaps<CR>
nmap ? [unite]?

" Usage: :Ctags . --exclude=[pattern]
command! -nargs=* -complete=file -bang Ctags call s:vimrc_create_ctags(<bang>0, <f-args>)
command! -nargs=* -complete=file -bang CtagExclude
      \ execute 'Ctags<bang>' [<f-args>][0] join(map([<f-args>][1 :], '"--exclude=" . v:val'))

function! s:vimrc_create_ctags(create, ...) " (tags_output_dir_or_file, [target_dir, ...])
  " acceptable even if args is empty
  if a:0
    let [dir_or_file; option] = a:000
  else
    let [dir_or_file; option] = ['']
  endif

  let path = fnamemodify(dir_or_file, ':p')
  let inputs = filter(copy(option), '(isdirectory(v:val) || filereadable(v:val))')
  let option = filter(copy(option), '!(isdirectory(v:val) || filereadable(v:val))')
  call map(inputs, 'fnamemodify(v:val, ":p")')

  echo 'Creating tags file:' path
  let dir = isdirectory(path) ? path : fnamemodify(path, ':p:h')
  lcd `=path`

  if s:is_win
    " NOTE: --jcode option is only available on CTAGS日本語対応版
    let exopt = get(s:jcode, &fileencoding, '')
  else
    let exopt = ''
  endif

  let tags = isdirectory(path) ? 'tags' : fnamemodify(path, ':.')

  call map(inputs, 'fnamemodify(v:val, ":.:s?[/\\\\]$??")')
  let input = empty(inputs) ? [] : [join(inputs, "\n")]
  let L = empty(inputs) ? '' : '-L -'
  let f = isdirectory(path) ? '' : '-f ' . tags

  " echomsg join(['ctags', s:ctags_option, exopt, '--recurse', L, f] + option, ' ')
  " echomsg string(inputs)

  if filereadable(tags) || a:create
    echo call('system', [join(['ctags', s:ctags_option, exopt, '--recurse', L, f] + option, ' ')] + input)
    " if s:pathidx(getcwd(), 'D:/projects') == 0
    "   echo call('system', [join(['ctags', s:ctags_option, exopt, '--recurse', L, '-e', '-f ETAGS'] + option, ' ')] + input)
    " endif
    call s:vital('System.File').copy_file(tags, '.tags')
    echo 'Creating tags done.'
  else
    echo 'Tag file not found.'
  endif

  lcd -
endfunction

let s:ctags_option = '--extra=+q --extra=+f'
let s:jcode = {
      \ 'utf-8' : '--jcode=utf8',
      \ 'euc-jp': '--jcode=euc',
      \ 'cp932' : '--jcode=sjis',
      \ }

vnoremap <silent> [unite]f y:execute 'Unite file file/new -buffer-name=file -input='
      \ . <SID>escape_option(unite#util#substitute_path_separator(simplify(expand(@"))))<CR>
vnoremap <silent> [unite]F y:execute 'Unite file file/new -buffer-name=file -input='
      \ . <SID>escape_option(unite#util#substitute_path_separator(simplify(expand(eval(@")))))<CR>

" command! -nargs=* UniteBuffer execute 'Unite -profile-name=default -buffer-name=buffer-' . bufnr('%') <q-args>
" command! -nargs=* UniteBufferResume execute 'UniteResume -profile-name=default buffer-' . bufnr('%') <q-args>
" command! -nargs=* UniteBufferWithCursorWord execute 'UniteWithCursorWord -profile-name=default -buffer-name=buffer-' . bufnr('%') <q-args>
command! -nargs=* UniteBuffer Unite <args>
command! -nargs=* UniteBufferResume UniteResume <args>
command! -nargs=* UniteBufferWithCursorWord UniteWithCursorWord <args>

function! s:escape_option(text)
  return escape(escape(a:text, ' '), '\')
endfunction

function! s:escape_arg(text)
  return escape(escape(a:text, ' '), ':\')
endfunction
"}}}

" unite.vim alias {{{
call s:create_dict('g:unite_source_alias_aliases')
let g:unite_source_alias_aliases.file2 = {'source': 'file'}
call unite#custom_source('file2', 'ignore_pattern', '') " show all files
call unite#custom_source('file2', 'filters', ['matcher_default', 'sorter_default', 'converter_default', 'filter_ignore'])

VimrcStarting! call unite#define_source(unite#sources#alias#define())
" }}}

" unite.vim {{{
" after/ftplugin/unite.vim
let g:unite_enable_start_insert = 1
let g:unite_source_file_mru_limit = 200
let g:unite_source_directory_mru_limit = 100
let g:unite_source_grep_command = g:vimrc_grep_command
let g:unite_source_grep_default_opts = '-exclude=''\.(git|svn|hg|bzr)'''
let g:unite_source_grep_recursive_opt = '-R'

call unite#custom_source('file,file_rec', 'ignore_pattern', g:vimrc_file_ignore_pattern)
call unite#custom_source('file_mru', 'ignore_pattern', g:vimrc_file_mru_ignore_pattern)
call unite#custom_source('directory_mru', 'ignore_pattern', g:vimrc_directory_mru_ignore_pattern)
call unite#custom_source('grep', 'ignore_pattern', g:vimrc_grep_ignore_pattern)

call unite#custom_source('grep', 'max_candidates', 1000)
call unite#custom_source('file_mru', 'max_candidates', 30) " NOTE: 0を設定すると遅くなる?
call unite#custom_source('file_rec,file_rec/async', 'max_candidates', 500)
call unite#custom_source('mapping', 'max_candidates', 0)
call unite#custom_source('line', 'max_candidates', 0)

let g:unite_source_history_yank_enable = 1
" let g:unite_source_history_yank_limit = 20

" let [g:unite_cursor_line_highlight, g:unite_abbr_highlight] = ['PmenuSel', 'Normal']

"call unite#set_substitute_pattern('file', '[[:alnum:]]', '*\0', 100)
if s:is_win
  call unite#set_substitute_pattern('file', '\$\w\+', '\=escape(expand(submatch(0)), " ")', 200)  " expand environment variables
  call unite#set_substitute_pattern('file', 'g:\(\w\+\)', '\=escape(get(g:, submatch(1), submatch(0)), " ")', 190)  " expand global variables
  call unite#set_substitute_pattern('file' , '^\(.*[/\\]\)\?\zs\.\(\.\+\)\ze[^/\\]*$', '\=repeat("../", len(submatch(2)))', 210)  " ???
  " TODO:
  call unite#set_substitute_pattern('file', '^\/mnt\/dos\/\(\a\)\/', '\1:/', 200)
else
  call unite#set_substitute_pattern('file', '\$\w\+', '\=eval(submatch(0))', 200)
endif

" Fuzzy search (Drive letter shouldn't substitute wildcard.)
call unite#set_substitute_pattern('file,recent', '[[:alnum:]]\ze\([^:]\|$\)', '*\0', 100)
call unite#set_substitute_pattern('file,recent', '^\~', "\\=substitute(unite#util#substitute_path_separator($HOME), ' ', '\\\\ ', 'g')", -100)
call unite#set_substitute_pattern('file,recent', '^\~\([^\/]\)', "\\=substitute(unite#util#substitute_path_separator($HOME), ' ', '\\\\ ', 'g') . '/' . submatch(1)", 100)

let s:unite_buffer_names = 'default,buffers'
call unite#set_substitute_pattern(s:unite_buffer_names, '[^*]\ze[[:alnum:]]', '\0*', 100)
let s:unite_special_buffer = 'action,completion'
call unite#set_substitute_pattern(s:unite_special_buffer, '[[:alnum:]]', '*\0', 100)


" http://d.hatena.ne.jp/thinca/20101027/1288190498
call unite#set_substitute_pattern('file,recent', '^\\', '~/*')

" substitute M-? -> "\<M-?>"
call unite#set_substitute_pattern('mapping-help', '[Mm]-[[:graph:]]\>', "\\=eval('\"\\<'.submatch(0).'>\"')")

" http://d.hatena.ne.jp/thinca/
" デフォルトでは ignorecase と smartcase を使う
call unite#set_profile('default', 'smartcase', 1)
call unite#set_profile('default', 'ignorecase', 1)
" ファイル選択時は smartcase を使わない
call unite#set_profile('file,recent', 'smartcase', 0)
call unite#set_profile('file,recent', 'ignorecase', 1)
" }}}

" unite.vim customize {{{
call unite#custom_source('directory_mru', 'filters', ['matcher_default', 'sorter_word', 'converter_default'])

" call unite#custom_source('file', 'filters', ['matcher_default', 'sorter_default', 'converter_resolvepath'])
" call unite#custom_source('buffer', 'filters', ['matcher_default', 'sorter_default', 'converter_bufname'])
" call unite#custom_source('buffer_tab', 'filters', ['matcher_default', 'sorter_default', 'converter_bufname'])
" call unite#custom_source('bookmark', 'filters', ['converter_abbr2word', 'matcher_default', 'sorter_default', 'converter_default'])
" call unite#custom_source('action', 'filters', ['matcher_default', 'sorter_rank', 'converter_default'])

call extend(unite#kinds#common#define().action_table.yank_escape, {'is_quit': 0})
" call extend(unite#kinds#common#define().action_table.ex, {'is_quit': 0})
" }}}

" unite-outline.vim {{{
nnoremap <silent> <M-r> :<C-u>UniteBuffer outline<CR>
nnoremap <silent> [unite]o     :<C-u>UniteBufferResume -no-start-insert<CR>
nnoremap <silent> [unite]O     :<C-u>UniteBuffer -no-start-insert outline:!:filetype<CR>
nnoremap <silent> [unite]<M-o> :<C-u>UniteBuffer -no-start-insert outline:!:folding <CR>
nnoremap <silent> [unite]<C-o> m':<C-u>UniteBufferWithCursorWord outline -no-start-insert -immediately<CR>
"}}}

" unite.vim custom action {{{
function! s:openable_actions()
  let action_table = {}

  " WinMerge
  if executable(expand('$PROGRAMFILES\WinMerge\WinMergeU.exe')) || executable('WinMergeU.exe')
    let action_table.winmerge = {
          \   'is_selectable': 1,
          \ }
    function! action_table.winmerge.func(candidates)
      " TODO: modifiedなバッファもdiffできるようにする?
      let list = map(copy(a:candidates), 'v:val.action__path')

      let prev = bufnr('#')

      for i in range(len(list))
        if !filereadable(list[i]) && bufexists(list[i])
          let temp = tempname() . '.' . fnamemodify(list[i], ':e')
          execute 'buffer' list[i]
          noautocmd write! `=temp`
          let list[i] = temp
        endif
      endfor

      if prev >= 0
        execute 'buffer' prev
      endif

      let candidate = {
            \ 'action__path': expand('$PROGRAMFILES\WinMerge\WinMergeU.exe'),
            \ 'action__args': map(copy(list), 'iconv(v:val, &encoding, &termencoding)'),
            \ }
      " \ 'action__args': map(copy(a:candidates), 'iconv(v:val.action__path, &encoding, &termencoding)'),
      call unite#get_kinds('guicmd').action_table.execute.func(candidate)
    endfunction
  endif

  for [key, value] in items(action_table)
    call unite#custom_action('openable', key, value)
  endfor
endfunction
call s:openable_actions()

function! s:cdable_actions()
  let action_table = {}

  " extshell
  let action_table.extshell = {
        \ }
  function! action_table.extshell.func(candidate)
    execute g:unite_kind_openable_cd_command '`=a:candidate.action__directory`'
    " TODO: ckwをDOS窓なしで起動する
    " silent execute '!cmd /c start "" ckw'
    call vimproc#system_gui(printf('%s %s', g:vimshell_use_terminal_command, &shell))
  endfunction

  for [key, value] in items(action_table)
    call unite#custom_action('cdable', key, value)
  endfor
endfunction
call s:cdable_actions()
" }}}

" errormarker.vim {{{
if 1
  let g:errormarker_erroricon = globpath(&runtimepath, 'icons/error.bmp')
  let g:errormarker_warningicon = globpath(&runtimepath, 'icons/warning.bmp')
  " let g:errormarker_errorgroup = 'SpellBad'
  " let g:errormarker_warninggroup = 'SpellCap'
  let g:errormarker_errorgroup = ''
  " let g:errormarker_errorgroup = 'SpellLocal'
  let g:errormarker_warninggroup = ''
  let g:errormarker_warningtypes = 'wWrR' " warning, remark
endif
" }}}


" alignta.vim {{{
let g:alignta_default_arguments = '\S\+'
xmap a<Space> :Alignta<Space>
xmap a<Tab>   :Alignta --><Space>
" vnoremap <Bar> :Alignta ,<CR>
" }}}

" vimshell.vim {{{
let g:vimshell_cd_command = 'cd' " Work with CdBufferDir.
let g:vimshell_scrollback_limit = 10000

let g:vimshell_prompt = g:vimrc_prompt_shell
let g:vimshell_user_prompt = 'fnamemodify(getcwd(), ":~")'

let g:vimshell_use_terminal_command = s:is_win ? 'ckw -e' : 'gnome-terminal -e'

if s:is_win
  call s:create_dict('g:vimshell_interactive_cygwin_commands')
  let g:vimshell_interactive_cygwin_commands.gdb = 1

  call s:create_dict('g:vimshell_interactive_encodings')
  let g:vimshell_interactive_encodings.gdb = 'cp932'
  let g:vimshell_interactive_encodings.fakecygpty = 'cp932'
endif

autocmd MyAutoCmd FileType vimshell
      \ call vimshell#set_alias('vcvarsall', printf('source ''%s'' ', 'C:\Program Files\Microsoft Visual Studio 10.0\VC\vcvarsall.bat'))

" " vimshell filetype settings
autocmd MyAutoCmd FileType int-python runtime ftplugin/python.vim

command! -nargs=? Terminal call vimproc#system_gui(printf('%s %s', g:vimshell_use_terminal_command, (len(<q-args>) ? <q-args> : &shell)))
command! -nargs=? Bg call vimproc#system_gui(<q-args>)
" command! CygTerm Bg 'C:\Program Files\teraterm\cyglaunch.exe'
command! -nargs=* Sh execute 'Terminal' s:is_win ? vimproc#get_command_name('nyaos') : 'bash --login -i' <q-args>
command! -nargs=* Bash Terminal bash --login -i <args>
" }}}

" neocomplcache.vim option {{{
let g:acp_enableAtStartup = 0
let g:neocomplcache_enable_at_startup = 1
let g:neocomplcache_enable_smart_case = 0
let g:neocomplcache_enable_camel_case_completion = 0
let g:neocomplcache_enable_underbar_completion = 0
" let g:neocomplcache_min_syntax_length = 3

let g:neocomplcache_auto_completion_start_length = 3
let g:neocomplcache_manual_completion_start_length = 0
let g:neocomplcache_enable_ignore_case = 1
" let g:neocomplcache_enable_quick_match = 1
let g:neocomplcache_enable_auto_delimiter = 1
let g:neocomplcache_max_keyword_width = 100
let g:neocomplcache_max_menu_width = 50
let g:neocomplcache_release_cache_time = 60 * 60 * 3

" let g:neocomplcache_cursor_hold_i_time = 200
let g:neocomplcache_enable_cursor_hold_i = 0
let g:neocomplcache_enable_prefetch = 1
let g:neocomplcache_enable_insert_char_pre = 0

let g:neocomplcache_enable_auto_select = 0
let g:neocomplcache_enable_debug = 0

let g:neocomplcache_enable_fuzzy_completion = 1

" let g:neocomplcache_caching_limit_file_size = 0
call s:create_dict('g:neocomplcache_source_disable')
let g:neocomplcache_source_disable.tags_complete = 1
let g:neocomplcache_source_disable.include_complete = 1
let g:neocomplcache_disable_caching_file_path_pattern = g:vimrc_grep_ignore_pattern

" Define keyword pattern.
call s:create_dict('g:neocomplcache_keyword_patterns')
call s:create_dict('g:neocomplcache_text_mode_filetypes')
call s:create_dict('g:neocomplcache_omni_patterns')
let g:neocomplcache_keyword_patterns['default'] = '\h\w*'
let g:neocomplcache_text_mode_filetypes['text'] = 0

" call s:create_dict('g:neocomplcache_source_completion_length')
" let g:neocomplcache_source_completion_length['buffer_complete'] = 2
" let g:neocomplcache_source_completion_length['keyword_complete'] = 2
" let g:neocomplcache_source_completion_length['vim_complete'] = 1
" let g:neocomplcache_source_completion_length['omni_complete'] = 3 " Start vimshell omni_complete on 3 chars ('../')
" let g:neocomplcache_source_completion_length['gosh_complete'] = 3
" let g:neocomplcache_source_completion_length['filename_complete'] = 3
" let g:neocomplcache_source_completion_length['clang_complete'] = 100

" minimum syntax length.
" let g:neocomplcache_min_syntax_length = 2
" let g:neocomplcache_source_completion_length.syntax_complete = g:neocomplcache_min_syntax_length

" call s:create_dict('g:neocomplcache_quick_match_patterns')
" let g:neocomplcache_quick_match_patterns['default'] = '@'

" Examples:
call s:create_dict('g:neocomplcache_vim_completefuncs')
let g:neocomplcache_vim_completefuncs['Unite'] = 'unite#complete_source'
let g:neocomplcache_vim_completefuncs['VimShell'] = 'vimshell#complete'

call s:create_dict('g:neocomplcache_ctags_arguments_list')
" --fields にn追加
let g:neocomplcache_ctags_arguments_list['c']   = '-R --sort=1 --c-kinds=+p --fields=+iaSn --extra=+q -I __wur'
let g:neocomplcache_ctags_arguments_list['cpp'] = '-R --sort=1 --c++-kinds=+p --fields=+iaSn --extra=+q -I __wur --language-force=C++'
" }}}

" omnicppcomplete.vim {{{
let OmniCpp_ShowAccess = 1
let OmniCpp_ShowScopeInAddr = 1
let OmniCpp_ShowPrototypeInAbbr = 1 " show function parameters
" }}}

" clang_complete {{{
" http://d.hatena.ne.jp/osyo-manga/20120911/1347354707
let g:neocomplcache_force_overwrite_completefunc = 1
call s:create_dict('g:neocomplcache_force_omni_patterns')
let g:neocomplcache_force_omni_patterns.cpp = '[^.[:digit:] *\t]\%(\.\|->\)\|::'
let g:clang_complete_auto = 0
let g:clang_complete_copen = 1
let g:clang_hl_errors = 1
let g:clang_snippets = 0 " vmap <Tab>されてしまう
let g:clang_use_library = 1
" }}}

" edit/completion mappings {{{
" mappings for match.
cnoremap <expr> <C-CR> getcmdtype() == '/' ? <SID>set_match(getcmdline()) . "\<CR>" : "\<C-CR>"
" nnoremap <silent> <F3>   :call search(matcharg(1)[1], '')<CR>
" nnoremap <silent> <S-F3> :call search(matcharg(1)[1], 'b')<CR>
nnoremap <silent> <C-F3> :match<CR>

function! s:set_match(pattern)
  if a:pattern ==# ''
    match
  else
    execute printf('match NonText /%s/', a:pattern)
  endif
  return ''
endfunction
" }}}

" notepad.exe <F5>
noremap! <F5> <C-r>=strftime(input('strftime:format: ', '%Y%m%d%H%M%S'))<CR>

" inoremap <silent> <C-r>? <C-r>=text#surround('delete', "\\<\r\\>", @/)<CR>
noremap! <C-r>?     <C-r>=substitute(@/, '\\V\|\\<\|\\>', '', 'g')<CR>
" Insert OR-pattern from register.
noremap! <C-r><Bar>    <C-r>=join(split(@+), '\|')<CR>
noremap! <C-r><Bslash> <C-r>=join(split(@+), '\\|')<CR>

"}}}

"{{{ Alt key mapping.
" http://d.hatena.ne.jp/thinca/20101215/1292340358
if has('unix') && !has('gui_running')
  " Use meta keys in console.
  function! s:use_meta_keys()  " {{{
    for i in map(
    \   range(char2nr('a'), char2nr('z'))
    \ + range(char2nr('A'), char2nr('Z'))
    \ + range(char2nr('0'), char2nr('9'))
    \ , 'nr2char(v:val)')
      " <ESC>O do not map because used by arrow keys.
      if i != 'O'
        execute 'nmap <ESC>' . i '<M-' . i . '>'
      endif
    endfor
  endfunction  " }}}

  call s:use_meta_keys()
  map <NUL> <C-Space>
  map! <NUL> <C-Space>
endif
"}}}

function! s:tab_wrapper()
  if neocomplcache#sources#snippets_complete#expandable()
    return "\<Plug>(neocomplcache_snippets_jump)"
  elseif pumvisible()
    return "\<C-n>"
 "  elseif (!exists('b:smart_expandtab') || b:smart_expandtab) &&
	" \   !&l:expandtab && !search('^\s*\%#', 'nc')
 "    return repeat(' ', &l:tabstop - (virtcol('.') - 1) % &l:tabstop)
  endif
  return "\<Tab>"
endfunction
imap <silent> <expr> <Tab> <SID>tab_wrapper()

" " neocomplcache.vim mappings {{{
" inoremap <silent><expr> <Plug>(neocomplcache_snippets_expand2) NeocomplJump()
" noremap  <silent><expr> <Plug>(neocomplcache_snippets_expand2) NeocomplJump()
"
" imap <expr><C-l> NeocomplExpand("\<Plug>(neocomplcache_complete_common_string)", "")
"
" function! NeocomplExpand(pumvisible_expr, default_expr)
"   let expandable = neosnippet#expandable()
"   if expandable == 1 || expandable == 3
"     " カーソル位置にスニペットのトリガーがある
"     return "\<Plug>(neocomplcache_close_popup)\<C-g>u\<Plug>(neosnippet_expand_or_jump)\<Plug>(cancel_select_mode)"
"   elseif expandable == 2
"     " カレントバッファにスニペットのプレースホルダーを発見した
"     return pumvisible() ? a:pumvisible_expr : "\<Plug>(neocomplcache_snippets_expand2)\<Plug>(cancel_select_mode)"
"   else
"     " 見つからない
"     return pumvisible() ? a:pumvisible_expr : a:default_expr
"   endif
" endfunction
"
" function! NeocomplJump()
"   let return_to_normal = mode() ==# 'i' ? "\<C-g>u\<Esc>" : "\<Esc>"
"
"   if search(g:get_placeholder_marker_pattern(), 'cwn') == 0
"     return return_to_normal . ":call search('\\$\\($\\|\D\+\\)', '')\<CR>v"
"     " return ''
"   endif
"
"   return return_to_normal . ":call search(g:get_placeholder_marker_pattern(), 'cw')\<CR>"
"         \ . "v:\<C-u>execute 'normal! gv' | call search(g:get_placeholder_marker_pattern(), 'cwe')\<CR>c"
" endfunction
"
" function! g:get_placeholder_marker_pattern()"{{{
"   return '<`\d\+\%(:.\{-}\)\?\\\@<!`>'
" endfunction"}}}
" " }}}

" insert mode map {{{
" IME off
imap <Esc> <Esc>
inoremap <C-@> <Esc>
inoremap <C-CR> <Nop>
" }}}

" smartinput.vim {{{
call smartinput#clear_rules()
call smartinput#define_default_rules()

let g:vimrc_c_family = ['c', 'cpp', 'cs', 'java', 'javascript']
call smartinput#define_rule({'at': '\%#\_s*)', 'char': ')', 'input': ')'})
call smartinput#define_rule({'at': '\%#\_s*}', 'char': '}', 'input': '}'})
" "\c" is dummy pattern. It means extending "at" chars for increase rule priority.
call smartinput#define_rule({'at': '\%#\s*)\c', 'char': ')', 'input': '<C-r>=smartinput#_leave_block('')'')<Enter><Right>'})
call smartinput#define_rule({'at': '\%#\s*}\c', 'char': '}', 'input': '<C-r>=smartinput#_leave_block(''}'')<Enter><Right>'})

" "=" -> "= {|};"
call smartinput#define_rule({'at': '=\s*\%#', 'char': '{', 'input': '{};<Left><Left>', 'filetype': g:vimrc_c_family})
" "func" -> "func(|);"
call smartinput#define_rule({'at': '\w\+\%#$', 'char': '(', 'input': '();<Left><Left>', 'filetype': g:vimrc_c_family})

" 既に閉じ括弧がある場合は自動で閉じない TODO 括弧が入れ子になったとき動作しない
call smartinput#define_rule({'at': '\%#\_s*)', 'char': '(', 'input': '<C-r>=VimrcSmartInputOpenParen("(", ")")<CR>'})
call smartinput#define_rule({'at': '\%#\_s*}', 'char': '{', 'input': '<C-r>=VimrcSmartInputOpenParen("{", "}")<CR>'})
function! VimrcSmartInputOpenParen(open, close)
  let open_line = line('.')
  let close_line = search('\_s*' . a:close, 'cenW')
  if open_line != close_line
    if matchstr(getline(open_line), '^\s\+') ==# matchstr(getline(close_line), '^\s\+') " is indent level same?
      return a:open
    endif
  endif
  return a:open . a:close . "\<Left>"
endfunction

" smartinput.vim filetype:vim
call smartinput#define_rule({'at': '\\\%#', 'char': '(', 'input': '(\)<Left><Left>', 'filetype': ['vim']})

" Context specific rule
call smartinput#define_rule({'at': '\<\(case\s\+\k\+\|default\)\s*:\%#$', 'char': '<Enter>',
      \ 'input': '<Enter><Enter>break<C-q>;<Up><Esc>cc', 'filetype': g:vimrc_c_family}) " case X:<CR> -> break;
call smartinput#define_rule({'at': '\<augroup\s\+\S\+\s*\%#$', 'char': '<Enter>',
      \ 'input': '<Enter><Enter>augroup END<Up><Esc>cc', 'filetype': ['vim']}) " augroup X<CR> -> augroup END
call smartinput#define_rule({'at': '.*@param\(\[\|\]\|\t\|\w\)\+.*\%#$', 'char': '<Enter>',
      \ 'input': '<C-r>=SmartInputDoxyComment()<CR>', 'filetype': g:vimrc_c_family}) " * @param[in] X<CR> -> \n* @param[in] X
function! SmartInputDoxyComment()
  return "\<CR>\<Esc>cc0\<C-d>" . matchstr(getline('.'), '.*@param\(\[\|\]\|\t\|\w\)\+')
endfunction

call smartinput#define_rule({'at': '^\s*>>>.*\%#$', 'char': '<Enter>', 'input': '<Enter>>>> ', 'filetype': ['python']}) " continue doctest
call smartinput#define_rule({'at': '^\s*\.\.\..*\%#$', 'char': '<Enter>', 'input': '<Enter>...<Tab><Tab>', 'filetype': ['python']}) " continue doctest

" _T("") for support multibyte string literal
call smartinput#define_rule({'at': '_("\%#")', 'char': '<BS>', 'input': '<Right><Right><BS><BS><BS><BS><BS>'}) " TODO
call smartinput#define_rule({'at': '"\%#"', 'char': '<BS>', 'input': '<BS><Del>'})
call smartinput#define_rule({'at': '\%#', 'char': '"', 'input': '<C-r>=VimrcSmartInputCPPStringLiteral()<CR>', 'filetype': ['c', 'cpp']})
function! VimrcSmartInputCPPStringLiteral()
  " バッファ中で既に_T("")が使われているときのみ
  if !s:syntax_cursor('^\(cBlock\|cParen\)$') || !search('_T("', 'cn')
    return '"'
  endif
  return "_T(\"\")\<Left>\<Left>"
endfunction

let g:smartinput_no_default_key_mappings = 1
call smartinput#map_trigger_keys() " for .vimrc reloading
" }}}

" neosnippet {{{
let g:neosnippet#snippets_directory = join(split(globpath(&runtimepath, 'config/snippets'), '\n'), ',')
call s:set_default('g:snips_author_name', '')

" simple template
" NOTE: should be ignored special buffers.
autocmd MyAutoCmd BufNewFile *
      \  if !has('vim_starting') && expand('<afile>:t') !~# '[\[\]*]'
      \|  execute 'Unite snippet -immediately -no-empty -input=bufnewfile'
      \|  stopinsert
      \| endif

"}}}

" vcs status {{{
command! GitDiff drop [gitdiff]
command! HgDiff  drop [hgdiff]
command! SvnDiff drop [svndiff]

autocmd MyAutoCmd BufReadCmd [[]gitdiff[]] call s:show_vcs_status(['git status', 'git diff'])
autocmd MyAutoCmd BufReadCmd [[]hgdiff[]]  call s:show_vcs_status(['hg status' , 'hg diff' ])
autocmd MyAutoCmd BufReadCmd [[]svndiff[]] call s:show_vcs_status(['svn status', 'svn diff'])

function! s:show_vcs_status(commands)
  setlocal noreadonly modifiable
  lcd %:p:h
  silent execute '0read!' a:commands[0]
  for cmd in a:commands[1 :]
    silent execute '$read!' cmd
  endfor
  cd -

  silent %substitute/\r//ge
  setlocal readonly nomodifiable

  setlocal syntax=git
  runtime! ftplugin/diff_log.vim

  " Back to last position.
  silent! normal! `"
endfunction
" }}}

" vcs command {{{
command! -nargs=* -complete=file Hg  Bang hg    <args> -hook/output_encode/encoding &termencoding
command! -nargs=* -complete=file Git Bang git   <args> -hook/output_encode/encoding &termencoding
command! -nargs=* -complete=file Svn Bang svn   <args> -hook/output_encode/encoding &termencoding
" }}}

" git {{{
command! GitLocalUser
      \  let s:str = inputsecret('user.name: ')
      \| if s:str !=# ''
      \|   silent execute '!git config user.name' s:str
      \|   silent execute '!git config user.email' (s:str . '@gmail.com')
      \| endif
      \| unlet s:str
" }}}

" hgtk commands {{{
let s:thg =  '!start ' . (executable('thg') ? 'thg' : 'hgtk')
function! s:BlankIgnore(str)
  if a:str == "''"
    return ''
  elseif a:str == '""'
    return ''
  else
    return a:str
  endif
endfunction

command! Hgtkupdate execute s:thg 'update'
" command! Hgtksync   VimProcBang hg incoming
command! Hgtksync   call util#bang('hg incoming', 'utf-8', 'cp932')
command! Hgtkstatus VimProcBang hg status
" command! -nargs=? -complete=file Hgtkstatus  execute s:thg "status"   s:BlankIgnore(<q-args>)
command! -nargs=? -complete=file Hgtkcommit  execute s:thg "commit"   s:BlankIgnore(<q-args>)
command! -nargs=? -complete=file Hgtkshelve  execute s:thg "shelve"   s:BlankIgnore(<q-args>)
command! -nargs=? -complete=file Hgtklog     execute s:thg "log"      s:BlankIgnore(<q-args>)
command! -nargs=? -complete=file Hgtkdiff    execute s:thg "vdiff"    s:BlankIgnore(<q-args>)
command! -nargs=? -complete=file -range=1 Hgtkblame   execute s:thg "blame --line <line1>"    s:BlankIgnore(<q-args>)

nmap [Space]vu :Hgtkupdate<CR>
nmap [Space]v+ :Hgtksync  <CR>
nmap [Space]vD :Hgtkstatus<CR>
nmap [Space]vv :Hgtkcommit<CR>
nmap [Space]vs :Hgtkshelve<CR>
nmap [Space]vL :Hgtklog   <CR>
nmap [Space]v= :Hgtkdiff  <CR>
nmap [Space]vG :Hgtkblame <CR>
nmap [Space]vl :Hgtklog    %<CR>
nmap [Space]v= :Hgtkdiff   %<CR>
nmap [Space]vg :Hgtkblame  %<CR>
"}}}

nmap ! :Bang<Space>
command! -nargs=* -complete=command Out Unite2 -no-start-insert output:<args>
command! -nargs=* -complete=shellcmd Cp932Bang Bang <args> -hook/output_encode/encoding cp932 -outputter/buffer/into 1
command! -nargs=* -complete=shellcmd Utf8Bang Bang <args> -hook/output_encode/encoding utf-8 -outputter/buffer/into 1

" QuickRunでshellコマンドを実行する -hook/output_encode/encoding以降のオプションはquickrunのオプションとして扱う
command! -nargs=+ -complete=shellcmd Bang execute 'QuickRun -type _ -outputter buffer'
      \ join([<f-args>, ''][index([<f-args>], '-hook/output_encode/encoding') : ], ' ')
      \ '-exec "' . escape(join([<f-args>, ''][ : (index([<f-args>], '-hook/output_encode/encoding') - 1)], ' '), '"') . '"'

" Debug commands {{{
command! SyntaxAtCursor
      \  for s:id in synstack(line('.'), col('.'))
      \|  echo synIDattr(s:id, 'name') synIDattr(synIDtrans(s:id), 'name')
      \| endfor
      \| for s:id in synstack(line('.'), col('.'))
      \|  execute 'PrintHighlight' synIDattr(s:id, 'name')
      \| endfor

command! -nargs=1 -complete=highlight PrintHighlight
      \  execute 'syntax list <args>'
      \| execute 'verbose highlight <args>'

command! IndentLevel let v:lnum = line('.')
      \| echo printf('indent:%d cindent:%d lispindent:%d indentexpr:%d prevnonblank(-1):%d indent(prevnonblank(-1)):%d',
      \indent(v:lnum), cindent(v:lnum), lispindent(v:lnum), eval(&indentexpr), prevnonblank(v:lnum - 1), indent(prevnonblank(v:lnum - 1)))
command! FoldLevel let v:lnum = line('.') | echo eval(&foldexpr) | echo foldlevel(v:lnum)
command! FoldTrace let s:list = map(range(1, line('$')), '[foldlevel(v:val), foldclosed(v:val), foldclosedend(v:val), foldtextresult(v:val)]')
      \| vnew | setlocal bt=nofile | put! =s:list

command! -nargs=+ -complete=var Vars PP filter(copy(g:), 'v:key =~# "^<args>"')
command! SortUptime sort! n /[^ ]*  /

command! -nargs=* -complete=mapping BufferMaps AllMaps <buffer> <args>
command!
\   -nargs=* -complete=mapping
\   AllMaps
\   map <args> | map! <args> | lmap <args>

silent! call scope#set_svar(s:, expand('<sfile>:p')) " for debug

" 選択した範囲を vim コマンドとして実行する
" nnoremap [Space]e yy:@"<CR>
" vnoremap <silent> [Space]<C-e> y:execute 'unlet' @"<CR>

" 選択した範囲を vim scriptの式またはコマンドとして実行する
vnoremap <silent> [Space]e :<C-u>call scope#visual_eval()<CR>
nnoremap <silent> [Space]e :<C-u>call scope#eval(<SID>get_text_on_cursor('\%(\w\+:\\|[&$]\)\=[[:alnum:]_#]\+'))<CR>

vnoremap <silent> [Space]E y:<C-u>call scope#sid_expr(@")<CR>

function! s:get_text_on_cursor(pat)
  let line = getline('.')
  let pos = col('.')
  let s = 0
  while s < pos
    let [s, e] = [match(line, a:pat, s), matchend(line, a:pat, s)]
    if s < 0
      break
    elseif s < pos && pos <= e
      return line[s : e - 1]
    endif
    let s += 1
  endwhile
  return ''
endfunction

command! -nargs=+ Eval call scope#eval(<q-args>)
command! -nargs=* PN execute 'PP' <q-args> | echo "\n"

command! -nargs=* Hex  echo printf('0x%08X 0x%X', eval(<q-args>), eval(<q-args>))
command! -nargs=* Char echo printf('0x%02X %s', eval(<q-args>), nr2char(eval(<q-args>)))
command! -nargs=* Ord  echo printf('%s 0x%02X %d', <q-args>, char2nr(<q-args>), char2nr(<q-args>))

" ArrayChar ef bc a8 ef bd 85 ef bd 8c ef bd 8c ef bd 8f => "Ｈｅｌｌｏ"
" NOTE: Result is affected by &fileencoding.
command! -nargs=* ArrayChar echo string(iconv(eval('"' . join(map([<f-args>], 'printf("\\x%02x", v:val)'), ''). '"'), &fileencoding, &encoding))

" To show hit-enter-prompt. (for yanking echo area)
nnoremap @; :@: \| echo "\n"<CR>

" Print char code.
nnoremap ga :execute 'normal! ga' \| echo "\n"<CR>
nnoremap g8 :execute 'normal! g8' \| echo "\n"<CR>

" command! -nargs=? -complete=event AuDelete call AuDelete(<q-args>)
" function! AuDelete(event)
"   augroup ---
"   augroup END
"   execute 'autocmd' a:event
"   let list = ['---'] + filter(split(util#command_output('autocmd ' . a:event), '\n'), 'v:val =~ "^\\w"') + ['---']
"   execute 'autocmd!' list[inputlist(list)]
" endfunction

"}}}

" prettyprint.vim
let g:prettyprint_show_expression = 1

" ftplugin
" TODO: Is it work fine?
autocmd MyAutoCmd BufWritePost */ftplugin/*.vim if bufnr('$') < 100 | doautoall filetypeplugin FileType | endif
autocmd MyAutoCmd BufWritePost */indent/*.vim   if bufnr('$') < 100 | doautoall filetypeindent FileType | endif
" autocmd MyAutoCmd BufWritePost */syntax/*.vim if bufnr('$') < 100 | doautoall syntaxset FileType | endif

" localrc.vim {{{
command! -nargs=* LocalrcApply execute 'doautoall plugin-localrc BufReadPost' (len(<q-args>) ? <q-args> : '*')
" Apply on save .local.vimrc file.
autocmd MyAutoCmd BufWritePost */.local*.vimrc execute 'LocalrcApply' expand('%:p:h:s?.hg/patches??:s?/$??') . '/*'
" }}}

" 環境毎の設定
if filereadable(expand('$VIMHOME/tools/depends/depends.vim'))
  source $VIMHOME/tools/depends/depends.vim
endif

map <Leader>cc <Plug>NERDCommenterComment

" textobj-user.vim {{{
omap is <Plug>(textobj-parameter-i)
xmap is <Plug>(textobj-parameter-i)
omap as <Plug>(textobj-parameter-a)
xmap as <Plug>(textobj-parameter-a)

" " v:count回数分だけ下に移動しながら貼り付け
" nnoremap <silent> gp @='"' . v:register . 'p`[' . 'j'<CR>
" nmap <silent> g.  @=(v:count == 0) ? '.nn' : '.nn'<CR>
" nmap <silent> gr. @=(v:count == 0) ? '.' : '.`[j'<CR>

" Auto indent when yank and paste with linewise.
nnoremap <silent> P :call <SID>normal_put('P')<CR>
nnoremap <silent> p :call <SID>normal_put('p')<CR>

function! s:normal_put(command)
  " use mark 's, 'e
  call setpos("'s", getpos("'["))
  call setpos("'e", getpos("']"))
  execute 'normal! "' . v:register . a:command
  let [a1, a2] = [line("'s"), line("'e")]
  let [b1, b2] = [line("'["), line("']")]

  if (&cindent || &indentexpr !=# '')
        \ && (strpart(getregtype(), 0, 1) ==# 'V' && v:operator =~# '[yd=]')
        \ && &filetype !=# 'java' && &filetype !=# 'python'
    " TODO javaのインデントがおかしい

    let &undolevels = &undolevels

    if abs(a1 - b2) == 1 || abs(a2 - b1) == 1
      echomsg string([a1, a2, b1, b2])
      " 直前にヤンクした範囲と貼り付けた範囲が隣接しているときは範囲全体のインデント修正
      call cursor(min([a1, b1]))
      normal! V
      call cursor(max([a2, b2]))
      normal! =
    else
      normal! `[=`]
    endif
  endif
endfunction

" paste with indent
noremap [p p`[=`]
noremap [P P`[=`]

" incremental edit
" TODO 桁上りなどの処理
" TODO 繰り返し
" TODO @.より'[']をyankして取得したほうがよい?
nnoremap <expr> c. printf("c%dl%s\<Esc>", strlen(@.), substitute(@., '.$', '\=nr2char(char2nr(submatch(0)) + 1)', 'g'))

noremap -   "0
noremap --  "1
noremap --- "-

" :help undo-register
nnoremap <M-y> u.

nnoremap Y y$

" Move to end of line.
" nnoremap <silent><expr> <C-e> (search('\%#.$', 'cn')) ? 'g_' : '$'
nnoremap <silent>       <C-e> $
onoremap <silent>       <C-e> $
xnoremap <silent><expr> <C-e> (&selection ==# 'exclusive' \|\| mode() ==# "\<C-v>") ? '$' : '$h'

nnoremap $ $
xnoremap $ $

" http://vim-users.jp/2011/04/hack214/
onoremap ) t)
onoremap ( t(
xnoremap ) f)
xnoremap ( f(
"}}}

" camelcasemotion.vim {{{
map  <silent> <M-f> <Plug>CamelCaseMotion_w
map  <silent> <M-b> <Plug>CamelCaseMotion_b
map  <silent> <M-e> <Plug>CamelCaseMotion_e
nmap <silent> <M-d> d<Plug>CamelCaseMotion_w
nmap <silent> <M-c> c<Plug>CamelCaseMotion_e
nmap <silent> <M-h> c<Plug>CamelCaseMotion_b
"}}}

" changelist {{{
nnoremap <silent> g; :call <SID>changelist_loop()<CR>
function! s:changelist_loop()
  try
    " move older changing position
    normal! g;
  " catch /^Vim\%((\a\+)\)\=E662/ " E662: 変更リストの先頭
  catch /E662/ " E662: 変更リストの先頭
    " move latest changed position
    try
      normal! 999g,
    catch /E663/ " E663: 変更リストの末尾
      " Nop
    endtry
  catch /E664/ " E664: 変更リストが空です
    echo v:exception
  endtry
endfunction
" }}}

" smooth scroll {{{
" http://d.hatena.ne.jp/namutaka/20110123/1295781476
" }}}

" workaround {{{
" https://github.com/vim-jp/issues/issues/79
let g:ruby_path = ''

" 誰かが勝手にiskeywordに[:#]を追加してしまう
autocmd MyAutoCmd BufReadPost * setlocal iskeyword-=:,#
autocmd MyAutoCmd BufReadPost *.vim,*.vimrc setlocal iskeyword+=#
" }}}

set secure

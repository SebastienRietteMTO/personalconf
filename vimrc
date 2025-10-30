" TODO
" - There are two autocompletion baloons, we must suppress one
" - Is there a way to run SlimConfig to associate the just opened terminal
"   (by :IPython)
" - It would be nice to install ripgrep or Silver Searcher to use :Rp or :Ag to
"   search file content

" HELP on this file
" Documentation on commands (new mapping or other) must begin with
" the string ' DOC' to be extracted automatically issuing
" grep '^" DOC' .vimrc | cut -c 7- | pandoc -f markdown -o customhelp.pdf
" In addition the command :myhelp will display it
:command Myhelp :echo(system('grep "^\" DOC" ~/.vimrc | sed "s/\\\</</" | sed "s/\\\>/>/" | cut -c 7-'))

" INSTALLATION
" Plugins are automatically installed but they can need dependancies.
" The shell snippets needed to perform those installations are
" introduced by the string ' EXEC'. The following command execute them:
" bash -c "$(grep '^\" EXEC' ~/.vimrc | cut -c 8-)"

""""""""""""""""""""""""""""""
""""" PLUGINS
""""""""""""""""""""""""""""""

""""" vim-plug (https://github.com/junegunn/vim-plug/wiki/tips)

" DOC
" DOC Plugin management
" DOC =================
" DOC At startup, plugins are automatically installed
" DOC and the plugin manager (vim-plug) is updated. Commands are:
" DOC
" DOC - :PlugUpdate to update the plugins
" DOC - :PlugClean to remove unused plugins
" DOC

" Install vim-plug if not found
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
endif

" Upgrade it
autocmd VimEnter * PlugUpgrade

" Run PlugInstall if there are missing plugins
autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  \| PlugInstall --sync | source $MYVIMRC
\| endif

call plug#begin()
Plug 'junegunn/vim-plug' " to get plugin manager help

""""" ALE (linters)

Plug 'dense-analysis/ale'
" For linting with https://github.com/dense-analysis/ale
" Suppression of module files in current working directory
let g:ale_fortran_gcc_options = '-Wall -J$TMP'
" To try to correct my pb of being unable to select text sometimes when linting is
" running https://github.com/dense-analysis/ale/issues/1689
"let g:ale_set_balloons=0
" Autocompletion with <C-x><C-o>
let g:ale_completion_enabled = 1
set omnifunc=ale#completion#OmniFunc
hi ALEVirtualTextError ctermbg=160 ctermfg=16 cterm=bold
hi ALEVirtualTextWarning ctermbg=190 ctermfg=16 cterm=bold
hi ALEVirtualTextInfo ctermbg=46 ctermfg=16 cterm=bold
hi ALEVirtualTextStyleError ctermbg=160 ctermfg=16 cterm=bold
hi ALEVirtualTextStyleWarning ctermbg=190 ctermfg=16 cterm=bold

""""" NERDTree (file explorer)
" DOC
" DOC NERDTree
" DOC ========
" DOC \<Ctrl-t\> or :NERDTree to open a window with directory tree
" DOC
" DOC - Open a tab with t
" DOC - fold/unfold with Space or the mouse
" DOC - C to change tree root to the selected node
" DOC - m to open menu for file manipulation
" DOC - r to refresh
" DOC
Plug 'preservim/nerdtree'
autocmd BufWinEnter * if &buftype != 'quickfix' && getcmdwintype() == '' | silent NERDTreeMirror | endif " Open the existing NERDTree on each new tab.
autocmd BufEnter * if winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | call feedkeys(":quit\<CR>:\<BS>") | endif " Close the tab if NERDTree is the only window remaining in it.
Plug 'baopham/vim-nerdtree-unfocus'

nnoremap <C-t> :NERDTreeToggle<CR> " Open/close it with Ctrl-t
let NERDTreeMapActivateNode='<space>'
let NERDTreeIgnore=['\.pyc$', '\~$', '^__pycache__$'] "ignore files in NERDTree
let NERDTreeShowHidden=1
Plug 'xuyuanp/nerdtree-git-plugin' " Add git status, see also GIT plugin section

""""" Status bar
Plug 'vim-airline/vim-airline'

""""" python
Plug 'jpalardy/vim-slime', { 'for': 'python' } " Needed for vim-ipython-cell
Plug 'hanschen/vim-ipython-cell', { 'for': 'python' } " ipython-like
" DOC
" DOC ipython
" DOC =======
" DOC Open a terminal with ipython using :IPython
" DOC
" DOC At the first execution, one must select the terminal executing ipython.
" DOC
" DOC - Press \<Ctrl-p\> to execute a cell and jump to the next
" DOC - :IPythonCellRun executes the whole script
" DOC - all commands are described [here](https://github.com/hanschen/vim-ipython-cell?tab=readme-ov-file#commands)
" DOC
noremap <C-p> :IPythonCellExecuteCellJump<CR>
let g:slime_target = "vimterminal"
let g:slime_vimterminal_cmd = "/usr/bin/ipython3"
set splitright " To open terminal on the right
" Adds the :IPython command to open a terminal with ipython
:command IPython call Open_ipython_term()
function Open_ipython_term()
  let wid = win_getid()
  :vert terminal ++close ipython3
  call win_gotoid(wid) " to restore focus on original window
  echo wid
endfunction
" Highlight cell headers
augroup ipython_cell_highlight
    autocmd!
    autocmd ColorScheme * highlight IPythonCell ctermbg=238 guifg=darkgrey guibg=#444d56
augroup END
Plug 'tmhedberg/SimpylFold' " python folding (zc/zo on class, function...)
set foldlevel=99 " To open folding at opening

""""" GIT (see also NERDTree plugin section)
" DOC
" DOC GIT
" DOC ===
" DOC Git commands are available with :Git
" DOC
Plug 'tpope/vim-fugitive' " Use git command with :Git
Plug 'airblade/vim-gitgutter' " Add a sign for added/deleted lines

""""" Completion
" DOC
" DOC Completion and help
" DOC ===================
" DOC
" DOC - Completion with tab
" DOC - help with \<Ctrl-Space\>
" DOC
Plug 'ervandew/supertab' " Completion with tab
Plug 'davidhalter/jedi-vim' " Ctrl-space to get help on python functions

""""" Tags
" DOC
" DOC Tags
" DOC ====
" DOC Open a tag navigator with \<Ctrl-y\>
" DOC
Plug 'majutsushi/tagbar' " :TagbarToggle
nnoremap <C-y> :TagbarToggle<CR>

" EXEC [ ! -d $HOME/GIT ] && mkdir $HOME/GIT
" EXEC cd $HOME/GIT
" EXEC if [ ! -d ctags ]; then
" EXEC   git clone https://github.com/universal-ctags/ctags.git
" EXEC   cd ctags
" EXEC   docompilation=true
" EXEC else
" EXEC   cd ctags
" EXEC   commit=$(git rev-parse HEAD)
" EXEC   git pull
" EXEC   if [ $(git rev-parse HEAD) != $commit ]; then
" EXEC     make clean
" EXEC     docompilation=true
" EXEC   else
" EXEC     docompilation=false
" EXEC   fi
" EXEC fi
" EXEC if [ $docompilation == true ]; then
" EXEC   ./autogen.sh
" EXEC   ./configure --prefix=$HOME/bin
" EXEC   make
" EXEC fi
" EXEC
let g:tagbar_ctags_bin = "$HOME/GIT/ctags/ctags"

""""" Languages
Plug 'sheerun/vim-polyglot'

""""" Search
" DOC
" DOC Search
" DOC ======
" DOC :FZF to search for a file by filename
" DOC
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
"
call plug#end()


""""""""""""""""""""""""""""""
""""" DIFF CONFIG
""""""""""""""""""""""""""""""

" DOC
" DOC Diff mode
" DOC =========
" DOC - \<Ctrl-↑\>, \<Ctrl-↓\> to go to previous/next diff
" DOC - \<Ctrl-←\>, \<Ctrl-→\> to copy diff from right to left or the reverse
" DOC - \<Ctrl-PageUp\>, \<Ctrl-PageDown\> to take or not into account spaces in diff
" DOC
noremap <C-Down> ]c
noremap <C-Up> [c
noremap <expr> <C-Right> (winnr('$') ==# 2 ? (winnr()==1 ? 'dp':'do'):'')
noremap <expr> <C-Left> (winnr('$') ==# 2 ? (winnr()==1 ? 'do':'dp'):'')
noremap <C-PageDown> :set diffopt+=iwhiteall<CR>
noremap <C-PageUp> :set diffopt-=iwhiteall<CR>

" Disable one diff window during a three-way diff allowing you to cut out the
" noise of a three-way diff and focus on just the changes between two versions
" at a time. Inspired by Steve Losh's Splice
function! DiffToggle(window)
  " Save the cursor position and turn on diff for all windows
  let l:save_cursor = getpos('.')
  windo :diffthis
  " Turn off diff for the specified window (but keep scrollbind) and move
  " the cursor to the left-most diff window
  exe a:window . "wincmd w"
  diffoff
  set scrollbind
  set cursorbind
  exe a:window . "wincmd " . (a:window == 1 ? "l" : "h")
  " Update the diff and restore the cursor position
  diffupdate
  call setpos('.', l:save_cursor)
endfunction
" Toggle diff view on the left, center, or right windows
nmap <silent> <leader>dl :call DiffToggle(1)<cr>
nmap <silent> <leader>dc :call DiffToggle(2)<cr>
nmap <silent> <leader>dr :call DiffToggle(3)<cr>

function! GetDiffBuffers()
    return map(filter(range(1, winnr('$')), 'getwinvar(v:val, "&diff")'), 'winbufnr(v:val)')
endfunction

function! DiffPutAll()
    for bufspec in GetDiffBuffers()
        execute 'diffput' bufspec
    endfor
endfunction

command! -range=-1 -nargs=* DPA call DiffPutAll()

""""""""""""""""""""""""""""""
""""" GENERAL CONFIG
""""""""""""""""""""""""""""""

" DOC
" DOC Other config
" DOC ============

set autowrite
set nobackup
set noic
set showmode
set showmatch
set scrolloff=0
set hlsearch
set expandtab
set tabstop=2
set mouse=a
set tabpagemax=100

autocmd FileType fortran set colorcolumn=132

" I use Ctrl-q to keep alive the telnet link. Normally this char is
" intercepted by the terminal (VSTART command) and vim cannot see it.
" In some cases, Ctrl-q is not intercpeted by the terminal properly
" and is transmitted to the executed program. A workaround is to disable
" the Ctrl-q mapping in vi (or more precisely replace it to a void
" command) in control and edit modes.
map <C-q> <Nop>
map! <C-q> <Nop>

" DOC - \<Space\> to fold/unfold
nnoremap <space> za " Enable folding with spacebar

" DOC - \<Ctrl-b\> to open a terminal in the current window
" DOC - \<Ctrl-n\> to open a new tab with a terminal
" DOC - \<Ctrl-w\>N to be able to scroll and/or copy, i to return
noremap <C-b> :terminal ++curwin<CR>
noremap <C-n> :tab terminal<CR>

" To merge vim clipboard and system clipboard?
" Doesn't work with gnome terminal
set clipboard^=unnamed,unnamedplus

" DOC - Selection
" DOC   - Select text by v (normal), V (whole lines) or  \<Ctrl-V\> (columns)
" DOC   - Cut with d, copy with y, paste before with P, paste after with p
" DOC   - Put in upper case with U, in lower case with u
" DOC - Undo/redo
" DOC   - undo with u, undo the line with U, redo with \<Ctrl-r\>
" DOC   - get the list of undo by :undolist
" DOC - :cq to exit with error (to abort a git commit)
" DOC

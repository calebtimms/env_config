""" Timmseh's Incredible VIMRC """

"" List of Used Plugins and the commands to clone them and populate their helptags
" git clone https://github.com/preservim/nerdtree.git ~/.vim/pack/plugins/start/nerdtree
" vim -u NONE -c "helptags ~/.vim/pack/plugins/start/nerdtree/doc" -c q
" git clone https://github.com/tpope/vim-obsession.git  ~/.vim/pack/plugins/start/obsession
" vim -u NONE -c "helptags ~/.vim/pack/plugins/start/obsession/doc" -c q
" git clone https://github.com/vim-airline/vim-airline.git  ~/.vim/pack/plugins/start/airline
" vim -u NONE -c "helptags ~/.vim/pack/plugins/start/airline/doc" -c q
" git clone https://github.com/vim-airline/vim-airline-themes.git  ~/.vim/pack/plugins/start/airline-themes
" vim -u NONE -c "helptags ~/.vim/pack/plugins/start/airline-themes/doc" -c q
" git clone https://github.com/ctrlpvim/ctrlp.vim.git  ~/.vim/pack/plugins/start/ctrlp
" vim -u NONE -c "helptags ~/.vim/pack/plugins/start/ctrlp/doc" -c q
" git clone https://github.com/tpope/vim-fugitive.git  ~/.vim/pack/plugins/start/fugitive
" vim -u NONE -c "helptags ~/.vim/pack/plugins/start/fugitive/doc" -c q
" git clone https://github.com/airblade/vim-gitgutter.git  ~/.vim/pack/plugins/start/gitgutter
" vim -u NONE -c "helptags ~/.vim/pack/plugins/start/gitgutter/doc" -c q

"" A couple of VIM things
let mapleader = '.'
set nocompatible
set hidden
set wildmode=list:longest
set wildmenu
set clipboard=unnamedplus
"set clipboard=
vnoremap <Leader>y "+y
nnoremap <Leader>p "+p
set belloff=all

"" Editor Configuration
set number
set smarttab
set shiftwidth=4
set tabstop=4
set expandtab
set softtabstop=4
set nowrap
set autoindent
set copyindent
set ruler
set mouse=a
set mousemodel=extend
set showcmd
set backspace=indent,eol,start
set splitright
set splitbelow
set nofoldenable
syntax on
colorscheme industry

"" Search functionality modifications
set incsearch
set hlsearch
set showmatch
set showmode
set ignorecase
set smartcase
noremap <silent> <Space> :silent noh<Bar>echo<CR>
cnoreabbrev ev :e ~/.vimrc
cnoreabbrev ea :e ~/.aliases

"" Maps colon to semi-colon and switches 'j' and 'k' for navigation purposes
noremap ; :
noremap : ;
noremap j k
noremap k j

"" Maps 'jj' to Escape for exiting text in Insert mode
inoremap jj <Esc>

"" Working with buffers (based on mapleader set above, in my case '.')
nnoremap <Leader>b :buffers<CR>:buffer<Space>
nnoremap <Leader>f :bnext<CR>
nnoremap <Leader>a :bprev<CR>
nnoremap <Leader>q :bfirst<CR>
nnoremap <Leader>z :blast<CR>
nnoremap <Leader>r :b#<CR>
nnoremap <Leader>va :vertical ball<CR>
nnoremap <Leader>v :vertical sbuffer<Space>
nnoremap <Leader>sa :ball<CR>
nnoremap <Leader>s :sbuffer<Space>
cnoremap bd :bprevious <bar> bdelete #

"" Additional navigation changes
noremap K G
noremap J gg
noremap L $
noremap H 0
noremap <Esc>k )
noremap <Esc>j (
noremap <Esc>l w
noremap <Esc>h b

"" Bindings for moving the cursor within a VIM window without shifting context (T for top of window, B for bottom of window, G for middle of window)
noremap T H
noremap G M
noremap B L

"" Move cursor to the middle of the current line (horizontally)
noremap M :call cursor(0, virtcol('$')/2)<CR>

"" Maps multiple VIM windows controls to CTRL+direction using:
" h=left, j=up, k=down, l=right

" Moving cursor to windows:
noremap <C-h> <C-w>h
noremap <C-j> <C-w>k
noremap <C-k> <C-w>j
noremap <C-l> <C-w>l
noremap <C-c> <C-w>c
noremap <C-r> <C-w>p
noremap <C-[> <C-w>t
noremap <C-]> <C-w>b

" Moving the windows themselves:
"noremap <Leader>h <C-w>H
"noremap <Leader>j <C-w>K
"noremap <Leader>k <C-w>J
"noremap <Leader>l <C-w>L

" Resize splits
noremap <Leader>, <C-w><
noremap <Leader>. <C-w>>

" Set all splits equal again
noremap <C-\> <C-w>=

" Split file under cursor into either horizontal or vertical split
noremap sf <C-w>f
noremap vf <C-w>f \| <C-w>L

"" Changes default print behavior to printing before the current character
noremap p P
noremap P p

"" Maps '//' to search whatever text is highlighted in visual mode
vnoremap // y/\V<C-r>"<CR>

"" Increase default history and undo levels
set history=1000
set undolevels=1000

"" Add simple status line showing mode, filename, position (Note: This is likely unnecessary now that I'm using Airline)
set laststatus=2

set statusline=%f\ \|\ CursorLoc:{%l,%c\ %p%%}

" Statusline setup
set statusline=
set statusline +=%1*\ %n\ %*            "buffer number
set statusline +=%5*%{&ff}%*            "file format
set statusline +=%3*%y%*                "file type
set statusline +=%4*\ %<%F%*            "full path
set statusline +=%2*%m%*                "modified flag
set statusline +=%1*%=%5l%*             "current line
set statusline +=%2*/%L%*               "total lines
set statusline +=%1*%4v\ %*             "virtual column number
set statusline +=%2*0x%04B\ %*          "character under cursor

" Statusline Colors (cterm)
hi User1 ctermfg=214 ctermbg=236
hi User2 ctermfg=160 ctermbg=236
hi User3 ctermfg=201 ctermbg=236
hi User4 ctermfg=148 ctermbg=236
hi User5 ctermfg=226 ctermbg=236


"" VIM Aliases
" Show name of current file in bottom bar temporarily
cnoreabbrev name :echo expand('%:p') " Type ':name' in VIM command line list file name
" Copy current filename
cnoreabbrev cf :let @+=expand("%:p")
cnoreabbrev ws w !sudo tee %

function! s:EqualizeSplits() abort
  wincmd =
endfunction
command! WindowResize call s:EqualizeSplits()

" Map equalizing size of all open buffers (NERDTree excluded)
noremap <Leader>wr :WindowResize<CR>

" Modifications to quitting files to handle NERDTree smoothly
cnoreabbrev a :qa
cnoreabbrev aa :qa!
cnoreabbrev wa :w<CR>:qa

" Extra mappings for undo/redo
nnoremap - u
nnoremap = <C-r>

"" GVIM Settings
if has("gui_running")
    set guioptions-=m
    " set guifont=Monospace\ 12.5
    set guifont=Monospace\ 15

    " Statusline Colors
    hi User1 guifg=#eea040 guibg=#333333
    hi User2 guifg=#dd3333 guibg=#333333
    hi User3 guifg=#ff66ff guibg=#333333
    hi User4 guifg=#a0ee40 guibg=#333333
    hi User5 guifg=#eeee40 guibg=#333333

    " Custom diff colors for GVim
    highlight DiffAdd    gui=BOLD guifg=NONE    guibg=#005f00
    highlight DiffDelete gui=BOLD guifg=NONE    guibg=#5f0000
    highlight DiffChange gui=BOLD guifg=NONE    guibg=#005f5f
    highlight DiffText   gui=BOLD guifg=#ff00ff guibg=#005f5f
endif

"" VIM diff settings
set diffopt+=vertical,iwhite,foldcolumn:0,algorithm:histogram,indent-heuristic

" Diff shortcuts
noremap <Leader>dt :diffthis
noremap <Leader>do :diffoff
noremap <Leader>du :diffupdate
noremap <Leader>ds :diffsplit<Space>
noremap <Leader>df ]c
noremap <Leader>da [c
noremap [1 :diffget 1<CR>
noremap [2 :diffget 2<CR>
noremap [3 :diffget 3<CR>
noremap [4 :diffget 4<CR>
noremap [5 :diffget 5<CR>
noremap ]1 :diffput 1<CR>
noremap ]2 :diffput 2<CR>
noremap ]3 :diffput 3<CR>
noremap ]4 :diffput 4<CR>
noremap ]5 :diffput 5<CR>

" Folding shortcuts
noremap zx zM
noremap zz zR

" Custom diff colors
highlight DiffAdd    cterm=BOLD ctermfg=NONE ctermbg=22
highlight DiffDelete cterm=BOLD ctermfg=NONE ctermbg=52
highlight DiffChange cterm=BOLD ctermfg=NONE ctermbg=23
highlight DiffText   cterm=BOLD ctermfg=13 ctermbg=23

" QuickFix settings
function! ToggleQuickfix()
  for win in getwininfo()
    if win.quickfix
      cclose
      return
    endif
  endfor

  " Open the quickfix window without moving focus into it.
  let l:curwin = win_getid()
  execute "copen | resize " . (&lines / 4)
  call win_gotoid(l:curwin)
endfunction

nnoremap <silent> <Leader>c :call ToggleQuickfix()<CR>
noremap <Leader>k :cnext<CR>
noremap <Leader>j :cprev<CR>

function! SearchToQuickfix()
  let l:pattern = getreg('/')

  if empty(l:pattern)
    echo "No search pattern"
    return
  endif

  " Clear the previous quickfix list.
  call setqflist([], 'r')

  try
    " g = include every match on a line
    " j = do not jump to the first match
    execute 'silent vimgrep /' . escape(l:pattern, '/\') . '/gj %'
  catch /^Vim\%((\a\+)\)\=:E480/
    echo "No matches found for: " . l:pattern
    return
  endtry

  " Open the quickfix window without moving focus into it.
  let l:current_window = win_getid()
  execute "copen | resize " . (&lines / 4)
  call win_gotoid(l:current_window)
endfunction

nnoremap <silent> <Leader>/ :call SearchToQuickfix()<CR>

"""" Plugin Configuration

"" NERDTree Configuration
let g:NERDTreeWinSize = 30

" True if any window in the current tab is a NERDTree window
function! s:NERDTreeIsOpen() abort
  for w in range(1, winnr('$'))
    if getwinvar(w, '&filetype') ==# 'nerdtree'
      return 1
    endif
  endfor
  return 0
endfunction

function! s:NERDTreeWinNr() abort
  for w in range(1, winnr('$'))
    if getwinvar(w, '&filetype') ==# 'nerdtree'
      return w
    endif
  endfor
  return -1
endfunction

function! NERDTreeResize() abort
  let l:nerdtree_win = s:NERDTreeWinNr()
  if l:nerdtree_win == -1
    return
  endif

  let l:curwin = winnr()

  " Move to NERDTree, resize that window, then move back
  execute l:nerdtree_win . 'wincmd w'
  execute 'vertical resize ' . g:NERDTreeWinSize
  execute l:curwin . 'wincmd w'

  call s:EqualizeSplits()
endfunction

command! NERDTreeResize call NERDTreeResize()

" NERDTree shortcut mapping
nnoremap <C-n> :NERDTreeFocus<CR>
nnoremap <Leader>nf :NERDTreeFind<CR>
nnoremap <Leader>nt :NERDTreeToggle<CR>
nnoremap <Leader>nr :NERDTreeResize<CR>

"" Airline Configuration
" Airline Options
let g:airline_inactive_collapse=0

" Set up Airline Theme
let g:airline_theme='solarized_flood'

" Custom Airline Theme color patching
let g:airline_theme_patch_func = 'AirlineThemePatch'

function! AirlineThemePatch(palette)
  if g:airline_theme ==# 'solarized_flood'
    for mode in ['normal','insert','replace','visual','commandline','terminal']
      if has_key(a:palette, mode)
        " Remove italics from A / B / C / Z
        let a:palette[mode].airline_a[4] = ''
        let a:palette[mode].airline_b[4] = ''
        let a:palette[mode].airline_c[4] = ''
        let a:palette[mode].airline_z[4] = ''

        " Only change backgrounds for b/c/x/y to match inactive theme:
        " B + Y -> ctermbg=235, guibg=#262626
        let a:palette[mode].airline_b[1] = '#262626'
        let a:palette[mode].airline_b[3] = 235
        let a:palette[mode].airline_y[1] = '#262626'
        let a:palette[mode].airline_y[3] = 235

        " C + X -> ctermbg=236, guibg=#303030 let a:palette[mode].airline_c[1] = '#303030' let a:palette[mode].airline_c[3] = 236
        let a:palette[mode].airline_x[1] = '#303030'
        let a:palette[mode].airline_x[3] = 236
      endif
    endfor

    " Change text color in C / X to green in INSERT mode
    if has_key(a:palette, 'insert')
        let a:palette.insert.airline_c[0] = '#859900'
        let a:palette.insert.airline_c[2] = 106

        let a:palette.insert.airline_x[0] = '#859900'
        let a:palette.insert.airline_x[2] = 106
    endif
  endif
endfunction

" Set up custom Airline symbols
if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif

"let g:airline_symbols_ascii = 1
let g:airline_powerline_fonts = 1
let g:airline_symbols.linenr = ' Line:'
let g:airline_symbols.colnr = ' Col:'
let g:airline_symbols.maxlinenr = ''

let g:airline#extensions#default#layout = [
    \ [ 'a', 'b', 'c' ],
    \ [ 'x', 'y', 'z' ]
    \ ]

" Create custom Obsession status bar to be plugged into Airline
function! CustomObsessionStatus()
    let session = filereadable(v:this_session)
    if exists('g:this_obsession') && session
        let session_name = fnamemodify(g:this_obsession, ':t')
        return printf('[Live: %s]', session_name)
    elseif session
        let session_name = fnamemodify(g:this_session, ':t')
        return printf('[Paused: %s]', session_name)
    else
        return '[No Session]'
    endif
endfunction

" Custom Airline section creation
let g:airline_section_y = airline#section#create(['%{CustomObsessionStatus()}'])

" Disable Airline/Obsession integration since I'm using a customized solution above
let g:airline#extensions#obsession#enabled = 0

"" GitGutter Configuration
noremap <Leader>gta :GitGutterToggle<CR>
noremap <Leader>gt :GitGutterBufferToggle<CR>
noremap <Leader>gth :GitGutterLineHighlightsToggle<CR>
noremap <Leader>gd :GitGutterDiffOrig<CR>
noremap <Leader>gq :GitGutterQuickFix<CR>
noremap <Leader>hd <Plug>(GitGutterPreviewHunk)
noremap <Leader>hs <Plug>(GitGutterStageHunk)
noremap <Leader>hu <Plug>(GitGutterUndoHunk)
noremap <Leader>hf <Plug>(GitGutterNextHunk)
noremap <Leader>ha <Plug>(GitGutterPrevHunk)
set updatetime=125
set foldtext=gitgutter#fold#foldtext()
let g:gitgutter_max_signs = -1
# Note: Diff base will differ for work/home. Pick the right one or suffer lots of green screens.
#let g:gitgutter_diff_base = 'origin/master'
let g:gitgutter_diff_base = 'origin/main'
let g:gitgutter_preview_win_location = 'bel'

"" Obsession Configuration
function! s:ObWrapper(...) abort
  if a:0 == 0
    execute 'Obsession'
  else
    let l:file = a:1
    if l:file !~# '\.vim$'
      let l:file .= '.vim'
    endif
    execute 'Obsession ' . fnameescape(l:file)
  endif
endfunction
command! -nargs=? Ob call s:ObWrapper(<f-args>)

" Call custom Obsession function with ':ob'
cnoreabbrev ob :Ob
cnoreabbrev od :Obsession!

function! s:ObWrapper(...) abort
  if exists(':Obsession') != 2
    return
  endif

  if a:0 == 0
    if filewritable(getcwd()) != 2
      return
    endif

    silent! Obsession
    return
  endif

  let l:file = a:1

  if l:file !~# '\.vim$'
    let l:file .= '.vim'
  endif

  let l:session_path = fnamemodify(l:file, ':p')
  let l:session_dir = fnamemodify(l:session_path, ':h')

  if filewritable(l:session_dir) != 2
    return
  endif

  execute 'silent! Obsession ' . fnameescape(l:file)
endfunction

command! -nargs=? Ob call s:ObWrapper(<f-args>)

"" Ctrl-P Congiguration
let g:ctrlp_map = '<C-f>'
let g:ctrlp_show_hidden = 1
let g:ctrlp_prompt_mappings = {
  \ 'PrtSelectMove("j")': ['<c-k>', '<down>'],
  \ 'PrtSelectMove("k")': ['<c-j>', '<up>'],
  \ 'ToggleType(1)':      ['<c-up>'],
  \ 'PrtExit()':          ['<esc>', '<c-f>'],
  \ }

"""" Autocommand Configuration (Special Ordering to Ensure Expected Behavior)
"augroup StartObsessionIfNeeded
"  autocmd!
"  autocmd VimEnter * call s:maybe_obsession()
"augroup END
"
"function! s:maybe_obsession() abort
"  " If Obsession is already active, or we were started with a session file, do nothing
"  if exists('g:this_obsession') || !empty(v:this_session)
"    return
"  endif
"  " Activate Obsession since it is not already in a live state
"  execute 'Obsession'
"endfunction
"
""" Enable GitGutter line highlighting and enable NERDTree by default
"autocmd VimEnter * :GitGutterAll
"autocmd VimEnter * :GitGutterLineHighlightsEnable
"autocmd VimEnter * NERDTree | wincmd p

" Resize all open buffers to be equally split (accounts for NERDTree opening and taking space on the left-most side of the screen)
augroup ResizeSplits
  autocmd!
  autocmd VimEnter,BufNew,BufAdd,BufDelete,WinNew,WinClosed,VimResized * call s:EqualizeSplits()
augroup END

""" Autocommand Configuration

" Return true when Vim can create files in the current working directory.
function! s:CwdIsWritable() abort
  return filewritable(getcwd()) == 2
endfunction

function! s:MaybeStartObsession() abort
  " Plugin is unavailable.
  if exists(':Obsession') != 2
    return
  endif

  " Obsession is already active, or Vim was started with a session.
  if exists('g:this_obsession') || !empty(v:this_session)
    return
  endif

  " A default :Obsession writes Session.vim into the current directory.
  if !s:CwdIsWritable()
    return
  endif

  silent! Obsession
endfunction

function! s:SafePluginStartup() abort
  " Each command is independently protected so one plugin cannot interrupt
  " the rest of Vim's startup.

  if exists(':GitGutterAll') == 2
    silent! GitGutterAll
  endif

  if exists(':GitGutterLineHighlightsEnable') == 2
    silent! GitGutterLineHighlightsEnable
  endif

  if exists(':NERDTree') == 2
    try
      silent NERDTree
      silent! wincmd p
    catch
      " Ignore inaccessible directories and other NERDTree startup errors.
    endtry
  endif
endfunction

augroup SafePluginStartup
  autocmd!
  autocmd VimEnter * call s:MaybeStartObsession()
  autocmd VimEnter * call s:SafePluginStartup()
augroup END

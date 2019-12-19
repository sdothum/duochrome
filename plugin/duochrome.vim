" sdothum - 2016 (c) wtfpl

" Config
" ══════════════════════════════════════════════════════════════════════════════

let s:save_cpo = &cpo
set cpo&vim
if exists("g:loaded_duochrome") | finish | endif
let g:loaded_duochrome = 1

" ...................................................................... Session
" dynamic settings, see after/plugin/*
let g:duochrome_cursorline = !empty(glob('~/.session/vim:cursorline'))   " highlight
let g:duochrome_cursorline = !empty(glob('~/.session/vim:underline')) ? 2 : g:duochrome_cursorline
let g:cursorword           = !empty(glob('~/.session/vim:cursorword'))   " highlighting
let g:dark                 = !empty(glob('~/.session/vim:dark'))         " background
let g:mono                 = !empty(glob('~/.session/vim:mono'))         " single width utf-8
let g:readability          = !empty(glob('~/.session/vim:readability'))  " fontsize
let g:trace                = !empty(glob('~/.session/vim:trace'))        " debug

if &diff | let g:duochrome_cursorline = g:duochrome_cursorline ? g:duochrome_cursorline : 2 | endif  " underline default

" Filetype _____________________________________________________________________

" ............................................................. Prose filestypes
" distraction free filetyes
function! Prose()
  return &filetype =~ 'draft\|html\|mail\|markdown\|note\|wiki'
endfunction

function! Markdown()
  return &filetype =~ 'markdown\|wiki'
endfunction

" .................................................................... Protected
function! s:fzfBuffer()
  if exists("g:fzf#vim#buffers") | return g:fzf#vim#buffers != {} " fzf trap
  else                           | return 0
  endif
endfunction

function! Protected()
  return &filetype == 'help' || mode() == 't' || <SID>fzfBuffer()
endfunction

" ............................................................... Plugin windows
" plugin buffers typically are named '[<plugin>]' or '__<plugin>__'
function! PluginWindow()
  return expand('%:r') =~ '^[[_].*'
endfunction

function! CommandWindow()
  return expand('%p') == '[Command Line]'
endfunction

" System _______________________________________________________________________

" ........................................................................ Debug
nnoremap <silent><S-F10> :let g:trace = !g:trace<CR>

" .................................................................. Debug trace
command! -nargs=1 Trace call lib#trace(<f-args>)

" ........................................................... Error message trap
command! -nargs=1 Quietly call lib#Quietly(<f-args>)

" ........................................................ State change notifier
command! -nargs=1 Notify call lib#Notify(<f-args>)

" ............................................................. GUI delay window
command! -nargs=? -bar WaitFor call lib#WaitFor(<f-args>)

" Behaviour ____________________________________________________________________

augroup gui | autocmd! | augroup END

" ................................................................... Toggle gui
command! -bar ToggleGui silent! call gui#ToggleGui()

nnoremap <silent><S-F12>      :ToggleGui<CR>
inoremap <silent><S-F12> <C-o>:ToggleGui<CR>
vnoremap <silent><S-F12> :<C-u>ToggleGui<CR>

" ................................................................... Redraw gui
command! -bar RedrawGui silent! ToggleGui | WaitFor 50m \| ToggleGui

if has('gui_running')  " initial refresh to fill window
  autocmd gui VimEnter * RedrawGui
endif

nnoremap <silent><F12>      :RedrawGui<CR>
inoremap <silent><F12> <C-o>:RedrawGui<CR>
vnoremap <silent><F12> :<C-u>RedrawGui<CR>

" .................................................................... Scrolling
command! ScrollOffset silent! call gui#ScrollOffset()

" Look _________________________________________________________________________

" ................................................................... Cursorline
command! ToggleCursorline silent! call gui#ToggleCursorline()

nmap <silent><F8>      :ToggleCursorline<CR>
imap <silent><F8> <C-o>:ToggleCursorline<CR>

" ............................................................... Column margins
command! ToggleColumn silent! call gui#ToggleColumn()

set colorcolumn=0  " highlight column
nmap <silent><Bar> :ToggleColumn<CR>

" .......................................................... Line wrap highlight
command! ShowBreak silent! call gui#ShowBreak()
command! -nargs=? ToggleBreak silent! call gui#ToggleBreak(<f-args>)

nmap <silent><S-F8>      :ToggleBreak<CR>
imap <silent><S-F8> <C-o>:ToggleBreak<CR>

" ................................................................. Line numbers
set number
set numberwidth=10
set relativenumber

" The look _____________________________________________________________________

augroup theme | autocmd! | augroup END

" .................................................................. Colorscheme
colorscheme duochrome
if g:dark              | set background=dark
elseif empty($DISPLAY) | set background=dark  " console
else                   | set background=light
endif

command! -nargs=? -bar Background silent! call theme#Background(<f-args>)

autocmd theme InsertEnter * Background
autocmd theme InsertLeave * Background

" wm timing requires FocusGained+sleep with VimResized to consistently set margins, see Background
autocmd theme VimEnter,VimResized,FocusGained * WaitFor | Background

" ................................................................ Switch colour
command! LiteSwitch silent! call theme#LiteSwitch()

nmap <silent><F9>      :LiteSwitch<CR>
imap <silent><F9> <C-o>:LiteSwitch<CR>

" ................................................................ Single window
command! StatusLine silent! call theme#StatusLine()

" ................................................................ Split windows
command! -bar SplitColors silent! call theme#SplitColors()

let g:active = 0   " active window tag
" for active window highlighting
autocmd theme WinEnter,TerminalOpen,BufWinEnter,VimEnter * let g:active = g:active + 1 | let w:tagged = g:active
autocmd theme WinEnter,TerminalOpen                      * SplitColors

" Fonts ________________________________________________________________________

augroup ui | autocmd! | augroup END

" ................................................................. Code / Prose
" Iosevka custom compiled, with nerd-fonts awesome patches, see make_install/iosevka
let s:mono = g:mono ? '-mono' : ''                           " font name extension
let g:font = ['Iosevka' . s:mono, 'Iosevka-proof' . s:mono]  " family [code, prose]

" Display ______________________________________________________________________

" ..................................................................... Messages
" clear messages after awhile to keep screen clean and distraction free!
autocmd ui CursorHold * echo

" Highlighting _________________________________________________________________

" .......................................................... Syntax highlighting
set omnifunc=syntaxcomplete#Complete
syntax on  " turn on syntax highlighting
 
" ftplugin set syntax is overridden by vim runtime Syntax autocmd
autocmd ui Syntax <buffer> execute 'set syntax=' . &filetype
" refresh highlighting on arm
" autocmd ui CursorHold * if !Prose() && !&diff && !empty(&filetype) | execute 'set filetype=' . &filetype | endif

" Buffer _______________________________________________________________________

" ..................................................................... Filetype
command! -nargs=1 Filetype silent! call ui#Filetype(<f-args>)

nmap <leader>F :Filetype<Space>

" .................................................................... View mode
command! -bar ToggleProof silent! call ui#ToggleProof()

nmap <silent><S-F11>      :ToggleProof<CR>
imap <silent><S-F11> <C-o>:ToggleProof<CR>

if has('gui_running')
  autocmd ui InsertEnter * ToggleProof | SignifyDisable
  autocmd ui InsertLeave * ToggleProof | SignifyEnable
endif

" ................................................................. Line numbers
command! ToggleNumber silent! call ui#ToggleNumber()

" toggle relative/line number
nmap <silent># :ToggleNumber<CR>

" .................................................................... Line wrap
command! ToggleWrap call ui#ToggleWrap()

nmap <silent><leader><CR> :ToggleWrap<CR>

" ............................................................... Screen display
command! Layout silent! call ui#Layout()

" intial view mode: source code or prose, plugin windows inherit current theme (avoids thrashing)
autocmd ui VimEnter,BufWinEnter * Layout

" ....................................................................... Redraw
command! Refresh silent! call ui#Refresh()

nmap <silent><F11>      :Refresh<CR>
imap <silent><F11> <C-o>:Refresh<CR>

" .............................................................. Balance margins
command! Margins silent! call ui#Margins()

" ................................................................ Set font size
command! -nargs=1 Font silent! call ui#Font(<f-args>)

" prose font is by (writing preference) default set 1px larger than code font
nmap <silent><S-F9>      :Font !g:fonttype<CR>
imap <silent><S-F9> <C-o>:Font !g:fonttype<CR>

" .............................................................. Show statusline
command! ShowInfo silent! call ui#ShowInfo()

" .................................................... Toggle statusline details
command! -nargs=? -bar ToggleInfo silent! call ui#ToggleInfo(<f-args>)

nmap <silent><F7>        :ToggleInfo<CR>
imap <silent><F7>   <C-o>:ToggleInfo Prose()<CR>

" show info+sleep in balanced diff windows
autocmd ui VimEnter * if &diff | ToggleInfo | WaitFor | execute "normal! \<C-w>=" | endif

" Format _______________________________________________________________________

augroup statusline | autocmd! | augroup END

" ..................................................................... Settings
set laststatus=2                 " always show status line
set ruler                        " show cursor position in status line

let g:pad = ['      ', '     ']  " statusline padding [inner, outer]
"             123456    12345

" ....................................................................... Glyphs
" buffer g:icon [0] unmodified [1] unmodifiable [2] modified [3] inactive [4] insert mode
if empty($DISPLAY) | let g:icon = ['•', '-', '+', 'x', '^']  " console font
elseif g:mono      | let g:icon = ['', '', '', '', '']  " nerd-font utf-8 mono symbols
else               | let g:icon = ['', '', '', '', '']  " nerd-font utf-8 double width symbols
endif

" ............................................................. Expanded details
let g:detail = 0  " default expanded detail (0) tag (1) atom, see F7 map

" toggle tag / line details
nmap <silent><S-F7>      :let g:detail = !g:detail<CR>
imap <silent><S-F7> <C-o>:let g:detail = !g:detail<CR>

" .............................................................. Column position
let g:show_column = 0  " statusline current column

" trigger autocmd to flash column position (does not work for BOF)
nnoremap <silent><C-c> hl

autocmd statusline CursorHold  * let g:show_column = 0
autocmd statusline CursorMoved * let g:show_column = 1

" ................................................................. Syntax group
command! Atom echo statusline#Atom()

nnoremap <silent><F10> :Atom<CR>

let &cpo = s:save_cpo

" vim: set ft=vim: .vimrc

" sdothum - 2016 (c) wtfpl

" Config
" ══════════════════════════════════════════════════════════════════════════════

if exists('g:loaded_duochrome') | finish | endif
let g:loaded_duochrome = 1
let s:save_cpo = &cpo
set cpo&vim

" eEEetetet eteE
" ──────────────────────────────────────────────────────────────────────────────

" ...................................................................... Session
" dynamic settings, see after/plugin/*
if !exists('g:duochrome_cursorline') | let g:duochrome_cursorline = !empty(glob('~/.session/vim:cursorline')) | endif  " highlight
" ──────────────────────────────────
let g:duochrome_cursorline = !empty(glob('~/.session/vim:underline')) ? 2 : g:duochrome_cursorline
let g:cursorword           = !empty(glob('~/.session/vim:cursorword'))   " highlighting
let g:dark                 = !empty(glob('~/.session/vim:dark'))         " background
let g:mono                 = !empty(glob('~/.session/vim:mono'))         " single width utf-8
let g:readability          = !empty(glob('~/.session/vim:readability'))  " fontsize
let g:trace                = !empty(glob('~/.session/vim:trace'))        " debug

if &diff | let g:duochrome_cursorline = g:duochrome_cursorline ? g:duochrome_cursorline : 2 | endif  " underline default

" .......................................................................... Map
if !exists('g:duochrome_map') | let g:duochrome_map = 1 | endif  " key mapping (0) user assigned (1) defaults
" ───────────────────────────

function! s:m(map)
  if g:duochrome_map | execute a:map | endif
endfunction

" temporary mapping macro
command! -nargs=? M call <SID>m(<f-args>) 

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
  if exists('g:fzf#vim#buffers') | return g:fzf#vim#buffers != {} " fzf trap
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
M nnoremap <silent><S-F10> :let g:trace = !g:trace<CR>

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

M nnoremap <silent><S-F12>      :ToggleGui<CR>
M inoremap <silent><S-F12> <C-o>:ToggleGui<CR>
M vnoremap <silent><S-F12> :<C-u>ToggleGui<CR>

" ................................................................... Redraw gui
command! -bar RedrawGui silent! ToggleGui | WaitFor 50m \| ToggleGui

if has('gui_running')  " initial refresh to fill window
  autocmd gui VimEnter * RedrawGui
endif

M nnoremap <silent><F12>      :RedrawGui<CR>
M inoremap <silent><F12> <C-o>:RedrawGui<CR>
M vnoremap <silent><F12> :<C-u>RedrawGui<CR>

" .................................................................... Scrolling
command! ScrollOffset silent! call gui#ScrollOffset()

" ..................................................................... Messages
" clear messages after awhile to keep screen clean and distraction free!
autocmd gui CursorHold * echo

" Look _________________________________________________________________________

" ................................................................... Cursorline
command! ToggleCursorline silent! call gui#ToggleCursorline()

M nmap <silent><F8>      :ToggleCursorline<CR>
M imap <silent><F8> <C-o>:ToggleCursorline<CR>

" ............................................................... Column margins
command! ToggleColumn silent! call gui#ToggleColumn()

set colorcolumn=0  " highlight column
M nmap <silent><Bar> :ToggleColumn<CR>

" .......................................................... Line wrap highlight
command! ShowBreak silent! call gui#ShowBreak()
command! -nargs=? ToggleBreak silent! call gui#ToggleBreak(<f-args>)

M nmap <silent><S-F8>      :ToggleBreak<CR>
M imap <silent><S-F8> <C-o>:ToggleBreak<CR>

" ................................................................. Line numbers
set number
set numberwidth=10
set relativenumber

" Theme ________________________________________________________________________

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

M nmap <silent><F9>      :LiteSwitch<CR>
M imap <silent><F9> <C-o>:LiteSwitch<CR>

" ................................................................ Single window
command! StatusLine silent! call theme#StatusLine()

" ................................................................ Split windows
command! -bar SplitColors silent! call theme#SplitColors()

let g:active = 0   " active window tag
" for active window highlighting
autocmd theme WinEnter,TerminalOpen,BufWinEnter,VimEnter * let g:active = g:active + 1 | let w:tagged = g:active
autocmd theme WinEnter,TerminalOpen                      * SplitColors

" Text _________________________________________________________________________

augroup ui | autocmd! | augroup END

" ......................................................................... Font
" Iosevka custom compiled, with nerd-fonts awesome patches, see make_install/iosevka
if !exists('g:duochrom_font')
" ───────────────────────────
  let s:mono          = g:mono ? '-mono' : ''                                " font name extension
  let g:duochrom_font = ['Iosevka' . s:mono, 'Iosevka' . '-proof' . s:mono]  " family [code, prose]
endif

" .......................................................... Syntax highlighting
set omnifunc=syntaxcomplete#Complete
syntax on  " turn on syntax highlighting
 
" ftplugin set syntax is overridden by vim runtime Syntax autocmd
autocmd ui Syntax <buffer> execute 'set syntax=' . &filetype
" refresh highlighting on arm
" autocmd ui CursorHold * if !Prose() && !&diff && !empty(&filetype) | execute 'set filetype=' . &filetype | endif

" Distraction free mode ________________________________________________________

" .................................................................... View mode
command! -bar ToggleProof silent! call ui#ToggleProof()

M nmap <silent><S-F11>      :ToggleProof<CR>
M imap <silent><S-F11> <C-o>:ToggleProof<CR>

if has('gui_running')
  autocmd ui InsertEnter * ToggleProof | SignifyDisable
  autocmd ui InsertLeave * ToggleProof | SignifyEnable
endif

" ................................................................. Line numbers
command! ToggleNumber silent! call ui#ToggleNumber()

" toggle relative/line number
M nmap <silent># :ToggleNumber<CR>

" .............................................................. Show statusline
command! ShowInfo silent! call ui#ShowInfo()

" .................................................... Toggle statusline details
command! -nargs=? -bar ToggleInfo silent! call ui#ToggleInfo(<f-args>)

M nmap <silent><F7>        :ToggleInfo<CR>
M imap <silent><F7>   <C-o>:ToggleInfo Prose()<CR>

" show info+sleep in balanced diff windows
autocmd ui VimEnter * if &diff | ToggleInfo | WaitFor | execute "normal! \<C-w>=" | endif

" Format _______________________________________________________________________

" ..................................................................... Filetype
command! -nargs=1 Filetype silent! call ui#Filetype(<f-args>)

M nmap <leader>F :Filetype<Space>

" .................................................................... Line wrap
command! ToggleWrap call ui#ToggleWrap()

M nmap <silent><leader><CR> :ToggleWrap<CR>

" Screen _______________________________________________________________________

" ............................................................... Screen display
command! Layout silent! call ui#Layout()

" intial view mode: source code or prose, plugin windows inherit current theme (avoids thrashing)
autocmd ui VimEnter,BufWinEnter * Layout

" ...................................................................... Refresh
command! Refresh silent! call ui#Refresh()

M nmap <silent><F11>      :Refresh<CR>
M imap <silent><F11> <C-o>:Refresh<CR>

" .............................................................. Balance margins
command! Margins silent! call ui#Margins()

" ................................................................ Set font size
command! -nargs=1 Font silent! call ui#Font(<f-args>)

" prose font is by (writing preference) default set 1px larger than code font
M nmap <silent><S-F9>      :Font !g:fonttype<CR>
M imap <silent><S-F9> <C-o>:Font !g:fonttype<CR>

" Statusline ___________________________________________________________________

augroup statusline | autocmd! | augroup END

" ..................................................................... Settings
set laststatus=2                 " always show status line
set ruler                        " show cursor position in status line

let g:pad = ['      ', '     ']  " statusline padding [inner, outer]
"             123456    12345

" ....................................................................... Glyphs
" buffer g:duochrome_icon [0] unmodified (normal mode) [1] unmodifiable [2] modified [3] inactive (window) [4] insert mode
if !exists('g:duochrome_icon')
" ────────────────────────────
  if empty($DISPLAY) | let g:duochrome_icon = ['•', '-', '+', 'x', '^']  " console font
  elseif g:mono      | let g:duochrome_icon = ['', '', '', '', '']  " nerd-font utf-8 mono symbols
  else               | let g:duochrome_icon = ['', '', '', '', '']  " nerd-font utf-8 double width symbols
  endif
endif

" .................................................................. Information
let g:detail = 0  " default expanded detail (0) tag (1) atom, see F7 map

" toggle tag / line details
M nmap <silent><S-F7>      :let g:detail = !g:detail<CR>
M imap <silent><S-F7> <C-o>:let g:detail = !g:detail<CR>

" .............................................................. Column position
let g:show_column = 0  " statusline current column

" trigger autocmd to flash column position (does not work for BOF)
M nnoremap <silent><C-c> hl

autocmd statusline CursorHold  * let g:show_column = 0
autocmd statusline CursorMoved * let g:show_column = 1

" ................................................................. Syntax group
command! Atom echo statusline#Atom()

M nnoremap <silent><F10> :Atom<CR>

" cleanup
delcommand M
let &cpo = s:save_cpo

" vim: set ft=vim: "

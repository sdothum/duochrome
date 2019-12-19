" sdothum - 2016 (c) wtfpl

" User Interface
" ══════════════════════════════════════════════════════════════════════════════

" Buffer _______________________________________________________________________

" ..................................................................... Filetype
" set corresponding ui for filetye
function! ui#Filetype(ft)
  execute 'setfiletype ' . a:ft
  Layout  " respect ui
endfunction

" Distraction free mode ________________________________________________________

" .................................................................. Insert mode
" toggle full document highlight
function! ui#ToggleProof()
  Trace ui:ToggleProof()
  if CommandWindow() | return | endif
  let l:col              = virtcol('.')
  let g:duochrome_insert = !g:duochrome_insert
  if g:duochrome_insert | Limelight   " insert mode dfm view
  else                  | Limelight!  " normal mode proof view
  endif
  execute 'normal! ' . l:col . '|'
  Background
endfunction

" ................................................................. Line numbers
" toggle line numbers
function! ui#ToggleNumber()
  Trace ui:ToggleNumber
  let g:duochrome_relative = !g:duochrome_relative
  Background
endfunction

" Format _______________________________________________________________________

" .................................................................... Line wrap
function! ui#ToggleWrap()
  if !Prose() | return | endif
  if &formatoptions =~ 't'
    let l:textwidth = &textwidth  " formatoptions -t sets textwidth to 0
    SoftPencil
    set formatoptions-=t
    let &textwidth = l:textwidth  " restore for correct Margins calculation
  else
    HardPencil
    set formatoptions+=t
  endif
  Notify Automatic line wrap: &formatoptions =~ 't'
endfunction

" Screen _______________________________________________________________________

" ............................................................... Screen display
" initial view
function! ui#Layout()
  Trace ui:Layout()
  if PluginWindow() || !has("gui_running") | return | endif 
  let g:duochrome_markdown = Prose()
  Font Prose()
  ShowBreak
endfunction

" refresh layout
function! ui#Refresh()
  Trace ui:Refresh()
  if PluginWindow() | return | endif 
  let l:status     = &laststatus
  Layout   
  let &laststatus = l:status
endfunction

" .............................................................. Balance margins
" balance left right margins with font size changes (and window resizing)
function! ui#Margins()
  Trace ui:Margin
  if PluginWindow()  " flush left for plugin windows
    setlocal nonumber
    setlocal foldcolumn=0
  else
    let g:lite_dfm_left_offset = max([1, min([22, (&columns - &textwidth - (Prose() ? 0 : 4)) / 2])])  " account for code linenr <space> text
    Quietly LiteDFM
    ShowInfo
  endif 
endfunction

" ..................................................................... Set font
let g:fonttype = -1  " current font (0) source (1) prose, force setting

" adjust font sizes for various gpu's/displays, liteDFM offsets to fit screens
function! ui#Font(type)
  Trace ui:Font()
  if !has('gui_running') | return | endif 
  " a:type may be function or expression (nargs are literal strings only)
  execute 'let l:type = ' . a:type
  if g:fonttype != l:type | let g:fonttype = l:type
    let l:size = system('fontsize')
    let l:size = l:type ? l:size + 1 : l:size + g:readability
    execute 'set guifont=' . (Prose() ? g:font[1] : g:font[0]) . '\ ' . l:size
    if !g:fonttype | RedrawGui | endif  " refresh to window fill on small font
    set laststatus=2                    " turn on statusline
  endif
endfunction

" Statusline ___________________________________________________________________

" .............................................................. Show statusline
let s:expanded = 0  " statusline state (0) dfm (1) expanded

function! ui#ShowInfo()
  Trace ui:ShowInfo()
  execute 'set statusline=' . statusline#Statusline(s:expanded)
  StatusLine
endfunction

" ............................................................ Toggle statusline
function! ui#ToggleInfo(...)
  Trace ui:ToggleInfo
  if a:0 && a:1 | return | endif  " prose insert mode is always dfm
  let l:col = col('.')
  let s:expanded = !s:expanded
  ShowInfo
  execute 'normal! ' . l:col . '|'
endfunction

" ui.vim

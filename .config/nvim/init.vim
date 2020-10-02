if has("nvim")
    call plug#begin('~/.local/share/nvim/plugged')
else
    call plug#begin('~/.vim/plugged')
endif

    " set rtp^=/Users/tyleonha/Code/PowerShell/coc-powershell/
    Plug 'vim-airline/vim-airline-themes'
    Plug 'bling/vim-airline'
    Plug 'neoclide/coc.nvim', {'branch': 'release'}

    Plug 'scrooloose/nerdtree'
    
    " syntax highlighting
    Plug 'sheerun/vim-polyglot'

call plug#end()

nnoremap <silent> <C-k><C-B> :NERDTreeToggle<CR>

" Coc settings
" -- use <c-space>for trigger completion
inoremap <silent><expr> <c-space> coc#refresh()
" -- use <Tab> and <S-Tab> for navigate completion list:
inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
" -- use <cr> to confirm complete
inoremap <expr> <cr>    pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
" -- close preview window when completion is done.
autocmd! CompleteDone * if pumvisible() == 0 | pclose | endif
vmap <buffer> <F8> :<C-u>CocCommand powershell.evaluateSelection<CR>
nmap <buffer> <F8> :<C-u>CocCommand powershell.evaluateLine<CR>

" airline settings
let g:airline_powerline_fonts=1
let g:airline_inactive_collapse=1
let g:airline_inactive_alt_sep=0
let g:airline_detect_modified=1
let g:airline#extensions#wordcount#enabled = 1
let g:airline#extensions#fugitiveline#enabled = 1
let g:airline#extensions#branch#enabled = 1
let g:airline_detect_spell=1
let g:airline_detect_spelllang=1
let g:airline_exclude_preview = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#buffer_nr_show = 1
let g:airline#extensions#tabline#buffer_nr_format = '%s: '
let g:airline#extensions#tabline#fnamemod = ':t'
set ttimeoutlen=50

" create airline parts for coc server status & coc_current_function
function! VsimAirlineCocServer()
  return get(g:, 'coc_status', '')
endfunction
function! VsimAirlineCurrentFunction()
  let n = get(b:, 'coc_current_function', '')
  if n != ''
      return n.' '
  else
      return n
  endif
endfunction
function! VsimAirlineCurrentChar()
  let chr = matchstr(getline('.'), '\%' . col('.') . 'c.')
  return '[' . printf("0x%04X", char2nr(chr)) . ']'
endfunction

call airline#parts#define_function('coc', 'VsimAirlineCocServer')
call airline#parts#define_function('buf_func', 'VsimAirlineCurrentFunction')
call airline#parts#define_function('cur_char', 'VsimAirlineCurrentChar')

function! AirlineInit()
  let spc=g:airline_symbols.space
  let g:airline_section_a = airline#section#create(['crypt', 'paste', 'spell', 'iminsert', 'coc'])
  let g:airline_section_x = airline#section#create(['buf_func', 'filetype'])
  let g:airline_section_y = airline#section#create(['ffenc'])
  let g:airline_section_z = airline#section#create(['cur_char', 'windowswap', 'obsession', '%3p%%'.spc, 'linenr', 'maxlinenr', spc.':%3v'])

  let g:airline_section_error = '%{airline#util#wrap(airline#extensions#coc#get_error(),0)}'
  let g:airline_section_warning = '%{airline#util#wrap(airline#extensions#coc#get_warning(),0)}'
endfunction
autocmd User AirlineAfterInit call AirlineInit()

function! VsimProgrammerMode()
    set updatetime=300
    set signcolumn=yes
    autocmd! CursorHold  * silent call CocActionAsync('highlight')
    autocmd! CursorHoldI * silent call CocActionAsync('showSignatureHelp')
    autocmd! User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')

    setlocal nobackup
    setlocal nowritebackup

    setl formatexpr=CocAction('formatSelection')
    vmap <buffer> <C-e><C-d> <Plug>(coc-format-selected)
    imap <buffer> <C-e><C-d> <Plug>(coc-format-selected)
    nmap <buffer> <C-e><C-d> :call CocAction('format')<CR>
    vmap <buffer> <C-e>d     <Plug>(coc-format-selected)
    imap <buffer> <C-e>d     <Plug>(coc-format-selected)
    nmap <buffer> <C-e>d     :call CocAction('format')<CR>

    nmap <buffer> <C-.>      <Plug>(coc-codeaction)
    vmap <buffer> <C-.>      <Plug>(coc-codeaction-selected)

    if &filetype != 'vim'
        nmap <silent> <buffer> <S-K>      :call CocActionAsync('doHover')<CR>
    endif

    if &filetype == 'fsharp' || &filetype == 'vim'
        setlocal foldmethod=indent
    endif

    nmap <silent> <buffer> <F1>       :call CocActionAsync('doHover')<CR>

    nmap <buffer> <F2>                <Plug>(coc-rename)
    nmap <silent> <buffer> <F12>      <Plug>(coc-definition)
    nmap <silent> <buffer> <C-]>      <Plug>(coc-declaration)
    nmap <silent> <buffer> <C-k><C-r> <Plug>(coc-references)
    nmap <silent> <buffer> <C-k>r     <Plug>(coc-references)

    nmap <silent> <buffer> gd         <Plug>(coc-definition)
    nmap <silent> <buffer> gy         <Plug>(coc-type-definition)
    nmap <silent> <buffer> gi         <Plug>(coc-implementation)
    nmap <silent> <buffer> gr         <Plug>(coc-references)

    nmap <silent> <buffer> <C-S-F12>  <Plug>(coc-diagnostic-next)
    nmap <silent> <buffer> <C-W><C-E> :CocList diagnostics<CR>
    nmap <silent> <buffer> <C-W>e     :CocList diagnostics<CR>
    nmap <silent> <buffer> <C-S-P>    :CocCommand<CR>
endfunction

autocmd FileType c,cpp,typescript,json,ps1,psm1,psd1,powershell,fsharp,cs,python,vim call VsimProgrammerMode()

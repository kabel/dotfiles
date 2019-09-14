" pathogen packages
execute pathogen#infect()
execute pathogen#helptags()

" don't make foo~ files
set nobackup

" searching
set ignorecase
set smartcase
set hlsearch

" disable mouse integration
set mouse=

set confirm
set tabstop=4
set shiftwidth=4

" Override sensible default
set noshowmode
set noshowcmd
set shortmess+=F

let g:airline_powerline_fonts=1

"if !exists('g:airline_symbols')
"    let g:airline_symbols = {}
"endif
"let g:airline_left_sep = '▶'
"let g:airline_right_sep = '◀'
"let g:airline_symbols.crypt = '🔒'
"let g:airline_symbols.linenr = '¶'
"let g:airline_symbols.branch = '⎇'
"let g:airline_symbols.paste = 'ρ'
"let g:airline_symbols.whitespace = 'Ξ'

let g:airline_detect_modified=1
let g:airline_detect_paste=1

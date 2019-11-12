set textwidth=79  " lines longer than 79 columns will be broken
set shiftround    " round indent to multiple of 'shiftwidth'
set tabstop=4
set shiftwidth=4
set autoindent    " align the new line indent with the previous line  
set number    
inoremap {<CR> {<C-o>o}<C-o>O   
inoremap [<CR> [<C-o>o]<C-o>O   

set background=light
:colors desert

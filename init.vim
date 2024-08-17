" TODO clearly understand the implications of the following code intended to load .vimrc.
set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc

if filereadable(expand("~/.config/nvim/init_host_specific.vim"))
  source ~/.config/nvim/init_host_specific.vim
endif

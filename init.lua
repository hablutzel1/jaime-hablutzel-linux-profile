-- TODO clearly understand the implications of the following code intended to load .vimrc.
vim.cmd([[
set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc
]])

-- TODO allow to extend the Neovim configuration with another file host specific, e.g. init__host_specific.lua.

#!/bin/bash

####
# Copilot for Neovim
####
sudo apt update
sudo apt install -y nodejs npm
git clone https://github.com/github/copilot.vim.git \
  ~/.config/nvim/pack/github/start/copilot.vim

#!/bin/bash

# Apparently required to use GitHub CLI in the Dev Container. TODO confirm.
echo 'unset GITHUB_TOKEN' >> ~/.bashrc

####
# Copilot for Neovim
# TODO evaluate to move this to configure-profile when GitHub CLI is enabled.
####
sudo apt update
sudo apt install -y nodejs npm
git clone https://github.com/github/copilot.vim.git \
  ~/.config/nvim/pack/github/start/copilot.vim

#!/bin/bash

# update && upgrade
sudo dnf -y update && sudo dnf -y upgrade

# RPM Fusion # Restart Required
sudo dnf -y install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# broadcom-wl # Restart Required
sudo dnf -y install broadcom-wl

# close firewalld
sudo systemctl stop firewalld
sudo systemctl disable firewalld

# dotfiles python server
systemctl --user enable --now my-python-server.service

# sshd
sudo dnf -y install openssh-server && sudo systemctl enable --now sshd

# nodejs
sudo dnf -y install nodejs

# fcitx5 # Restart Required
sudo dnf -y install fcitx5 fcitx5-gtk fcitx5-qt fcitx5-configtool fcitx5-chinese-addons fcitx5-rime
mkdir -p ~/.config/environment.d
echo "GTK_IM_MODULE=fcitx" > ~/.config/environment.d/im.conf
echo "QT_IM_MODULE=fcitx" >> ~/.config/environment.d/im.conf
echo "XMODIFIERS=@im=fcitx" >> ~/.config/environment.d/im.conf
echo "SDL_IM_MODULE=fcitx" >> ~/.config/environment.d/im.conf
echo "GLFW_IM_MODULE=ibus" >> ~/.config/environment.d/im.conf

# 7z
sudo dnf -y install p7zip p7zip-plugins

# stow
sudo dnf -y install stow

# qemu
sudo dnf -y install @virtualization

# wireshark-cli
sudo dnf -y install wireshark-cli

# neovim
sudo dnf -y install neovim python3-neovim

# prismlauncher
sudo dnf -y copr enable g3tchoo/prismlauncher && sudo dnf -y install prismlauncher

# fzf
sudo dnf -y install fzf

# keepassxc
sudo dnf -y install keepassxc

# lazygit
sudo dnf -y copr enable dejan/lazygit && sudo dnf -y install lazygit

# mpv
sudo dnf -y install mpv

# zellij
sudo dnf -y install zellij

# ripgrep
sudo dnf -y install ripgrep

# bat
sudo dnf -y install bat

# starship
sudo dnf -y copr enable atim/starship && sudo dnf -y install starship

# bottom
sudo dnf -y copr enable atim/bottom && sudo dnf -y install bottom

# yt-dlp
sudo dnf -y install yt-dlp

# yazi
sudo dnf -y copr enable lihaohong/yazi && sudo dnf -y install yazi

# rpi-imager
sudo dnf -y install rpi-imager

# tigervnc
sudo dnf -y install tigervnc

# obs-studio
sudo dnf -y install obs-studio

# espanso
sudo dnf -y install --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release
sudo dnf -y install espanso-wayland
espanso service register
espanso start

# rclone
sudo dnf -y install rclone

# github-cli
sudo dnf -y install gh

# ncdu
sudo dnf install ncdu

# daed
sudo dnf -y copr enable zhullyb/v2rayA
sudo dnf -y install daed
sudo systemctl enable --now daed

# v2rayA
sudo dnf -y copr enable zhullyb/v2rayA
sudo dnf -y install v2ray v2raya
sudo systemctl enable --now v2raya

# clipse
sudo dnf -y copr enable azandure/clipse && sudo dnf -y install clipse

# eza
sudo dnf -y install eza

# arp-scan
sudo dnf -y install arp-scan

# sshfs
sudo dnf -y install sshfs

# Screenshot and Clipboard
sudo dnf -y install wl-clipboard grim slurp jq dunst

# vagrant
wget -O- https://rpm.releases.hashicorp.com/fedora/hashicorp.repo | sudo tee /etc/yum.repos.d/hashicorp.repo
sudo yum list available | grep hashicorp
sudo dnf -y install vagrant libvirt-devel
mkdir ~/vagrant-alpine
cd vagrant-alpine
vagrant init generic/alpine318
vagrant plugin install vagrant-libvirt

# cursor-cli
curl https://cursor.com/install -fsS | bash

# claude-cli
sudo npm install -g @anthropic-ai/claude-code

# copilot-cli
sudo npm install -g @github/copilot

# gemini-cli
sudo npm install -g @google/gemini-cli

# codex-cli
sudo npm install -g @openai/codex

# prettier
sudo npm install -g prettier

# repomix
sudo npm install -g repomix

# neoovim node for coc lsp
sudo npm install -g neovim

# fish
sudo dnf -y install fish && chsh -s /usr/bin/fish

## To-do List

### Running

- [润]
- [毕设]

### Waiting

- [我想实现一个围绕spring boot的完整项目,我将完成它作为我的面试实习项目(我希望不是烂大街的项目),!!!!重点一定要放在中国小公司java程序员最常见最真实的工作部分,我的学历是民办本科不太可能去中大厂!!!!,请先分成多个阶段,然后每个阶段分成多个的小任务,任务一定要划小不能再小的那种(我需要你之后一步一步带我做,但是现在先不做忙实现先划分一个具体的清单,我们采用一个最推荐最主流的开发策略,开发模式绝对不能采用瀑布开发,开发周期非常短,只有2个月,并且我还要并行刷Grind75(一个精选的LeetCode题集))和准备八股文. -------------------------我已经完成了这个项目我能不能添加AI功能]

# Fedora

```bash
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

# ghostty
sudo dnf -y copr enable scottames/ghostty && sudo dnf -y install ghostty

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

# android-tools
sudo dnf -y install android-tools

# github-cli
sudo dnf -y install gh

# minicom
sudo dnf -y install minicom

# daed
sudo dnf -y copr enable zhullyb/v2rayA
sudo dnf -y install daed
sudo systemctl enable --now daed

# v2rayA
sudo dnf -y copr enable zhullyb/v2rayA
sudo dnf -y install v2ray v2raya
sudo systemctl enable --now v2raya

# copyq
sudo dnf -y install copyq

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

# uv
curl -LsSf https://astral.sh/uv/install.sh | sh

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

# fish
sudo dnf -y install fish && chsh -s /usr/bin/fish
```

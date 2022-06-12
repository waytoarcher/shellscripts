#!/bin/bash
function install_vim() {
    mkdir -p "$HOME"/.vim/bundle
    mkdir -p "$HOME"/.vim/.backup
    mkdir -p "$HOME"/.vim/.undo
    mkdir -p "$HOME"/.vim/.swap
    sudo apt install -y libncurses5-dev cmake
    git clone https://github.com/VundleVim/Vundle.vim.git "$HOME"/.vim/bundle/Vundle.vim || exit
    cp ./vimrc "$HOME"/.vimrc || exit
    # YouCompleteMe 是基于 Vim 的 omnifunc 机制来实现自动补全功能
    if [ -d "$HOME"/.vim/bundle/YouCompleteMe ]; then
        :
    else
        git clone https://github.com/Valloric/YouCompleteMe.git "$HOME"/.vim/bundle/YouCompleteMe
        cd "$HOME"/.vim/bundle/YouCompleteMe || exit
        git submodule update --init --recursive
        #./install.sh --clang-completer --system-libclang
        python3 install.py --clangd-completer
    fi
    vim +PluginInstall +qall
}

function install_oh_my_zsh() {
    set -x
    exec > >(tee -i /tmp/install_zsh.log)
    exec 2>&1
    sudo apt update || exit
    sudo apt install -y zsh fonts-powerline curl git || exit
    cd "$HOME" || exit
    rm -rf "$HOME"/.local/share/fonts
    mkdir -p "$HOME"/.local/share/fonts
    cd "$HOME"/.local/share/fonts || exit
    while true; do
        wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf || true
        wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf || true
        wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf || true
        wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf || true
        fontsnu=$(find "$HOME"/.local/share/fonts/ -name "MesloLGS*" | wc -l)
        if [ "$fontsnu" == 4 ]; then
            break
        fi
    done
    fc-cache -v
    cd "$HOME" || exit
    echo "INFO Now start install zsh:"
    echo "When zsh have been installed,pleast input exit , back to continue run……"
    echo "When zsh have been installed,pleast input exit , back to continue run……"
    sleep 5
    i=0
    while true; do
        i=$((i + 1))
        wget -O - https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh | bash - || true
        if [ -f "$HOME"/.oh-my-zsh/oh-my-zsh.sh ]; then
            break
        fi
        if [ $i -gt 30 ]; then
            echo "Check the internet."
            exit 1
        fi
    done
    cp "$HOME"/.oh-my-zsh/templates/zshrc.zsh-template "$HOME"/.zshrc
    while true; do
        if git clone https://github.com/zsh-users/zsh-autosuggestions "$HOME"/.oh-my-zsh/custom/plugins/zsh-autosuggestions; then
            break
        fi
    done
    while true; do
        if git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$HOME"/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting; then
            break
        fi
    done
    while true; do
        if git clone https://github.com/sukkaw/zsh-proxy.git "$HOME"/.oh-my-zsh/custom/plugins/zsh-proxy; then
            break
        fi
    done
    while true; do
        if git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$HOME"/.oh-my-zsh/custom/themes/powerlevel10k; then
            break
        fi
    done
    sed -ri '/^plugins/c plugins=(git zsh-proxy colored-man-pages zsh-autosuggestions zsh-syntax-highlighting)' "$HOME"/.zshrc
    sed -ri '/^#[ *]HIST_STAMPS/c HIST_STAMPS="yyyy-mm-dd"' "$HOME"/.zshrc
    sed -ri '/^ZSH_THEME/c ZSH_THEME="powerlevel10k/powerlevel10k"' "$HOME"/.zshrc
    sed -ri "/^POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true/d" "$HOME"/.zshrc
    sed -ri "\$aPOWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true" "$HOME"/.zshrc
    echo "change default sh to zsh:"
    chsh -s "$(which zsh)"
    echo "$SHELL"
}
while true; do
    echo " 1: install vim           With plugins"
    echo " 2: install oh my zsh"
    echo " 0: exit"
    echo ""
    read -r -p "Please input the choice:" idx
    if [[ "$idx" -ge 1 ]] || [[ "$idx" -le 6 ]]; then
        :
    else
        echo "Please check the your choice."
    fi
    #  echo "no choice,exit"
    if [[ '1' = "$idx" ]]; then
        eval "install_vim"
    elif [[ '2' = "$idx" ]]; then
        eval "install_oh_my_zsh"
    elif [[ '0' = "$idx" ]]; then
        eval "exit"
    else
        echo "no choice,exit!"
        eval "exit"
    fi
done

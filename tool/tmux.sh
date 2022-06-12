#!/bin/bash
# By Sandylaw <waytoarcher@gmail.com>
# 四, 03 12月 2020 15时47分03秒 +0800
function package() {
    packages=("$@")
    apt=$(command -v apt-get)
    yum=$(command -v yum)
    yay=$(command -v yay)
    if [ -z "$yay" ]; then
        pacman=$(command -v pacman)
    fi
    if [ -n "$apt" ]; then
        sudo apt-get update
        sudo apt-get -y install "${packages[@]}"
    elif [ -n "$yum" ]; then
        sudo yum -y install "${packages[@]}"
    elif [ -n "$yay" ]; then
        yay -S "${packages[@]}"
    elif [ -n "$pacman" ]; then
        sudo pacman -S "${packages[@]}"
    else
        echo "Err: no path to apt-get or yum" >&2
    fi
}

package tmux xclip

cat << EOF | tee "$HOME"/.tmux.conf
## Use vim keybindings in copy mode
set-option -g mouse on
setw -g mode-keys vi
set-option -s set-clipboard off
bind P paste-buffer
bind-key -T copy-mode-vi v send-keys -X begin-selection
bind-key -T copy-mode-vi y send-keys -X rectangle-toggle
unbind -T copy-mode-vi Enter
bind-key -T copy-mode-vi Enter send-keys -X copy-pipe-and-cancel 'xclip -se c -i'
bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel 'xclip -se c -i'
EOF

cat << EOF
 Now you can enter copy mode normally with CTRL+B and [.
 Navigate the copy mode with vi-like-key bindings (u for up, d for down, etc.)
 Hit v to start copying.
 Press y or Enter to copy the text into the tmux buffer. This automatically cancels copy mode.
 Paste into the buffer with <prefix>+P (make sure that it’s uppercase P).

Or alternatively, use the mouse to copy text after you’ve entered copy mode.

The above commands use xclip, a Linux command line tool for X11. 
You can replace xclip -se c -i with a platform-specific command like pbcopy (MacOS) or 
wl-copy (Wayland).
EOF

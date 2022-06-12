#!/bin/bash

install() {
    cd /tmp || exit
    rm -rf pycharm-community-2020.2.3* || true
    wget https://download-cf.jetbrains.com/python/pycharm-community-2020.2.3.tar.gz
    sleep 3
    tar -xf pycharm-community-2020.2.3.tar.gz || exit
    echo copy to /opt/
    sudo cp -rf pycharm-community-2020.2.3 /opt/
    echo remove download files
    rm -rf pycharm-community-2020.2.3* || true
    cd /opt/pycharm-community-2020.2.3/bin || exit
    sleep 3
    echo setup pycharm
    sudo sed -r '/^SED/aexport _JAVA_AWT_WM_NONREPARENTING=1' ./pycharm.sh
    cat << EOF | sudo tee /etc/sysctl.d/notify.conf
fs.inotify.max_user_watches = 524288
EOF

cat << EOF | sudo tee /usr/bin/pycharm
#! /usr/bin/bash
nohup /usr/lib/gnome-settings-daemon/gsd-xsettings > /dev/null 2>&1 &
export _JAVA_AWT_WM_NONREPARENTING=1
/opt/pycharm-community-2020.2.3/bin/pycharm.sh
EOF

    sudo sysctl -p --system
    ./pycharm.sh
}
uninstall() {
    rm -rf "$HOME"/.config/JetBrains
    rm -rf "$HOME"/.java
    rm -rf "$HOME"/.jetbrains
    sudo rm -rf /opt/pycharm-community-2020.2.3
    sudo rm -rf /usr/local/bin/charm
}

echo "
1. install pycharm 2020.2.3
2. uninstall pycharm 2020.3.3
3. exit
"
read -r ipx

case $ipx in
    1)
        install
        echo "pycharm plugins: shell script, save, ansible and so on."
        ;;
    2)
        uninstall
        ;;
    3)
        exit
        ;;
    *) ;;

esac

#!/bin/bash
latest_version=$(wget -O - https://data.services.jetbrains.com/products/releases\?code\=PCP\&latest\=true\&type\=release 2> /dev/null | jq -r '.PCP[]|.version')

install() {
    cd /tmp || exit
    rm -rf pycharm-community-"$latest_version"* || true
    wget https://download.jetbrains.com/python/pycharm-community-"$latest_version".tar.gz
    sleep 3
    tar -xf pycharm-community-"$latest_version".tar.gz || exit
    echo copy to /opt/
    sudo cp -rf pycharm-community-"$latest_version" /opt/
    echo remove download files
    rm -rf pycharm-community-"$latest_version"* || true
    cd /opt/pycharm-community-"$latest_version"/bin || exit
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
/opt/pycharm-community-"$latest_version"/bin/pycharm.sh
EOF

    sudo chmod a+x /usr/bin/pycharm
    sudo sysctl -p --system
    ./pycharm.sh
}
uninstall() {
    rm -rf "$HOME"/.config/JetBrains
    rm -rf "$HOME"/.java
    rm -rf "$HOME"/.jetbrains
    sudo rm -rf /opt/pycharm-community-"$latest_version"
    sudo rm -rf /usr/local/bin/charm
}

echo "
1. install pycharm $latest_version
2. uninstall pycharm $latest_version
3. exit
"
read -r ipx

case $ipx in
    1)
        install
        echo "pycharm plugins: shell script, File Watchers, ansible and so on."
        ;;
    2)
        uninstall
        ;;
    3)
        exit
        ;;
    *) ;;

esac

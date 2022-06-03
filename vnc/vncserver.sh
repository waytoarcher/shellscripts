#!/usr/bin/bash
#by waytoarcher <waytoarcher@gmail.com> 2020-09-15
out() { printf "%s %s\n%s\n" "$1" "$2" "${@:3}"; }
error() { out "==> ERROR:" "$@"; } >&2
warning() { out "==> WARNING:" "$@"; } >&2
msg() { out "==>" "$@"; }

if [ "$(id -u)" -eq 0 ]; then
	error "Please run $0 with non-root."
	exit 1
fi
function help() {
	msg "bash $0 [50~99]"
	exit 0
}
case $1 in
-h | --help | -H | --HELP)
	help
	;;
*) ;;

esac

xport=${1:-99}
re='^[5-9]+[0-9]$'
if ! [[ "$xport" =~ $re ]]; then
	error "xport(VNC session number) should be in 50~99."
	exit 1
fi
echo "The xport is $xport"
function start_vncserver() {
	sport=$((xport + 5900))
	cport=$((xport + 6900))
	sudo systemctl stop vncserver@"$xport"
	sudo killall vncserver || true
    # shellcheck disable=SC2009
    ps aux | grep "[s]shpass" |grep $cport:127.0.0.1:$sport |awk '{print $2}'|xargs kill -15
    vncserver -kill :"$xport"
	#vncserver -localhost :"$xport"
	sudo systemctl restart vncserver@"$xport"
	sudo systemctl status vncserver@"$xport"
}
function install_vncserver() {
	user=$(whoami)
	msg "INFO installing tightvncserver"
	sudo apt install -y tightvncserver sshpass
	msg "INFO installing xfce4 terminal"
	sudo apt install -y xfce4 xfce4-terminal xterm rxvt-unicode
	rm -rf "$HOME"/.vnc
	vncserver -localhost :"$xport"
	sudo killall vncserver
	mv "$HOME"/.vnc/xstartup "$HOME"/.vnc/xstartup.bak || true
	cat <<EOF | tee "$HOME"/.Xresources
URxvt.scrollBar: false

! Molokai theme
URxvt*background: #101010
URxvt*foreground: #d0d0d0
URxvt*color0: #101010
URxvt*color1: #960050
URxvt*color2: #66aa11
URxvt*color3: #c47f2c
URxvt*color4: #30309b
URxvt*color5: #7e40a5
URxvt*color6: #3579a8
URxvt*color7: #9999aa
URxvt*color8: #303030
URxvt*color9: #ff0090
URxvt*color10: #80ff00
URxvt*color11: #ffba68
URxvt*color12: #5f5fee
URxvt*color13: #bb88dd
URxvt*color14: #4eb4fa
URxvt*color15: #d0d0d0

*xterm*background: #101010
*xterm*foreground: #d0d0d0
*xterm*cursorColor: #d0d0d0
*xterm*color0: #101010
*xterm*color1: #960050
*xterm*color2: #66aa11
*xterm*color3: #c47f2c
*xterm*color4: #30309b
*xterm*color5: #7e40a5
*xterm*color6: #3579a8
*xterm*color7: #9999aa
*xterm*color8: #303030
*xterm*color9: #ff0090
*xterm*color10: #80ff00
*xterm*color11: #ffba68
*xterm*color12: #5f5fee
*xterm*color13: #bb88dd
*xterm*color14: #4eb4fa
*xterm*color15: #d0d0d0
EOF
	cat <<EOF | tee "$HOME"/.vnc/xstartup
#!/bin/bash
xrdb $HOME/.Xresources
startxfce4 &
EOF
	chmod +x "$HOME"/.vnc/xstartup

	cat <<EOF | sudo tee /etc/systemd/system/vncserver@.service
Description=Start TightVNC server at startup
After=syslog.target network.target

[Service]
Type=forking
User=$user
Group=$user
WorkingDirectory=$HOME

PIDFile=$HOME/.vnc/%H:%i.pid
ExecStartPre=/usr/bin/vncserver -kill :%i > /dev/null 2>&1
ExecStart=/usr/bin/vncserver -depth 24 -geometry 1920x1080 :%i
ExecStop=/usr/bin/vncserver -kill :%i

[Install]
WantedBy=multi-user.target
EOF
	sudo systemctl daemon-reload
	sudo systemctl enable --now vncserver@"$xport".service
	start_vncserver
}

function install_vncviewer() {
	sudo apt install -y sshpass tigervnc-common xtightvncviewer
}

function start_vncviewer() {
	sport=$((xport + 5900))
	cport=$((xport + 6900))

	read -rp "Please input vncserver ip:" vncserver_ip
	read -srp "Please input vncserver password:" vncserver_passwd
	printf "\n"
	read -rp "Please input vncserver host username:" vncserver_host_username
	read -srp "Please input vncserver host user's password:" vncserver_host_user_passwd
	printf "\n"
	echo "$vncserver_passwd" | vncpasswd -f >~/."$vncserver_ip":"$xport".pass
    # shellcheck disable=SC2009
    ps aux | grep -e "[s]shpass" -e "$vncserver_ip" -e "$cport" |awk '{print \$2}'|xargs kill -15 &>/dev/null || true
#	killall sshpass &>/dev/null || true
	mkdir -p "$HOME"/.vnc/viewers || true
	cat <<EOF | tee "$HOME"/.vnc/viewers/viewer_"$vncserver_ip":"$xport"
#!/usr/bin/env bash
sshpass -p $vncserver_host_user_passwd ssh -L $cport:127.0.0.1:$sport -C -N -l $vncserver_host_username $vncserver_ip &
sleep 1
xtightvncviewer $@ -passwd ~/.$vncserver_ip:$xport.pass localhost:$cport
# shellcheck disable=SC2009
ps aux | grep -e "[s]shpass" -e $vncserver_ip -e $cport |awk '{print \$2}'|xargs kill -15 &>/dev/null || true
EOF
	chmod +x "$HOME"/.vnc/viewers/viewer_"$vncserver_ip":"$xport"
	"$HOME"/.vnc/viewers/viewer_"$vncserver_ip":"$xport"
}

function list_vncviewer() {
	read -ra viewers <<<"$(find "$HOME"/.vnc/viewers/ -name "viewer_*" -exec basename {} \; | tr "\n" " ")"
	viewers_sum=${#viewers[*]}
	if [[ $viewers_sum -lt 1 ]]; then
		warning "This no viewer exist now."
		main
	fi
	find "$HOME"/.vnc/viewers/ -name "viewer_*" -exec basename {} \; | cat -n
	read -rp "Please input the viewer id:" viewerid
	if [ "${viewerid}" -le 0 ] || [ "${viewerid}" -gt "${viewers_sum}" ]; then
		error "Please check the viewer id."
		main
	fi
	if [ -z "$viewerid" ]; then
		main
	fi
}

function fast_vncviewer() {
	list_vncviewer
	"$HOME/.vnc/viewers/${viewers[$viewerid - 1]}"
}

function delete_vncviewer() {
	list_vncviewer
	rm -f "$HOME/.vnc/viewers/${viewers[$viewerid - 1]}" || true
}
function main() {
	while true; do
		echo ""
		echo " Tightvncserver and tightvncviewer:"
		echo " 1: Install tightvncserver "
		echo " 2: Start   tightvncserver "
		echo " 3: Install tightvncviewer "
		echo " 4: Start   tightvncviewer with truecolor"
		echo " 5: Start   tightvncviewer with 8-bit color"
		echo " 6: Start   tightvncviewer saved"
		echo " 7: Delete  tightvncviewer saved"
		echo " 0: Exit"
		echo ""

		read -r -p "Please input the choice:" idx
		if [[ "$idx" -ge 1 ]] || [[ "$idx" -le 3 ]]; then
			:
		else
			echo "Please check the your choice."
		fi
		#  echo "no choice,exit"
		if [[ '1' = "$idx" ]]; then
			eval "install_vncserver"
		elif [[ '2' = "$idx" ]]; then
			eval "start_vncserver"
		elif [[ '3' = "$idx" ]]; then
			eval "install_vncviewer"
		elif [[ '4' = "$idx" ]]; then
			eval "start_vncviewer -truecolor"
		elif [[ '5' = "$idx" ]]; then
			eval "start_vncviewer -bgr233"
		elif [[ '6' = "$idx" ]]; then
			eval "fast_vncviewer"
		elif [[ '7' = "$idx" ]]; then
			eval "delete_vncviewer"
		elif [[ '0' = "$idx" ]]; then
			eval "exit 0"
		else
			echo "no choice,exit!"
			eval "exit 0"
		fi
	done
}
main

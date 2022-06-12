#!/usr/bin/env bash
function get_latest_release() {
	curl --silent "https://api.github.com/repos/$1/releases/latest" | grep -Po '"tag_name":[ ]*"\K.*?(?=")'
}
cd /tmp || exit 1
echo "INFO Installing v2ray"
case $(arch) in
x86_64)
	ARCH=64
	;;
aarch64)
	ARCH=arm64-v8a
	;;
mips64)
	ARCH=mips64el
	;;
*) ;;

esac
while true; do
	v2ray_version=$(get_latest_release "v2fly/v2ray-core")
	if [[ -n "$v2ray_version" ]]; then
		break
	fi
done
echo "$v2ray_version"
mkdir -p v2ray
wget -O v2ray.zip https://github.com/v2fly/v2ray-core/releases/download/"$v2ray_version"/v2ray-linux-$ARCH.zip && unzip v2ray.zip -d v2ray/
sudo systemctl stop v2ray
sleep 1
sudo cp v2ray/v2ray /usr/bin/
sudo cp v2ray/v2ctl /usr/bin/
sudo systemctl restart v2ray
rm -rf v2ray*

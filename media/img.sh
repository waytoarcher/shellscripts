#!/usr/bin/bash
#v1.0 by sandylaw <waytoarcher@gmail.com> 2020-09-20
file="${1}"
function help() {
	echo "Upload the image file to https://img.vim-cn.com"
	echo "Usage: ./img.sh image"
}
if [ "${file}" == -h ] || [ "${file}" == --help ]; then
	help
elif [ -z "${file}" ]; then
	echo "Please follow the command with a image."
	help
	exit 1
elif ! [ -f "${file}" ]; then
	echo "file does not exist."
	help
	exit 1
fi

if [ -f "${file}" ]; then
	extension="${file##*.}"
	extension=$(echo "$extension" | tr '[:upper:]' '[:lower:]')
	case "$extension" in
	bmp | jpg | png | tif | gif | pcx | tga | exif | fpx | svg | psd | cdr | pcd | dxf | ufo | eps | ai | raw | wmf | webp)
		curl -F "name=@${file}" 'https://img.vim-cn.com/?qr'
		;;
	*)
		echo "The ${file} extension : $extension is not supported!"
		help
		exit 1
		;;
	esac
fi

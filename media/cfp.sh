#!/usr/bin/bash
file="${1}"
function help() {
    echo "Paste the text file to https://cfp.vim-cn.com"
    echo "Usage: ./cfp.sh file"
}
if [ "${file}" == -h ] || [ "${file}" == --help ]; then
    help
elif [ -z "${file}" ]; then
    echo "Please follow the command with a file."
    help
    exit 1
elif ! [ -f "${file}" ]; then
    echo "file does not exist."
    help
    exit 1
fi

if [ -f "${file}" ]; then
    curl -F 'vimcn=<-' https://cfp.vim-cn.com/ < "${file}"
fi

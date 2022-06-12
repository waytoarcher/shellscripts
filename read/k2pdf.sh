#!/bin/bash
# By Sandylaw <waytoarcher@gmail.com>
# Fri, 04 Dec 2020 09:49:21 PM +0800
function k2pdf() {
	local file=${1}
	if [ -f "${file}" ]; then
		K2pdfopt -dev kv -wrap+ -ws 0.01 -as -c -ls "${file}"
	else
		echo "Please check the pdf file."
	fi
}
k2pdf "${1}"

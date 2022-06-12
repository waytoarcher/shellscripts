#!/bin/bash

cd /tmp/ || exit 1

curl -O https://www.python.org/ftp/python/3.8.12/Python-3.8.12.tar.xz
tar -xf Python-3.8.12.tar.xz
cd Python-3.8.12 || exit 1
./configure --enable-optimizations --enable-loadable-sqlite-extensions
make -j8
sudo make altinstall

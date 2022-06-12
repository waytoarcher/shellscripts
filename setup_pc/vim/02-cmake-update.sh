#!/bin/bash
cd /var/tmp
proxychains wget https://github.com/Kitware/CMake/releases/download/v3.20.5/cmake-3.20.5.tar.gz
tar -zxvf cmake-3.20.5.tar.gz
cd cmake-3.20.5
./bootstrap
make
sudo make install

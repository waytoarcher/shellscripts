#!/bin/bash
wget -qO - https://typora.io/linux/public-key.asc | sudo apt-key add -
echo "deb https://typora.io/linux ./" | sudo tee /etc/apt/sources.list.d/typora.list
sudo apt update
sudo apt install typora

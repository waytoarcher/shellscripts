#!/bin/bash
sudo systemctl disable v2ray.service
sudo systemctl stop v2ray.service
sudo docker run -d -p 9000:9000 --name v2ray --restart=always -v /etc/v2ray:/etc/v2ray teddysun/v2ray

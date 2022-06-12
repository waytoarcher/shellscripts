#!/bin/bash
client()
{
docker pull teddysun/xray
sudo mkdir -p /etc/nxray
sudo cp -f client_v2ray.json /etc/nxray/config.json
docker rm -f nxray || true
docker run -d -p 1090:1090 --name nxray --restart=always -v /etc/nxray:/etc/xray teddysun/xray
}

server()
{
docker pull teddysun/xray
sudo mkdir -p /etc/nxray
sudo cp -f server_v2ray.json /etc/xray/config.json
docker rm -f nxray || true
docker run -d -p 8900:8900 --name nxray --restart=always -v /etc/xray:/etc/xray teddysun/xray
}
acme()
{
    curl  https://get.acme.sh | sh -s email=my@example.com
    mkdir -p /data
    "$HOME"/.acme.sh/acme.sh --register-account -m "abc@gmail.com"
    "$HOME"/.acme.sh/acme.sh --issue -d "abc.v2less.com" --standalone -k ec-256 --force
    sleep 2
    acme.sh --installcert -d "abc.v2less.com" --fullchainpath /data/v2ray.crt --keypath /data/v2ray.key --ecc --force
}

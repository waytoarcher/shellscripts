#!/bin/bash
# 关于 gfwlist2privoxy 脚本
# 脚本依赖 base64、curl(支持 https)、perl5 v5.10.0+

# 获取 gfwlist2privoxy 脚本
cd /tmp/ || exit 1
curl -4sSkLO https://raw.github.com/zfl9/gfwlist2privoxy/master/gfwlist2privoxy

# 生成 gfwlist.action 文件
bash gfwlist2privoxy '192.168.122.233:1080'

# 检查 gfwlist.action 文件
#more gfwlist.action # 一般有 5000+ 行

# 应用 gfwlist.action 文件
mv -f gfwlist.action /etc/privoxy
sed -ri 's/gfwlist.action/d' /etc/privoxy/config
echo 'actionsfile gfwlist.action' >>/etc/privoxy/config

# 启动 privoxy.service 服务
systemctl start privoxy.service
systemctl -l status privoxy.service

proxy="http://127.0.0.1:8118"
export http_proxy=$proxy
export https_proxy=$proxy
export no_proxy="localhost, 127.0.0.1, ::1"

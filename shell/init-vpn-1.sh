#!/bin/bsh
# 2020-04-04

# USSAGE="curl https://raw.githubusercontent.com/xyz71148/utils/master/shell/init-vpn-1.sh | bash -s SSPORT SSPASSWORD ALARM_TOKEN PROXY_PROJECT_ID"

SS_PORT=$1
SS_PWD=$2
ALARM_TOKEN=$3
PROXY_PROJECT_ID=$4
HOST="$(dig +short myip.opendns.com @resolver1.opendns.com)"

sudo docker rm -f shadowsocks
sudo docker run -d -e SERVER_START=1 -e SS_PORT=$SS_PORT -e SS_HOST=0.0.0.0 -e SS_M=aes-256-cfb -e SS_PWD=$SS_PWD -e BOOTS=ss -p $SS_PORT:$SS_PORT --cap-add=NET_ADMIN --name shadowsocks sanfun/public:shadowsocks-v1

nohup proxy_go https://$PROXY_PROJECT_ID.appspot.com 0.0.0.0:8081 >> /tmp/proxy.log &

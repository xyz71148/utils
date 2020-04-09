#!/bin/bsh
# 2020-04-04

# USSAGE="curl https://raw.githubusercontent.com/xyz71148/utils/master/shell/init-vpn-12.sh | bash -s $SS_PORT $SS_PWD $ALARM_TOKEN $PROXY_PROJECT_ID $REPORT_URL"

HOST=$(dig +short myip.opendns.com @resolver1.opendns.com)
SS_PORT=$1
SS_PWD=$2
PROXY_PROJECT_ID=$3
REPORT_URL=$4

echo $HOST
echo $SS_PORT
echo $SS_PWD
echo $PROXY_PROJECT_ID
echo $REPORT_URL

sudo docker rm -f shadowsocks
sudo docker run -d -e SERVER_START=1 -e SS_PORT=$SS_PORT -e SS_HOST=0.0.0.0 -e SS_M=aes-256-cfb -e SS_PWD=$SS_PWD -e BOOTS=ss -p $SS_PORT:$SS_PORT --cap-add=NET_ADMIN --name shadowsocks sanfun/public:shadowsocks-v1

sleep 1
sudo docker ps

sudo rm -rf /bin/proxy_go
sudo curl https://$PROXY_PROJECT_ID.appspot.com/static/proxy_go -o /bin/proxy_go
sudo chmod +x /bin/proxy_go

nohup proxy_go 0.0.0.0:8001 0.0.0.0:8000 https://$PROXY_PROJECT_ID.appspot.com  >> /tmp/proxy.log &

curl -X PUT -F ip=$HOST $REPORT_URL


#!/bin/bsh
# 2020-04-04

# USSAGE="curl https://raw.githubusercontent.com/xyz71148/utils/master/shell/init-vpn-12.sh | bash $SS_PORT $SS_PWD $ALARM_TOKEN $PROXY_PROJECT_ID $REPORT_URL"

HOST=$(dig +short myip.opendns.com @resolver1.opendns.com)
SS_PORT=$1
SS_PWD=$2
ALARM_TOKEN=$3
PROXY_PROJECT_ID=$4
REPORT_URL=$5

echo $HOST
echo $SS_PORT
echo $SS_PWD
echo $ALARM_TOKEN
echo $PROXY_PROJECT_ID
echo $REPORT_URL

sudo docker rm -f shadowsocks
sudo docker run -d -e SERVER_START=1 -e SS_PORT=$SS_PORT -e SS_HOST=0.0.0.0 -e SS_M=aes-256-cfb -e SS_PWD=$SS_PWD -e BOOTS=ss -p $SS_PORT:$SS_PORT --cap-add=NET_ADMIN --name shadowsocks sanfun/public:shadowsocks-v1

sleep 1
sudo docker ps

mkdir -p webroot
cat  > webroot/index.php << EOF 
<?php 
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS, PUT, DELETE");
header('Access-Control-Allow-Headers:x-requested-with,content-type');
header('Content-Type: application/json'); 
echo json_encode([\$_SERVER['REQUEST_TIME_FLOAT'],\$_SERVER['REMOTE_ADDR']]);
EOF
nohup sudo php -S 0.0.0.0:80 -t webroot >> /tmp/web.log &

nohup proxy_go https://$PROXY_PROJECT_ID.appspot.com 0.0.0.0:8081 >> /tmp/proxy.log &

curl https://oapi.dingtalk.com/robot/send?access_token=$ALARM_TOKEN \
   -H 'Content-Type: application/json' \
   -d "{\"msgtype\": \"text\", 
  \"text\": {
     \"content\": \"[DEV] $HOST:$SS_PORT UP, SS_PWD: $SS_PWD, http://ping.chinaz.com/$HOST\"
  }
}"

curl -X PUT -F ip=$HOST $REPORT_URL


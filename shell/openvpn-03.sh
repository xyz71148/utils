#!/bin/bash
# BY: Joseph


# USSAGE="curl https://raw.githubusercontent.com/xyz71148/utils/master/shell/openvpn-03.sh | bash -s $OPEN_VPN_PORT $OPEN_VPN_PWD $REPORT_URL $UPLOAD"


OPEN_VPN_PORT=$1
OPEN_VPN_PWD=$2
PROXY_PROJECT_ID=$3
REPORT_URL=$4
UPLOAD=$5

HOST="$(dig +short myip.opendns.com @resolver1.opendns.com)"
HOST_NAME=${HOST//./_}
OVPN_DATA='ovpn-data'

echo "========================"
echo $OPEN_VPN_PORT
echo $OPEN_VPN_PWD
echo $PROXY_PROJECT_ID
echo $REPORT_URL
echo $HOST
echo $HOST_NAME
echo "========================"

FILE=~/ovpn/$HOST_NAME.ovpn
if test -f "$FILE"; then
    echo "$FILE exist"
    sudo docker run --volumes-from $OVPN_DATA -d -p $OPEN_VPN_PORT:$OPEN_VPN_PORT/udp --cap-add=NET_ADMIN kylemanna/openvpn
	  sudo docker ps
    exit 1
fi

sudo apt-get install -y expect
sudo docker rm -f $OVPN_DATA
sudo docker run --name $OVPN_DATA -v /etc/openvpn busybox
sudo docker run --volumes-from $OVPN_DATA kylemanna/openvpn ovpn_genconfig -u udp://$HOST:$OPEN_VPN_PORT

TMP=$(mktemp)

cat > $TMP << EOF 
#exp_internal 1 # Uncomment for debug
set timeout -1
spawn sudo docker run -it --volumes-from $OVPN_DATA kylemanna/openvpn ovpn_initpki
#expect -exact "Confirm removal:"
#send -- "yes\r"
expect -exact "Enter New CA Key Passphrase:"
send -- "$OPEN_VPN_PWD\r"
expect -exact "Re-Enter New CA Key Passphrase:"
send -- "$OPEN_VPN_PWD\r"
expect -exact "Common Name (eg: your user, host, or server name) \[Easy-RSA CA\]:"
send -- "$HOST\r"
expect -exact "Enter pass phrase for /etc/openvpn/pki/private/ca.key:"
send -- "$OPEN_VPN_PWD\r"
expect -exact "Enter pass phrase for /etc/openvpn/pki/private/ca.key:"
send -- "$OPEN_VPN_PWD\r"
expect eof
EOF
echo "========================"

cat $TMP
expect -f $TMP || (echo "ovpn_initpki failed"; exit 1);
rm $TMP
echo "========================"

cat  > $TMP << EOF 
#exp_internal 1 # Uncomment for debug
spawn sudo docker run -it --volumes-from $OVPN_DATA kylemanna/openvpn easyrsa build-client-full $HOST_NAME nopass
expect -exact "Enter pass phrase for /etc/openvpn/pki/private/ca.key"
send -- "$OPEN_VPN_PWD\r"
expect eof
EOF

cat $TMP
expect -f $TMP || (echo "build-client-full failed"; exit 1);
rm $TMP
echo "========================"

mkdir -p ~/ovpn
sudo docker run --volumes-from $OVPN_DATA  kylemanna/openvpn ovpn_getclient $HOST_NAME > ~/ovpn/$HOST_NAME.ovpn
cat ~/ovpn/$HOST_NAME.ovpn
echo "========================"
sudo docker run --volumes-from $OVPN_DATA -d -p $OPEN_VPN_PORT:$OPEN_VPN_PORT/udp --cap-add=NET_ADMIN kylemanna/openvpn
sleep 1
sudo docker ps

nohup proxy_go 0.0.0.0:8001 0.0.0.0:8000 https://$PROXY_PROJECT_ID.appspot.com  >> /tmp/proxy.log &


if test $[UPLOAD] -eq "1"
then
    curl -X PUT $REPORT_URL -F ip=$HOST -F files=@/root/ovpn/$HOST_NAME.ovpn
fi


#!/bin/bash
USSAGE="curl https://raw.githubusercontent.com/xyz71148/utils/master/shell/docker-ss-server-xx.sh | bash -s SSPORT SSPASSWORD"
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

SSPORT=$1
if [ "${SSPORT}" = "" ]; then
    echo "Error: usage: $USSAGE"
    exit 1
else
    SSPORT=$1
fi

SSPASSWORD=$2
if [ "${SSPASSWORD}" = "" ]; then
    echo "Error: usage: $USSAGE"
    exit 1
else
    SSPASSWORD=$2
fi
echo $SSPORT
echo $SSPASSWORD

# Install docker prerequisites
sudo apt update
sudo apt install -y apt-transport-https ca-certificates
sudo apt install -y linux-image-extra-$(uname -r) linux-image-extra-virtual

# Add docker GPG key
sudo apt-key adv \
    --keyserver hkp://ha.pool.sks-keyservers.net:80 \
    --recv-keys 58118E89F3A912897C070ADBF76221572C52609D

# Add docker apt repository
echo "deb https://apt.dockerproject.org/repo ubuntu-xenial main" | sudo tee /etc/apt/sources.list.d/docker.list

# Install the docker engine
sudo apt update
sudo apt install -y docker-engine

# Make sure docker service is running
sudo service docker status
sudo service docker start

# Test docker installation
sudo docker run hello-world

# Install the shadowsocks docker image
sudo docker pull oddrationale/docker-shadowsocks
docker rm -f shadowsocks
sudo docker run -d \
    --name shadowsocks \
    --restart=always \
    -p $SSPORT:$SSPORT \
    oddrationale/docker-shadowsocks \
    -qq \
    -m aes-256-cfb \
    -s 0.0.0.0 \
    -p $SSPORT \
    -k $SSPASSWORD
    

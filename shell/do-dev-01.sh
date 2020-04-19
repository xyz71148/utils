#!/bin/bash
project_id=$1
mkdir -p ~/data/home

FILE=~/data/home/.git
if test -d "$FILE"; then
    cd ~/data/home
    git pull origin master
else
    git clone git@e.coding.net:sanfun/vpn.git ~/data/home
    cd ~/data/home
fi

sudo docker build -f Dockerfile.dev -t vpn_docker_dev .

sudo docker rm -f vpn_docker_dev || { echo "error ";}

sudo docker run --name vpn_docker_dev \
    -e AP_ENV=1 \
    -e APP=sshd,app_dev \
    -e ALIAS_start="cd /data/home && python main.py" \
    -e AP_CLOUDSDK_CORE_PROJECT=$project_id \
    -e AP_GOOGLE_CLOUD_PROJECT=$project_id \
    -e AP_FLASK_ENV=dev \
    -e AP_PYTHONPATH=/data/home \
    -e AP_GOOGLE_APPLICATION_CREDENTIALS=/data/setting/credit.json.log \
    -p 8080:8080 \
    -p "8022:22" \
    -v $PWD:/data/home \
    -v $PWD/docker-data/setting:/data/setting \
    -v ~/data/root_cache:/root/.cache \
    --cap-add=NET_ADMIN \
    --network app \
    -it vpn_docker_dev


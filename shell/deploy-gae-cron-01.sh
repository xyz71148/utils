#!/bin/bsh

USSAGE="curl https://raw.githubusercontent.com/xyz71148/utils/master/shell/deploy-gae-cron-01.sh | bash -s $PROJECT_ID"

gcloud config set project $1 \
  && rm -rf /tmp/vpn && git clone git@e.coding.net:sanfun/vpn.git /tmp/vpn \
  && cd /tmp/vpn \
  && gcloud app deploy cron.yaml -q \
  && rm -rf /tmp/vpn 

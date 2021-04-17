#!/bin/bash
set -e
oldpwd=$PWD
cd $(dirname $0)
if test ! -z "$DOMAIN_LIST"
then
    echo "$DOMAIN_LIST"|jq -srR 'split("\n")|map(select(length > 0))|map(split(" "))|map({(.[0]):.[1]})|add' > domain.json
fi
if test ! -z "$KEY_SH"
then
    echo "$KEY_SH" > key.sh
    . key.sh
fi
certname=$(cat domain.json |jq 'keys_unsorted[0]' -r)
sudo snap install certbot --classic
sudo find . -name "install.sh" -exec bash {} \;
find . -name "config.sh" -exec bash {} \;
certargs="--config-dir $PWD/letsencrypt --work-dir $PWD/work --logs-dir $PWD/log"
certbot $certargs register -m $CERT_EMAIL  --agree-tos --non-interactive || echo account exists

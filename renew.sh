#!/bin/bash
set -e
oldpwd=$PWD
cd $(dirname $0)
export keyScript=${1:-$PWD/key.sh}
if test ! -e "$keyScript"; then
  echo $keyScript not found
  exit 3
fi
if test ! -r "$keyScript"; then
  echo $keyScript can not read
  exit 4
fi
certname=$(cat domain.json |jq 'keys_unsorted[0]' -r)
certlist=$(cat domain.json |jq 'keys_unsorted|map(" -d "+.+" -d *."+.)|add' -r)
certargs="--config-dir $PWD/letsencrypt --work-dir $PWD/work --logs-dir $PWD/log"
certbot $certargs certonly  --cert-name $certname --expand $certlist --manual --preferred-challenges dns --server https://acme-v02.api.letsencrypt.org/directory  --manual-auth-hook $PWD/certbot-renew-hook.sh --manual-cleanup-hook  $PWD/reset.sh --force-renewal $DRY_RUN


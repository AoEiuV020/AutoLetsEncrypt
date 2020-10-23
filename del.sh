#!/bin/sh
# 删除域名对应dns的服务商，
set -e
oldpwd=$PWD
cd $(dirname $0)
domain=$1

if test -z "$domain"; then
  echo domain empty
  exit 1
fi

domainFile=domain.json
if test ! -e $domainFile; then
  echo '{}' >$domainFile
fi
jq "del(.\"$domain\")" $domainFile >$domainFile.bak
mv -f $domainFile.bak $domainFile

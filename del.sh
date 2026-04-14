#!/bin/sh
# 删除域名
set -e
cd "$(dirname "$0")"
domain=$1

if [ -z "$domain" ]; then
    echo "domain empty"
    exit 1
fi

domainFile=domain.json
if [ ! -e "$domainFile" ]; then
    echo '{}' > "$domainFile"
fi
jq "del(.\"$domain\")" "$domainFile" > "$domainFile.bak"
mv -f "$domainFile.bak" "$domainFile"

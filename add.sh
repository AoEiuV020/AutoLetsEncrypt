#!/bin/sh
# 添加域名对应dns的服务商
set -e
cd "$(dirname "$0")"
domain=$1
value=$2

if [ -z "$domain" ]; then
    echo "domain empty"
    exit 1
fi
if [ -z "$value" ]; then
    echo "value empty"
    exit 2
fi

# 校验服务商名称
case "$value" in
    aliyun|tencent|cloudflare) ;;
    *)
        echo "unsupported provider: $value (supports: aliyun, tencent, cloudflare)"
        exit 3
        ;;
esac

domainFile=domain.json
if [ ! -e "$domainFile" ]; then
    echo '{}' > "$domainFile"
fi
jq ".+{\"$domain\":\"$value\"}" "$domainFile" > "$domainFile.bak"
mv -f "$domainFile.bak" "$domainFile"

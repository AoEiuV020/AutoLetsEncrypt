#!/bin/bash
set -e
cd "$(dirname "$0")"

# 解析 DOMAIN_LIST → domain.json
if [ -n "$DOMAIN_LIST" ]; then
    echo "$DOMAIN_LIST" | jq -srR '
        split("\n") | map(select(length > 0)) |
        map(split(" ")) | map({(.[0]):.[1]}) | add
    ' > domain.json
fi

# 写入 key.sh
if [ -n "$KEY_SH" ]; then
    echo "$KEY_SH" > key.sh
fi

# 克隆 acme.sh（如果不存在）
if [ ! -f "acme.sh/acme.sh" ]; then
    git clone --depth 1 https://github.com/acmesh-official/acme.sh.git
fi

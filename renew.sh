#!/bin/bash
set -e
cd "$(dirname "$0")"

# 加载凭据
keyScript=${1:-$PWD/key.sh}
if [ ! -r "$keyScript" ]; then
    echo "key script not found or not readable: $keyScript"
    exit 1
fi
set -a
. "$keyScript"
set +a

# 服务商名称补全 dns_ 前缀
provider_dns() {
    case "$1" in
        dns_*) echo "$1" ;;
        *)     echo "dns_$1" ;;
    esac
}

# 构建域名参数（hybrid DNS 模式）
ACME_ARGS=()
for domain in $(jq -r 'keys_unsorted[]' domain.json); do
    provider=$(jq -r ".\"$domain\"" domain.json)
    dns_name=$(provider_dns "$provider")
    ACME_ARGS+=(-d "$domain" --dns "$dns_name" -d "*.$domain" --dns "$dns_name")
done

# 签发/续签证书
# ACME_SERVER 未设置时使用 acme.sh 默认 CA（ZeroSSL）
# DRY_RUN 非空时使用 staging 测试服务器
SERVER_ARGS=()
if [ -n "$DRY_RUN" ]; then
    SERVER_ARGS=(--staging)
elif [ -n "$ACME_SERVER" ]; then
    SERVER_ARGS=(--server "$ACME_SERVER")
fi

./acme.sh/acme.sh --log --issue \
    --config-home "$PWD/acme-data" \
    "${SERVER_ARGS[@]}" \
    --force \
    --accountemail "$CERT_EMAIL" \
    "${ACME_ARGS[@]}"

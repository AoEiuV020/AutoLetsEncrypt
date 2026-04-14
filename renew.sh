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
    ACME_ARGS+=(--dns "$dns_name" -d "$domain" -d "*.$domain")
done

# 签发/续签证书
# DRY_RUN 可设为 --staging 使用测试服务器
./acme.sh/acme.sh --issue \
    --config-home "$PWD/acme-data" \
    --server letsencrypt \
    --force \
    --accountemail "$CERT_EMAIL" \
    "${ACME_ARGS[@]}" \
    $DRY_RUN

# acme.sh 参考

[acme.sh](https://github.com/acmesh-official/acme.sh)（⭐46.3K）：纯 Shell ACME 客户端，仅需 curl/openssl，支持 [190+ DNS 服务商](https://github.com/acmesh-official/acme.sh/wiki/dnsapi)。

## 安装

```bash
# 在线安装（安装到 ~/.acme.sh/）
curl https://get.acme.sh | sh -s email=my@example.com

# 或 git clone 后使用（CI/CD 推荐）
git clone --depth 1 https://github.com/acmesh-official/acme.sh.git
```

## DNS 服务商

### 阿里云（dns_ali）

```bash
export Ali_Key="AccessKey ID"
export Ali_Secret="AccessKey Secret"
acme.sh --issue --dns dns_ali -d example.com -d '*.example.com'
```

> [wiki: dns_ali](https://github.com/acmesh-official/acme.sh/wiki/dnsapi#dns_ali)

### 腾讯云（dns_tencent）

使用 [TencentCloud API 3.0](https://github.com/acmesh-official/acme.sh/wiki/dnsapi2#dns_tencent)（`dnspod.tencentcloudapi.com`），非旧版 `dns_dp`。

```bash
export Tencent_SecretId="SecretId"
export Tencent_SecretKey="SecretKey"
acme.sh --issue --dns dns_tencent -d example.com -d '*.example.com'
```

> `dns_dp` 使用旧版 DNSPod API（`dnsapi.cn`），凭据为 `DP_Id`/`DP_Key`，不推荐。

### Cloudflare（dns_cf）

```bash
# API Token（推荐，需 Zone > DNS > Edit 权限）
export CF_Token="your-token"
export CF_Account_ID="your-account-id"  # 多域名用 Account ID
acme.sh --issue --dns dns_cf -d example.com -d '*.example.com'
```

> 也支持 `CF_Zone_ID`（单域名）或 `CF_Key`+`CF_Email`（全局密钥，不推荐）。[wiki: dns_cf](https://github.com/acmesh-official/acme.sh/wiki/dnsapi#1-cloudflare-option)

## 混合 DNS 服务商（Hybrid Mode）

单证书中不同域名使用[不同 DNS 服务商](https://github.com/acmesh-official/acme.sh/wiki/How-to-issue-a-cert#3-multiple-domains-san-mode--hybrid-mode)：

```bash
acme.sh --issue \
  -d a.com  --dns dns_ali \
  -d '*.a.com' --dns dns_ali \
  -d b.com  --dns dns_tencent \
  -d '*.b.com' --dns dns_tencent \
  -d c.com  --dns dns_cf \
  -d '*.c.com' --dns dns_cf
```

每个 `--dns` 作用于紧跟其后的 `-d` 域名，直到遇到下一个 `--dns`。

## 关键参数

| 参数 | 说明 |
|------|------|
| `--server letsencrypt` | 使用 Let's Encrypt（默认 CA 是 ZeroSSL） |
| `--force` | 强制续签（即使证书未到期） |
| `--config-home /path` | 自定义配置/证书存储目录（CI/CD 必选） |
| `--cert-home /path` | 单独设置证书存储目录 |
| `--install-cert -d example.com` | 将证书复制到指定路径 |
| `--renew -d example.com` | 续签指定域名 |
| `--renew-all` | 续签所有证书 |
| `--cron` | 自动检查并续签到期证书 |

## 证书文件

签发后证书保存在 `<config-home>/<domain>/`：

| 文件 | 说明 |
|------|------|
| `<domain>.cer` | 域名证书 |
| `<domain>.key` | 私钥 |
| `fullchain.cer` | 完整证书链（部署用） |
| `ca.cer` | CA 证书 |

## CI/CD 用法

```bash
# 1. 下载 acme.sh（不执行 --install）
git clone --depth 1 https://github.com/acmesh-official/acme.sh.git /tmp/acme.sh

# 2. 设置环境变量（从 CI Secrets 注入）

# 3. 签发/续签
/tmp/acme.sh/acme.sh --issue \
  --config-home ./certs \
  --server letsencrypt \
  --force \
  -d a.com --dns dns_ali \
  -d b.com --dns dns_tencent

# 4. 证书在 ./certs/<domain>/ 下
```

环境变量首次使用后保存到 `<config-home>/account.conf`，续签时自动读取。

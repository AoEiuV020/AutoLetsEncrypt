# acme.sh 参考

[acme.sh](https://github.com/acmesh-official/acme.sh)（⭐46.3K）：纯 Shell ACME 客户端，仅需 curl/openssl，支持 [190+ DNS 服务商](https://github.com/acmesh-official/acme.sh/wiki/dnsapi)。

## 安装

```bash
# 在线安装（安装到 ~/.acme.sh/）
curl https://get.acme.sh | sh -s email=my@example.com

# 或 git clone 后使用（CI/CD 推荐）
git clone --depth 1 https://github.com/acmesh-official/acme.sh.git
```

## 基本用法

```bash
# 签发单域名证书（DNS 方式）
acme.sh --issue --dns dns_ali -d example.com

# 签发通配符证书
acme.sh --issue -d example.com --dns dns_ali -d '*.example.com'

# 续签指定域名
acme.sh --renew -d example.com

# 续签所有证书
acme.sh --renew-all

# 自动检查并续签到期证书（适合 cron）
acme.sh --cron
```

## 关键参数

| 参数 | 说明 |
|------|------|
| `--server letsencrypt` | 使用 Let's Encrypt（默认 CA 是 ZeroSSL） |
| `--server letsencrypt_test` | 使用 Let's Encrypt [测试服务器](https://acme-staging-v02.api.letsencrypt.org/directory)（不受速率限制） |
| `--staging` | 等同于 `--server letsencrypt_test`，但不能与 `--server` 同时使用（`--server` 优先） |
| `--force` | 强制续签（即使证书未到期） |
| `--config-home /path` | 自定义配置/证书存储目录（CI/CD 必选） |
| `--cert-home /path` | 单独设置证书存储目录 |
| `--install-cert -d example.com` | 将证书复制到指定路径 |
| `--accountemail my@example.com` | 设置注册邮箱 |

## 证书文件

签发后证书保存在 `<config-home>/<domain>/`：

| 文件 | 说明 |
|------|------|
| `<domain>.cer` | 域名证书 |
| `<domain>.key` | 私钥 |
| `fullchain.cer` | 完整证书链（部署用） |
| `ca.cer` | CA 证书 |

环境变量首次使用后保存到 `<config-home>/account.conf`，续签时自动读取。

---

## DNS 服务商

### 阿里云（dns_ali）

```bash
export Ali_Key="AccessKey ID"
export Ali_Secret="AccessKey Secret"
acme.sh --issue -d example.com --dns dns_ali -d '*.example.com'
```

> [wiki: dns_ali](https://github.com/acmesh-official/acme.sh/wiki/dnsapi#dns_ali)

### 腾讯云（dns_tencent）

使用 [TencentCloud API 3.0](https://github.com/acmesh-official/acme.sh/wiki/dnsapi2#dns_tencent)（`dnspod.tencentcloudapi.com`），非旧版 `dns_dp`。

```bash
export Tencent_SecretId="SecretId"
export Tencent_SecretKey="SecretKey"
acme.sh --issue -d example.com --dns dns_tencent -d '*.example.com'
```

> `dns_dp` 使用旧版 DNSPod API（`dnsapi.cn`），凭据为 `DP_Id`/`DP_Key`，不推荐。

### Cloudflare（dns_cf）

两种认证方式：

```bash
# 方式一：API Token（推荐，最小权限）
# 需要 Zone > DNS > Edit 权限
export CF_Token="your-api-token"
export CF_Account_ID="your-account-id"

# 方式二：全局 API Key（不推荐）
export CF_Key="your-global-api-key"
export CF_Email="your-email@example.com"

acme.sh --issue -d example.com --dns dns_cf -d '*.example.com'
```

| 变量 | 说明 |
|------|------|
| `CF_Token` | [API Token](https://dash.cloudflare.com/profile/api-tokens)（推荐） |
| `CF_Account_ID` | 账户 ID（Token 方式必填） |
| `CF_Zone_ID` | Zone ID（可选，单域名可用来代替 Account ID） |
| `CF_Key` | 全局 API Key（不推荐） |
| `CF_Email` | 账户邮箱（仅 Key 方式需要） |

> [wiki: dns_cf](https://github.com/acmesh-official/acme.sh/wiki/dnsapi#1-cloudflare-option)

## 混合 DNS 服务商（Hybrid Mode）

单证书中不同域名使用[不同 DNS 服务商](https://github.com/acmesh-official/acme.sh/wiki/How-to-issue-a-cert#3-multiple-domains-san-mode--hybrid-mode)：

```bash
acme.sh --issue \
  -d a.com  --dns dns_ali \
  -d '*.a.com' --dns dns_ali \
  -d b.com  --dns dns_cf \
  -d '*.b.com' --dns dns_cf
```

> **`-d` 与 `--dns` 按位置 1:1 匹配**：acme.sh 将所有 `-d` 和所有验证方式分别累加为逗号列表，按位置一一对应。位置缺失时自动复用上一个（所以单服务商只写一次 `--dns` 即可），但混合模式必须每个域名都显式写明。

## CI/CD 用法

```bash
# 1. 下载 acme.sh（不执行 --install）
git clone --depth 1 https://github.com/acmesh-official/acme.sh.git /tmp/acme.sh

# 2. 设置环境变量（从 CI Secrets 注入）

# 3. 签发/续签（每个 -d 配一个 --dns）
/tmp/acme.sh/acme.sh --issue \
  --config-home ./certs \
  --server letsencrypt \
  --force \
  -d a.com --dns dns_ali \
  -d '*.a.com' --dns dns_ali \
  -d b.com --dns dns_cf \
  -d '*.b.com' --dns dns_cf

# 4. 证书在 ./certs/<domain>_ecc/ 下
```

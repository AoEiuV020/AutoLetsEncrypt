# ACME 客户端

除 certbot 外，还有其他 ACME 客户端内置了 DNS 服务商支持，无需手写 DNS hook 脚本。

## 对比

| 特性 | certbot | [acme.sh](https://github.com/acmesh-official/acme.sh)（⭐46.3K） | [lego](https://github.com/go-acme/lego)（⭐9.5K） |
|------|---------|---------|------|
| 语言 | Python | Shell | Go |
| 安装方式 | snap / pip | curl 一行安装 | 单二进制下载 |
| DNS 服务商数 | 需插件或手动 hook | ~150+ | ~180 |
| 阿里云 | 需手动 hook | ✅ `dns_ali` | ✅ `alidns` |
| 腾讯云 DNSPod | 需手动 hook | ✅ `dns_dp` | ✅ `tencentcloud` |
| Cloudflare | 需插件 `certbot-dns-cloudflare` | ✅ `dns_cf` | ✅ `cloudflare` |
| 通配符证书 | ✅ | ✅ | ✅ |
| 无 root 运行 | ❌ 需 snap/sudo | ✅ | ✅ |
| GitHub Actions 适配 | 需 snap install | curl 安装即可 | 下载二进制即可 |
| 凭据管理 | 文件/环境变量 | 自动保存到 account.conf | 环境变量 |

## acme.sh

纯 Shell 实现，无依赖（仅需 curl/openssl）。

### 基本用法

```bash
# 安装
curl https://get.acme.sh | sh -s email=my@example.com

# 使用阿里云 DNS 申请通配符证书
export Ali_Key="your-key"
export Ali_Secret="your-secret"
acme.sh --issue --dns dns_ali -d example.com -d '*.example.com'

# 使用腾讯云 DNSPod
export DP_Id="your-id"
export DP_Key="your-key"
acme.sh --issue --dns dns_dp -d example.com -d '*.example.com'

# 使用 Cloudflare
export CF_DNS_API_TOKEN="your-token"
acme.sh --issue --dns dns_cf -d example.com -d '*.example.com'
```

### 特点

- 自动续签（cron job）
- 凭据首次输入后保存到 `~/.acme.sh/account.conf`，后续续签无需重复配置
- 默认 CA 是 ZeroSSL（可切换为 Let's Encrypt：`--server letsencrypt`）

## lego

Go 编写的单二进制 ACME 客户端，[~180 个 DNS 服务商](https://go-acme.github.io/lego/dns)内置支持。

### 基本用法

```bash
# 下载（GitHub Actions 中可用 go install 或直接下载 release）
# https://github.com/go-acme/lego/releases

# 使用阿里云 DNS
ALICLOUD_ACCESS_KEY=your-key \
ALICLOUD_SECRET_KEY=your-secret \
lego --email my@example.com --dns alidns -d '*.example.com' -d example.com run

# 使用腾讯云
TENCENTCLOUD_SECRET_ID=your-id \
TENCENTCLOUD_SECRET_KEY=your-key \
lego --email my@example.com --dns tencentcloud -d '*.example.com' -d example.com run

# 使用 Cloudflare
CF_DNS_API_TOKEN=your-token \
lego --email my@example.com --dns cloudflare -d '*.example.com' -d example.com run

# 续签
lego --email my@example.com --dns cloudflare -d example.com renew
```

### 特点

- 单二进制，零依赖，下载即用
- 证书默认保存在 `.lego/certificates/` 目录
- 支持 `--path` 指定证书存储路径
- 支持 `renew --hook` 续签后执行自定义脚本

## 对本项目的意义

使用 acme.sh 或 lego 可以**完全替代 certbot + 手写 DNS hook 脚本**：

- 不再需要 `certbot-renew-hook.sh`、各服务商的 `apply.sh`/`reset.sh`
- 不再需要安装 certbot（snap）和 aliyun-cli
- DNS 记录的添加/删除/等待传播 全部由 ACME 客户端内部处理
- 工作流简化为：下载工具 → 设置环境变量 → 一条命令完成申请/续签

**推荐 lego**：单二进制适合 CI/CD 环境，下载解压即可运行，无需安装步骤。

# AGENTS.md — AutoLetsEncrypt

## 项目概述

自动申请和续签 Let's Encrypt 证书的工具，通过 acme.sh hybrid DNS 模式 + GitHub Actions 实现无人值守。证书存储在 WebDAV 上。

## 架构

```
GitHub Actions (每周日 UTC 20:00 触发)
  ├── 从 WebDAV 下载旧配置（acme-data.tar.gz）
  ├── init.sh — 解析 DOMAIN_LIST → domain.json，写入 key.sh，克隆 acme.sh
  ├── renew.sh — source key.sh，构建 acme.sh hybrid DNS 命令，签发/续签证书
  └── 上传 acme-data.tar.gz 到 WebDAV
```

核心机制：acme.sh hybrid DNS 模式，一条命令中为不同域名指定不同 DNS 插件：
```
acme.sh --issue --dns dns_ali -d a.com -d '*.a.com' --dns dns_cf -d b.com -d '*.b.com'
```

## 目录结构

| 路径 | 说明 |
|------|------|
| `init.sh` | 初始化：解析域名列表→domain.json、写入 key.sh、克隆 acme.sh |
| `renew.sh` | 续签入口：加载凭据、构建 hybrid DNS 参数、调用 acme.sh |
| `add.sh` / `del.sh` | 本地管理 domain.json（域名→服务商映射） |
| `extract.sh` | 部署端脚本：从 WebDAV 拉取证书并执行 /etc/acme-data.d/*.sh 部署钩子 |
| `key-example.sh` | 密钥配置模板（acme.sh 环境变量格式） |
| `.github/workflows/renew.yml` | Actions 自动续签工作流 |
| `.github/workflows/debugger.yml` | Actions 调试用（tmate） |
| `md/参考/` | 开发参考文档 |

## DNS 服务商

所有 DNS 操作由 acme.sh 内置插件完成，本项目不包含任何服务商实现代码。

| 服务商 | acme.sh 插件 | 环境变量 |
|--------|-------------|---------|
| aliyun | dns_ali | `Ali_Key`, `Ali_Secret` |
| tencent | dns_tencent | `Tencent_SecretId`, `Tencent_SecretKey` |
| cloudflare | dns_cf | `CF_Token`, `CF_Account_ID` |

服务商名称映射定义在 renew.sh 的 `provider_dns()` 函数中。

## 关键配置（GitHub Secrets）

| Secret | 说明 |
|--------|------|
| `DOMAIN_LIST` | 域名列表，每行 `<域名> <服务商>` |
| `KEY_SH` | shell 脚本，定义 acme.sh 所需的 DNS 服务商凭据变量 |
| `WEBDAV_URL` | WebDAV 地址（含认证信息） |

## 运行时生成的文件

| 文件 | 来源 | 说明 |
|------|------|------|
| `domain.json` | init.sh 从 DOMAIN_LIST 生成 | 域名→服务商映射 |
| `key.sh` | init.sh 从 KEY_SH 写入 | 服务商凭据脚本 |
| `acme.sh/` | init.sh git clone | acme.sh 客户端 |
| `acme-data/` | acme.sh 生成 | 证书、账号配置（--config-home） |

## 开发约束

- 运行环境为 GitHub Actions `ubuntu-latest`
- 敏感信息通过 Secrets 注入，禁止硬编码
- acme.sh 不做安装（`--issue` 直接调用），通过 `--config-home` 指定数据目录
- 证书文件位于 `acme-data/<首个域名>/` 下：`<域名>.cer`、`<域名>.key`、`fullchain.cer`、`ca.cer`

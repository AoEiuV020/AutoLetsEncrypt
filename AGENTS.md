# AGENTS.md — AutoLetsEncrypt

## 项目概述

自动申请和续签 Let's Encrypt 证书的工具，通过 certbot DNS challenge + GitHub Actions 实现无人值守。证书存储在 WebDAV 上。

## 架构

```
GitHub Actions (每周日 UTC 20:00 触发)
  ├── 从 WebDAV 下载旧证书配置
  ├── init.sh — 安装 certbot、配置 DNS 服务商 CLI、注册账号
  ├── renew.sh — 调用 certbot certonly，钩子脚本自动处理 DNS 验证
  │   ├── certbot-renew-hook.sh (--manual-auth-hook) — 添加 _acme-challenge TXT 记录
  │   └── reset.sh (--manual-cleanup-hook) — 删除 TXT 记录
  └── 上传新证书到 WebDAV
```

## 目录结构

| 路径 | 说明 |
|------|------|
| `init.sh` | 初始化：解析域名列表、安装 certbot 和服务商工具、注册账号 |
| `renew.sh` | 续签入口：调用 certbot 并指定钩子 |
| `certbot-renew-hook.sh` | certbot auth hook：根据域名查找服务商并调用 apply.sh |
| `reset.sh` | certbot cleanup hook：调用服务商的 reset.sh 删除记录 |
| `add.sh` / `del.sh` | 本地管理 domain.json（域名→服务商映射） |
| `extract.sh` | 部署端脚本：从 WebDAV 拉取证书并执行部署钩子 |
| `key-example.sh` | 密钥配置模板 |
| `<provider>/` | 各 DNS 服务商实现目录 |
| `<provider>/install.sh` | 安装该服务商依赖 |
| `<provider>/apply.sh` | 添加 _acme-challenge TXT 记录 |
| `<provider>/reset.sh` | 删除所有 _acme-challenge 记录 |
| `<provider>/query.sh` | 查询 DNS 记录 |
| `.github/workflows/renew.yml` | Actions 自动续签工作流 |
| `.github/workflows/debugger.yml` | Actions 调试用（tmate） |

## DNS 服务商

| 服务商 | 实现方式 | 外部依赖 |
|--------|---------|---------|
| aliyun | aliyun CLI | 需下载安装 aliyun-cli |
| tencent | curl + openssl 手动签名 | 无额外依赖，但代码复杂 |
| cloudflare | curl + Bearer Token | 无额外依赖，API 简洁 |
| namecheap | 未实现（API 需付费资格） | — |

## 关键配置（GitHub Secrets）

| Secret | 说明 |
|--------|------|
| `DOMAIN_LIST` | 域名列表，每行 `<域名> <服务商>` |
| `KEY_SH` | shell 脚本，定义各服务商密钥变量 |
| `WEBDAV_URL` | WebDAV 地址（含认证信息） |

## 开发约束

- 运行环境为 GitHub Actions `ubuntu-latest`
- 敏感信息通过 Secrets 注入，禁止硬编码
- domain.json 是运行时生成的中间文件（域名→服务商映射）
- certbot 通过 snap 安装

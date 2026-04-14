# GitHub Actions 预装环境

[ubuntu-latest（24.04）完整清单](https://github.com/actions/runner-images/blob/main/images/ubuntu/Ubuntu2404-Readme.md)中与本项目相关的工具。

## 语言运行时

| 运行时 | 默认版本 | 可选版本 | 说明 |
|--------|---------|---------|------|
| Node.js | 20.20.2 | 22.22.2, 24.14.1 | 预装，用 `actions/setup-node` 切换版本 |
| Python | 3.12.3 | 3.10–3.14 | 预装 |
| Bash | 5.2.21 | — | 预装 |

## 包管理器

| 工具 | 版本 |
|------|------|
| npm | 10.8.2 |
| pip3 | 24.0 |
| snap | 预装 |

## 本项目用到的系统工具

| 工具 | 版本 | 本项目用途 |
|------|------|-----------|
| curl | 8.5.0 | HTTP API 调用 |
| jq | 1.7 | JSON 处理 |
| openssl | 3.0.13 | HMAC 签名 |
| tar | 1.35 | 打包证书 |
| git | 2.53.0 | checkout |

## 本项目额外安装的工具

| 工具 | 当前安装方式 | 是否必须 |
|------|------------|---------|
| certbot | `snap install certbot --classic` | 可被 acme.sh / lego 替代 |
| aliyun-cli | 手动下载 tgz | 可被 HTTP API 或 SDK 替代 |

## 关键结论

- Node.js 20+ 预装，**零安装成本**即可使用 `fetch()`、`crypto` 等内置模块
- Python 3.12 预装，也是零安装成本的备选
- 如果换用 [lego](ACME客户端.md#lego)，是单个 Go 二进制文件，下载即用，无需 snap

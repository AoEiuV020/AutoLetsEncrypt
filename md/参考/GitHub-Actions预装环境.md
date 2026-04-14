# GitHub Actions 预装环境

[ubuntu-latest（24.04）完整清单](https://github.com/actions/runner-images/blob/main/images/ubuntu/Ubuntu2404-Readme.md)。

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

## 系统工具

| 工具 | 版本 | 常见用途 |
|------|------|---------|
| curl | 8.5.0 | HTTP 请求 |
| jq | 1.7 | JSON 处理 |
| openssl | 3.0.13 | 加密/签名 |
| tar | 1.35 | 打包压缩 |
| git | 2.53.0 | 版本控制 |

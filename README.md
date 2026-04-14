# AutoLetsEncrypt

通过 GitHub Actions 自动申请和续签 [Let's Encrypt](https://letsencrypt.org/) 证书，使用 [acme.sh](https://github.com/acmesh-official/acme.sh) hybrid DNS 模式支持多域名多服务商单证书。

## 工作原理

```
GitHub Actions (每周日 UTC 20:00)
  ├── 从 WebDAV 下载旧配置（acme-data.tar.gz）
  ├── init.sh — 解析域名列表、写入密钥、克隆 acme.sh
  ├── renew.sh — 构建 hybrid DNS 命令，签发/续签证书
  └── 上传新配置到 WebDAV
```

acme.sh hybrid DNS 模式允许在一张证书中混合使用不同 DNS 服务商，每个域名自动签发主域名和通配符（`*.domain`）。

## 使用方法

Fork 本仓库后，在 Settings → Secrets and variables → Actions 中配置以下 Secrets：

### DOMAIN_LIST

域名列表，每行格式为 `<域名> <服务商>`，空格分隔：

```
domain1.com ali
domain1.cn tencent
domain2.name cf
```

DOMAIN_LIST 中的服务商名称会自动补全 `dns_` 前缀（`ali` → `dns_ali`），也可直接写完整名称（`dns_ali`）。全部可用的 DNS 插件见 [acme.sh wiki](https://github.com/acmesh-official/acme.sh/wiki/dnsapi)。

常用服务商：

| 名称 | acme.sh DNS 插件 | 所需凭据 |
|---------|-----------------|---------|
| ali | dns_ali | `Ali_Key` + `Ali_Secret` |
| tencent | dns_tencent | `Tencent_SecretId` + `Tencent_SecretKey`（TencentCloud API 3.0） |
| cf | dns_cf | `CF_Token` + `CF_Account_ID` |

### KEY_SH

Shell 脚本格式的密钥配置，参考 [key-example.sh](key-example.sh)：

```shell
#!/bin/sh
CERT_EMAIL=your@email.com
Ali_Key=your_ali_access_key
Ali_Secret=your_ali_secret
Tencent_SecretId=your_tencent_secret_id
Tencent_SecretKey=your_tencent_secret_key
CF_Token=your_cf_api_token
CF_Account_ID=your_cf_account_id
```

只需配置实际用到的服务商凭据。

### WEBDAV_URL

WebDAV 地址（含认证信息），用于存储证书配置：

```
https://user:pass@webdav.example.com/path
```

## 配置完成后

每周日凌晨 4 点（UTC+8）自动续签，也可在 [Actions](../../actions/workflows/renew.yml) 页面手动触发。

**部署不在本项目范围内。** 证书上传到 WebDAV 后，可使用 crontab + [extract.sh](extract.sh) 定期拉取部署，或自行编写部署脚本。extract.sh 会检查归档更新时间，仅在最近 24 小时内有更新时才部署，并执行 `/etc/acme-data.d/*.sh` 中的重启钩子。

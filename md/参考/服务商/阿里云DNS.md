# 阿里云 DNS API

[阿里云 DNS（Alidns）](https://www.alibabacloud.com/help/en/alibaba-cloud-dns/latest/api-alidns-2015-01-09-dir-parsing-records)用于管理域名解析记录。

## API 概要

| 项目 | 值 |
|------|-----|
| 端点 | `https://alidns.aliyuncs.com/` |
| API 版本 | 2015-01-09 |
| 签名方式 | HMAC-SHA1 |
| 协议 | HTTPS GET/POST |
| 认证参数 | AccessKeyId + 签名 |

## 本项目需要的 Action

| Action | 说明 | 必需参数 |
|--------|------|---------|
| `AddDomainRecord` | 添加解析记录 | DomainName, RR, Type, Value |
| `DeleteDomainRecord` | 删除解析记录 | RecordId |
| `DescribeSubDomainRecords` | 查询子域名记录（用于获取 RecordId） | SubDomain |
| `DescribeDomainRecords` | 查询域名记录列表 | DomainName |

## 签名流程

1. 构造规范化请求字符串（参数按字母排序，URL encode）
2. 构造待签名字符串：`GET&%2F&<URL编码后的请求字符串>`
3. 使用 `HMAC-SHA1` 和 `AccessKeySecret + "&"` 计算签名
4. Base64 编码后 URL encode，附加到请求中

acme.sh 的 [`dns_ali.sh`](https://github.com/acmesh-official/acme.sh/blob/master/dnsapi/dns_ali.sh) 是一个完整的 shell 实现参考。

## Node.js SDK

| 包名 | 版本 | 说明 |
|------|------|------|
| [`@alicloud/alidns20150109`](https://registry.npmjs.org/@alicloud/alidns20150109) | 4.3.5 | 官方 SDK，依赖 `@alicloud/openapi-core` |

```javascript
const Alidns = require('@alicloud/alidns20150109');
const OpenApi = require('@alicloud/openapi-client');

const config = new OpenApi.Config({
  accessKeyId: process.env.ALICLOUD_ACCESS_KEY,
  accessKeySecret: process.env.ALICLOUD_SECRET_KEY,
  endpoint: 'alidns.cn-hangzhou.aliyuncs.com',
});
const client = new Alidns.default(config);

// 添加 TXT 记录
await client.addDomainRecord({
  domainName: 'example.com',
  RR: '_acme-challenge',
  type: 'TXT',
  value: 'validation-token',
});
```

## Python SDK

| 包名 | 说明 |
|------|------|
| `alibabacloud-alidns20150109` | 官方 Python SDK |

## 零依赖方案

直接用 Node.js `crypto.createHmac('sha1', ...)` 实现签名，`fetch()` 发请求，无需安装任何 npm 包。签名逻辑可参考 acme.sh 源码中的 `_ali_rest` 函数。

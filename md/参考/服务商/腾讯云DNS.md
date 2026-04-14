# 腾讯云 DNS API

[腾讯云 DNSPod API 3.0](https://cloud.tencent.com/document/api/1427/56166) 是当前版本。旧版 `cns.api.qcloud.com/v2/` **已废弃**，不应继续使用。

## API 概要

| 项目 | 值 |
|------|-----|
| 端点 | `dnspod.tencentcloudapi.com` |
| API 版本 | 2021-03-23 |
| 签名方式 | TC3-HMAC-SHA256 |
| Region | 不需要（DNS 服务无地域概念） |

## 本项目需要的 Action

| Action | 说明 | 必需参数 |
|--------|------|---------|
| [`CreateRecord`](https://cloud.tencent.com/document/api/1427/56180) | 添加解析记录 | Domain, SubDomain, RecordType, RecordLine, Value |
| [`DeleteRecord`](https://cloud.tencent.com/document/api/1427/56176) | 删除解析记录 | Domain, RecordId |
| [`DescribeRecordList`](https://cloud.tencent.com/document/api/1427/56166) | 查询记录列表 | Domain |

## TC3-HMAC-SHA256 签名流程

1. 拼接 `CanonicalRequest`：HTTPMethod + URI + QueryString + Headers + SignedHeaders + HashedPayload
2. 拼接 `StringToSign`：Algorithm + Timestamp + CredentialScope + Hash(CanonicalRequest)
3. 用 SecretKey 按日期/服务/请求 逐层派生密钥
4. 计算最终签名

比旧版 v2 复杂，**强烈建议使用 SDK** 而非手写签名。

## Node.js SDK

| 包名 | 版本 | 说明 |
|------|------|------|
| [`tencentcloud-sdk-nodejs-dnspod`](https://registry.npmjs.org/tencentcloud-sdk-nodejs-dnspod) | 4.1.213 | 官方 SDK，仅含 DNSPod 模块 |

```javascript
const tencentcloud = require('tencentcloud-sdk-nodejs-dnspod');
const DnspodClient = tencentcloud.dnspod.v20210323.Client;

const client = new DnspodClient({
  credential: {
    secretId: process.env.TENCENTCLOUD_SECRET_ID,
    secretKey: process.env.TENCENTCLOUD_SECRET_KEY,
  },
});

// 添加 TXT 记录
await client.CreateRecord({
  Domain: 'example.com',
  SubDomain: '_acme-challenge',
  RecordType: 'TXT',
  RecordLine: '默认',
  Value: 'validation-token',
});
```

## Python SDK

| 包名 | 说明 |
|------|------|
| `tencentcloud-sdk-python-dnspod` | 官方 Python SDK |

## 与旧 API 的差异

| 对比项 | 旧版 v2 | 新版 API 3.0 |
|--------|---------|-------------|
| 端点 | `cns.api.qcloud.com/v2/` | `dnspod.tencentcloudapi.com` |
| 签名 | HmacSHA256（简单拼接） | TC3-HMAC-SHA256（多层派生） |
| 请求格式 | GET + QueryString | POST + JSON body |
| SDK 支持 | 已停止维护 | 持续更新 |
| 状态 | **已废弃** | 当前版本 |

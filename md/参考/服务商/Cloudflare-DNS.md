# Cloudflare DNS API

[Cloudflare API v4](https://developers.cloudflare.com/api/) 用于管理 DNS 记录。

## API 概要

| 项目 | 值 |
|------|-----|
| 端点 | `https://api.cloudflare.com/client/v4/` |
| 认证方式 | Bearer Token（推荐）或 API Key + Email |
| 速率限制 | 1,200 请求 / 5 分钟 / 用户，超限返回 429 并封禁 5 分钟 |

## 本项目需要的接口

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/zones/{zone_id}/dns_records` | 创建记录 |
| DELETE | `/zones/{zone_id}/dns_records/{id}` | 删除记录 |
| GET | `/zones/{zone_id}/dns_records?name={name}` | 查询记录（获取 record id） |
| GET | `/zones?name={domain}` | 查询 Zone ID |

## 认证

推荐使用 [API Token](https://dash.cloudflare.com/profile/api-tokens)（细粒度权限）：

- 所需权限：`Zone / DNS / Edit` + `Zone / Zone / Read`
- Header：`Authorization: Bearer <token>`

项目当前使用的 Bearer Token 方式是官方推荐做法，**无需改动**。

## Node.js SDK

| 包名 | 版本 | 说明 |
|------|------|------|
| [`cloudflare`](https://registry.npmjs.org/cloudflare) | 5.2.0 | 官方 TypeScript SDK |

```javascript
const Cloudflare = require('cloudflare');
const cf = new Cloudflare({ apiToken: process.env.CLOUDFLARE_API_TOKEN });

// 获取 Zone ID
const zones = await cf.zones.list({ name: 'example.com' });
const zoneId = zones.result[0].id;

// 添加 TXT 记录
await cf.dns.records.create({
  zone_id: zoneId,
  type: 'TXT',
  name: '_acme-challenge.example.com',
  content: 'validation-token',
});
```

## Python SDK

| 包名 | 说明 |
|------|------|
| `cloudflare`（PyPI） | 官方 Python SDK |

## 零依赖方案

Cloudflare API 最简单，直接用 `fetch()` + Bearer Token 即可，无需 SDK。项目当前的 curl 实现已经足够简洁，迁移到 Node.js 时只需把 curl 换成 fetch。

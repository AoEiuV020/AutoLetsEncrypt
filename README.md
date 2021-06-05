# AutoLetsEncrypt
用于自动申请letsencrypt证书，通过手动dns钩子实现无人值守续签，使用actions每周自动续签，

## 使用方法
fork后在settings - Secrets中配置敏感数据，
1. DOMAIN_LIST 需要申请证书的域名列表，一行一个，格式为“<域名> <服务商>”,  
   空格分隔，服务商目前支持的包括，  
   | 阿里云: aliyun  
   | 腾讯云: tencent  
   | cloudflare: cloudflare  
   示例：
```
domain1.com aliyun
domain1.cn tencent
domain1.cc aliyun
domain2.name cloudflare
```
2. KEY_SH 参考[key-example.sh](key-example.sh), 配置用到的服务商accessKey，以及邮箱用于注册certbot接收续期提醒之类邮件，
   示例：
```shell
#!/bin/sh
CERT_EMAIL=*********@*****.***
ALIYUN_KEY=************************
ALIYUN_SECRET=******************************
TENCENT_ID=************************************
TENCENT_KEY=********************************
CLOUD_FLARE_TOKEN=****************************************
```
3. WEBDAV_URL webdav网盘地址，包括用户名密码，
   示例：
```
https://user:pass@webdav.example.com/path/file
```

然后就可以了，每周一凌晨4点自动从webdav下载旧配置（如果没有就会创建），续签后上传回webdav，  
也可以在[actions](../../actions/workflows/renew.yml)中点击Run workflow手动运行，

**不涉及部署**, 已经上传到webdav了大可简单使用crontab每周自动从webdav获取证书并部署，
参考[extract.sh](extract.sh),  
或者自己写部署脚本放在letsencrypt/renewal-hooks/deploy续签后自动运行，通过自己规定的方法发布到自己的服务器上，

## 已知问题
* 偶尔会因网络等各种临时问题导致续签失败，只要重试或者等下周自动再次续签就可以了，
* actions log中会泄漏域名列表，禁掉会影响排查问题，以后再考虑，
* 没有实际用到的服务商也会尝试配置，可能导致错误，主要是说aliyun，
* 添加域名时，老证书没有吊销，快过期时会收到邮件提醒续期，

## 计划中
* 使用github releases保存加密后的证书用于后续的续签，这样就能省下一个webdav,



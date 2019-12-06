# Let's Encrypt Manual Hook
用于自动申请letsencrypt证书，通过手动dns钩子实现，  
**只用命令行程序，不使用高级语言**  

一个文件夹代表一个支持的dns服务商，    
| 阿里云: aliyun  
| 腾讯云: tencent  
| cloudflare: cloudflare  

依赖json解析库: jq  
ubuntu:
```
sudo apt install -y jq
```

使用add.sh添加域名对应的服务商，  
```
./add.sh aoeiuv020.com aliyun
```

文件夹中的install.sh用于安装该服务商必须的工具，  
部分依赖在注释中表明，  
```
./aliyun/install.sh
```

key.sh保存dns服务商的Token相关，
```
cp -i key-example.sh key.sh
```

certbot自动续签使用certbot-renew-hook.sh  
自动续签后清理记录使用reset.sh  
```
certbot-auto renew  --manual-public-ip-logging-ok --cert-name aoeiuv020.com  --manual-auth-hook certbot-renew-hook.sh --manual-cleanup-hook  reset.sh
```

初次申请同理，  
```
certbot-auto certonly  --manual-public-ip-logging-ok  -d *.aoeiuv020.com  -d aoeiuv020.com  -d *.aoeiuv020.cc  -d aoeiuv020.cc  -d *.aoeiuv020.cn  -d aoeiuv020.cn --manual --preferred-challenges dns --server https://acme-v02.api.letsencrypt.org/directory  --manual-auth-hook certbot-renew-hook.sh --manual-cleanup-hook reset.sh
```


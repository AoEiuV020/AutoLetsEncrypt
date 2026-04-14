#!/bin/bash
set -e
ztime=$(stat -c %Y /mnt/webdav/certs/acme-data.tar.gz)
ctime=$(date +%s)
dtime=$((ctime - ztime))
oneday=$((60 * 60 * 24))
if [ "$dtime" -lt "$oneday" ] || [[ "$*" =~ "force" ]]; then
    cp -f /mnt/webdav/certs/acme-data.tar.gz /tmp/acme-data.tar.gz
    trap "rm -f /tmp/acme-data.tar.gz" EXIT
    cd /etc
    tar --overwrite -zxf /tmp/acme-data.tar.gz
    # /etc/acme-data.d 中放一些更新证书后需要重启的服务
    if [ -d /etc/acme-data.d ]; then
        for i in /etc/acme-data.d/*.sh; do
            [ -x "$i" ] && "$i"
        done
    fi
fi

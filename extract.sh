#!/bin/bash
set -e
ztime=$(stat -c %Y /mnt/webdav/certs/letsencrypt.tar.gz)
ctime=$(date +%s)
dtime=$(expr $ctime - $ztime)
oneday=$(expr 60 '*' 60 '*' 24)
if (test "$dtime" -lt "$oneday" || [[ "$@" =~ "force" ]]); then
    cp -f /mnt/webdav/certs/letsencrypt.tar.gz /tmp/letsencrypt.tar.gz
    trap "{ rm -f /tmp/letsencrypt.tar.gz; }" EXIT
    cd /etc
    tar --overwrite -zxf /tmp/letsencrypt.tar.gz
    # /etc/letsencrypt.d 中放一些更新证书后需要重启的服务，
    if [ -d /etc/letsencrypt.d ]; then
        for i in /etc/letsencrypt.d/*.sh; do
            if [ -x $i ]; then
                $i
            fi
        done
        unset i
    fi
fi

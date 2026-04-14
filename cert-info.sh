#!/bin/bash
set -e
cert=${1:?用法: $0 <证书路径>}
openssl x509 -in "$cert" -noout \
    -subject -issuer -dates -serial \
    -ext subjectAltName

#!/usr/bin/env bash
set -Eeuo pipefail
# PKGS: https://pkgs.alpinelinux.org/packages
# 版本列表: https://dl-cdn.alpinelinux.org/alpine/

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

# 生成 alpine3.1--- 3.21的容器
for x in $(seq	1 21); \
do \

echo "building alpine 3.${x}"
./build.sh 3.${x}

done


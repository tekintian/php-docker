#!/usr/bin/env bash
set -Eeuo pipefail

# 生成 alpine3.12--- 3.21的容器
for x in $(seq	12 21); \
do \

echo "building alpine 3.${x}"
./build.sh 3.${x}

done


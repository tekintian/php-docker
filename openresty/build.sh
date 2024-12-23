#!/usr/bin/env bash
set -Eeuo pipefail

docker build -t tekintian/alpine-openresty:1.27.1.1 \
    -t tekintian/alpine-openresty:1.27 \
    -t tekintian/alpine-openresty \
    -t registry.cn-hangzhou.aliyuncs.com/alpine-docker/openresty \
    -t registry.cn-hangzhou.aliyuncs.com/alpine-docker/openresty:1.27 \
    -t registry.cn-hangzhou.aliyuncs.com/alpine-docker/openresty:1.27.1.1 \
    -f Dockerfile .


docker push tekintian/alpine-openresty:1.27.1.1
docker push tekintian/alpine-openresty:1.27
docker push tekintian/alpine-openresty
docker push registry.cn-hangzhou.aliyuncs.com/alpine-docker/openresty:1.27
docker push registry.cn-hangzhou.aliyuncs.com/alpine-docker/openresty:1.27.1.1


# 拷贝一份1panel的最新版本openresty到ali仓库
docker pull 1panel/openresty
docker tag 1panel/openresty registry.cn-hangzhou.aliyuncs.com/alpine-docker/openresty:1panel
docker push registry.cn-hangzhou.aliyuncs.com/alpine-docker/openresty:1panel

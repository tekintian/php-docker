#!/usr/bin/env bash
# @Author: Tekin Tian
# @Date:   2022-11-06 10:44:54
# @Last Modified by:   tekintian
# @Last Modified time: 2024-12-23 10:07:28
#
# https://github.com/tekintian/alpine
#
# Fail hard and fast
set -Eeuo pipefail

WORK_DIR=$(cd $(dirname $0); pwd)

# 接收版本参数
if [ "x$1" = 'x' ]; then
   ALPINE_VERSION="3.17"
else
  ALPINE_VERSION=$1
fi


# RELEASE_URL="https://github.com/tekintian/alpine/archive/refs/heads/master.tar.gz"

#构建时间 2022-11-28T19:54:36
BUILD_DATE=`date +%Y-%m-%dT%H:%M:%S`

# APK mirror
# mirrors.ustc.edu.cn
# mirrors.aliyun.com
# mirrors.tuna.tsinghua.edu.cn
# 官方默认的CDN
# dl-cdn.alpinelinux.org
APK_MIRROR="dl-cdn.alpinelinux.org"


# 镜像构建
docker build -f ${WORK_DIR}/Dockerfile \
    -t tekintian/alpine:${ALPINE_VERSION} \
    -t tekintian/alpine \
    -t registry.cn-hangzhou.aliyuncs.com/alpine-docker/alpine:${ALPINE_VERSION} \
    -t registry.cn-hangzhou.aliyuncs.com/alpine-docker/alpine \
    --build-arg ALPINE_VERSION="${ALPINE_VERSION}" \
    --build-arg BUILD_DATE="${BUILD_DATE}" \
    --build-arg APK_MIRROR="${APK_MIRROR}" \
    ${WORK_DIR}

docker push tekintian/alpine:${ALPINE_VERSION}
docker push tekintian/alpine
docker push registry.cn-hangzhou.aliyuncs.com/alpine-docker/alpine:${ALPINE_VERSION}
docker push registry.cn-hangzhou.aliyuncs.com/alpine-docker/alpine


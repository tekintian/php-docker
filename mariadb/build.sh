#!/usr/bin/env bash
set -Eeuo pipefail

WORK_DIR=$(cd $(dirname $0); pwd)

# 接收版本参数
if [ "x$1" = 'x' ]; then
   ALPINE_VERSION="3.17"
else
  ALPINE_VERSION=$1
fi

# 获取mariadb版本信息 ,如: 10.11.6-r0
MARIADB_VERSION=$(docker run --rm tekintian/alpine:${ALPINE_VERSION} sh -c "apk update && apk info mariadb"|grep "mariadb-"|awk 'NR==1{print $1}'|sed 's/mariadb-//g')

BUILD_TIME=`date +%Y%m%d`

docker build -t tekintian/alpine-mariadb:${MARIADB_VERSION} \
    -t registry.cn-hangzhou.aliyuncs.com/alpine-docker/mariadb:${MARIADB_VERSION} \
    --build-arg ALPINE_VERSION="${ALPINE_VERSION}" \
    --build-arg BUILD_DATE="${BUILD_DATE}" \
    --build-arg MARIADB_VERSION="${MARIADB_VERSION}" \
    -f Dockerfile .

# 推送到仓库
docker push tekintian/alpine-mariadb:${MARIADB_VERSION}
docker push registry.cn-hangzhou.aliyuncs.com/alpine-docker/mariadb:${MARIADB_VERSION}

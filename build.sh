#!/usr/bin/env bash
set -Eeuo pipefail

PHP_VERSION=8.4.2
ALPINE_VERSION=3.21

# cut -d '.' 按照.切割字符串, -f -2 显示前2段内容, 结果如: 8.4
MINOR_VERSION=$(echo ${PHP_VERSION}| cut -d '.' -f -2)

# 进入对应目录
cd ${MINOR_VERSION}/alpine${ALPINE_VERSION}/fpm

# 构建镜像
docker build -t tekintian/alpine-php:${PHP_VERSION} -t tekintian/alpine-php:${MINOR_VERSION} \
    -t registry.cn-hangzhou.aliyuncs.com/alpine-docker/php:${PHP_VERSION} \
    -t registry.cn-hangzhou.aliyuncs.com/alpine-docker/php:${MINOR_VERSION} \
    -f Dockerfile .

# 推送镜像
docker push tekintian/alpine-php:${PHP_VERSION}
docker push tekintian/alpine-php:${MINOR_VERSION}
docker push registry.cn-hangzhou.aliyuncs.com/alpine-docker/php:${PHP_VERSION}
docker push registry.cn-hangzhou.aliyuncs.com/alpine-docker/php:${MINOR_VERSION}

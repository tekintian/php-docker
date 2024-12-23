#!/usr/bin/env bash
# php镜像构建脚本
# 使用方法, 先执行 update.sh 更新PHP版本和dockerfile文件, 这个执行后会看到最新的版本信息,选择需要构建的版本
# 然后执行本脚本 , 如:  ./build.sh -v 8.4.2
#  -v php版本  
# -a ALPINE版本  当前支持 3.20  3.21 2个版本
# -s PHPSHA256签名字符串 登录 https://www.php.net/downloads.php 查看
# 
set -Eeuo pipefail

# build.sh -v PHP版本 -a ALPINE版本 -s 文件sha256
while getopts ":v:a:s:" opt
do
    case $opt in
        v)
            PHP_VERSION=$OPTARG;;
        a)
            ALPINE_VERSION=$OPTARG;;
        s)
            TAR_SHA256=$OPTARG;;
        ?)
        echo "Unknown parameter"
        exit 1;;
    esac
done

PHP_VERSION=${PHP_VERSION:-"8.4.2"}
ALPINE_VERSION=${ALPINE_VERSION:-"3.21"}
TAR_SHA256=${TAR_SHA256:-""}

# cut -d '.' 按照.切割字符串, -f -2 显示前2段内容, 结果如: 8.4
MINOR_VERSION=$(echo ${PHP_VERSION}| cut -d '.' -f -2)

# 进入对应目录
cd ${MINOR_VERSION}/alpine${ALPINE_VERSION}/fpm

# # 修改基础镜像
sed -i 's/FROM alpine:/FROM tekintian\/alpine:/g' Dockerfile

if [ ! -z ${TAR_SHA256} ];then
    sed -i 's/ENV PHP_SHA256=*$/ENV PHP_SHA256="'${TAR_SHA256}'"/g' Dockerfile
fi

if [ ! -z ${PHP_VERSION} ];then
    sed -i 's/^ENV PHP_VERSION .*/ENV PHP_VERSION '${PHP_VERSION}'/g' Dockerfile
    # shell正则匹配 [0-9.]* 表示匹配 0-9和.任意多次
    sed -i -e 's/distributions\/php-[0-9.]*/distributions\/php-'${PHP_VERSION}'./g' Dockerfile
fi

# 构建镜像
docker build -t tekintian/alpine-php:${PHP_VERSION} -t tekintian/alpine-php:${MINOR_VERSION} -t tekintian/alpine-php \
    -t registry.cn-hangzhou.aliyuncs.com/alpine-docker/php:${PHP_VERSION} \
    -t registry.cn-hangzhou.aliyuncs.com/alpine-docker/php:${MINOR_VERSION} \
    -t registry.cn-hangzhou.aliyuncs.com/alpine-docker/php \
    -f Dockerfile .

# 推送镜像
docker push tekintian/alpine-php
docker push tekintian/alpine-php:${PHP_VERSION}
docker push tekintian/alpine-php:${MINOR_VERSION}
docker push registry.cn-hangzhou.aliyuncs.com/alpine-docker/php
docker push registry.cn-hangzhou.aliyuncs.com/alpine-docker/php:${PHP_VERSION}
docker push registry.cn-hangzhou.aliyuncs.com/alpine-docker/php:${MINOR_VERSION}

#!/usr/bin/env bash
# @Author: Tekin Tian
# @Date:   2022-11-06 10:44:54
# @Last Modified by:   Tekin Tian
# @Last Modified time: 2023-03-15 08:53:45
# 
# nginx lua版本构建  build_lua.sh -v Nginx版本 -a ALPINE版本 -s 文件sha256
# 
# 如:  build_lua.sh -v 1.26.2 -a 3.16
# 
# https://nginx.org/en/download.html
# 
WORK_DIR=$(cd $(dirname $0); pwd)
cd ${WORK_DIR}

set -Eeuo pipefail

# build_lua.sh -v TENGINE版本 -a ALPINE版本 -s 文件sha256
while getopts ":v:a:s:" opt
do
    case $opt in
        v)
            TENGINE_VERSION=$OPTARG;;
        a)
            ALPINE_VERSION=$OPTARG;;
        ?)
        echo "Unknown parameter"
        exit 1;;
    esac
done

TENGINE_VERSION=${TENGINE_VERSION:-"3.1.0"}
ALPINE_VERSION=${ALPINE_VERSION:-"3.17"}

# 
# https://tengine.taobao.org/download/tengine-3.1.0.tar.gz
# 
RELEASE_URL="https://tengine.taobao.org/download/tengine-${TENGINE_VERSION}.tar.gz"

# nginx工作目录 官方默认  /var/www/html
# 
NGINX_WORK_DIR="/var/www/html"

# 替换版本号中的+为 -
VERSION=$(echo ${TENGINE_VERSION}|sed -e 's/+/-/g')

# 扩展TAG
TAG_EX="_${ALPINE_VERSION}"

# 最终build的TAG
TAG="${VERSION}${TAG_EX}"

# 获取中间版本号 如： 3.1
MS_VER=$(echo ${TENGINE_VERSION}|cut -d'.' -f -2)

# 构建时间 2024-12-23T23:43:03
BUILD_DATE=`date +%Y-%m-%dT%H:%M:%S`

docker build -f ${WORK_DIR}/tengine.Dockerfile -t tekintian/alpine-tengine:${TAG} \
      -t tekintian/alpine-tengine:${MS_VER}${TAG_EX} \
      -t registry.cn-hangzhou.aliyuncs.com/alpine-docker/tengine:${TAG} \
      -t registry.cn-hangzhou.aliyuncs.com/alpine-docker/tengine:${MS_VER}${TAG_EX} \
      --build-arg ALPINE_VERSION="${ALPINE_VERSION}" \
      --build-arg TENGINE_VERSION="${TENGINE_VERSION}" \
      --build-arg RELEASE_URL="${RELEASE_URL}" \
      --build-arg NGINX_WORK_DIR="${NGINX_WORK_DIR}" \
      --build-arg BUILD_DATE="${BUILD_DATE}" \
      ${WORK_DIR}

# # 运行容器并获取版本号，如果成功，则说明构建成功，否则构建失败
DNGINX_VER=$(docker run --rm tekintian/alpine-tengine:${TAG} nginx -version 2>&1 |cut -d'/' -f2| awk 'NR==1{print $1}')
# DNGINX_VER=$(docker run --rm tekintian/alpine-tengine:${TAG} nginx -version 2>&1 | grep "version " | cut -d'"' -f2)
# nginx -version 2>&1 |awk '/NGINX /{if (NR==1){print $2}}'
if [[ "$DNGINX_VER" =~ "${MS_VER}" ]];then

    echo "构建成功！TENGINE_VERSION: ${TAG} TAG: ${DNGINX_VER}${TAG_EX}"
    echo "docker run --rm -it tekintian/alpine-tengine:${DNGINX_VER}${TAG_EX} nginx -version"
    docker push tekintian/alpine-tengine:${TAG}
    docker push tekintian/alpine-tengine:${MS_VER}${TAG_EX}
    docker push registry.cn-hangzhou.aliyuncs.com/alpine-docker/tengine:${TAG}
    docker push registry.cn-hangzhou.aliyuncs.com/alpine-docker/tengine:${MS_VER}${TAG_EX}

else
  echo "获取tengine版本信息异常，构建失败！"
fi
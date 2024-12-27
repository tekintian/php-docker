#!/usr/bin/env bash
# Alpine Tengine-Ingress docker images maker
# https://tengine.taobao.org/download.html
# 
# ./build.sh -v Tengine-Ingress版本 -t TENGINE版本 -a Alpine版本
# 
# 如: ./build.sh -v 1.1.0 -t 3.1.0 -a 3.16
# 
WORK_DIR=$(cd $(dirname $0); pwd)
cd ${WORK_DIR}

set -Eeuo pipefail

# build.sh -v TENGINE版本 -a ALPINE版本
while getopts ":v:t:a:" opt
do
    case $opt in
        v)
            TENGINE_INGRESS_VERSION=$OPTARG;;
        t)
            TENGINE_VERSION=$OPTARG;;
        a)
            ALPINE_VERSION=$OPTARG;;
        ?)
        echo "Unknown parameter"
        exit 1;;
    esac
done


TENGINE_INGRESS_VERSION=${TENGINE_INGRESS_VERSION:-"1.1.0"}
TENGINE_VERSION=${TENGINE_VERSION:-"3.1.0"}
ALPINE_VERSION=${ALPINE_VERSION:-"3.16"}

# 替换版本号中的+为 -
VERSION=$(echo ${TENGINE_INGRESS_VERSION}|sed -e 's/+/-/g')

# 扩展TAG
TAG_EX="_${ALPINE_VERSION}"

# 最终build的TAG
TAG="${VERSION}${TAG_EX}"

# 获取中间版本号 如： 1.27
MS_VER=$(echo ${TENGINE_INGRESS_VERSION}|cut -d'.' -f -2)

# 构建时间 2024-12-23T23:43:03
BUILD_DATE=`date +%Y-%m-%dT%H:%M:%S`

if [ ! -f "tengine-ingress.tar.gz" ]; then
    # 下载 tengine-ingress.tar.gz 发行包
    wget -O tengine-ingress.tar.gz https://codeload.github.com/alibaba/tengine-ingress/tar.gz/refs/tags/Tengine-Ingress-v${TENGINE_INGRESS_VERSION}
fi

# 如果src目录不存在，则创建
if [! -d "src" ]; then
    mkdir src
fi
# 解压 tengine-ingress.tar.gz 发行包
tar -C src -zxvf tengine-ingress.tar.gz --strip-components=1
# 进入src目录
cd ${WORK_DIR}/src

# TENGINE镜像构建 这个镜像包含 modsecurity  luajit2等
docker build --no-cache \
    --build-arg BASE_IMAGE="tekintian/alpine:${ALPINE_VERSION}" \
    --build-arg LINUX_RELEASE="alpine" \
    -t tekintian/alpine-tengine:${TENGINE_VERSION} \
    -t registry.cn-hangzhou.aliyuncs.com/alpine-docker/tengine:${TENGINE_VERSION}-ts \
    images/tengine/rootfs/

# 以tengine镜像为基础, 构建 tengine-ingress镜像
docker build --no-cache \
    --build-arg BASE_IMAGE="tekintian/alpine-tengine:${TENGINE_VERSION}" \
    --build-arg VERSION="${TENGINE_INGRESS_VERSION}" \
    -t tekintian/tengine-ingress:${TENGINE_INGRESS_VERSION} \
    -t registry.cn-hangzhou.aliyuncs.com/alpine-docker/tengine:${TENGINE_INGRESS_VERSION}-ingress \
    -f build/Dockerfile  .

# 推送镜像
docker push tekintian/alpine-tengine:${TENGINE_VERSION}
docker push tekintian/tengine-ingress:${TENGINE_INGRESS_VERSION}
docker push registry.cn-hangzhou.aliyuncs.com/alpine-docker/tengine:${TENGINE_INGRESS_VERSION}-ingress
docker push registry.cn-hangzhou.aliyuncs.com/alpine-docker/tengine:${TENGINE_VERSION}-ts

# 构建完成 返回工作目录
cd ${WORK_DIR}

# 清理文件
rm -rf tengine-ingress.tar.gz
rm -rf src

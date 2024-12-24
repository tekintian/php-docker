#!/usr/bin/env bash
# @Author: Tekin Tian
# @Date:   2022-11-06 10:44:54
# @Last Modified by:   Tekin Tian
# @Last Modified time: 2022-12-13 15:31:36
# 
# nginx镜像构建  build.sh -v Nginx版本 -a ALPINE版本 -s 文件sha256
# 
# 如:  build.sh -v 1.26.2 -a 3.16
# 
# https://nginx.org/en/download.html
# 
WORK_DIR=$(cd $(dirname $0); pwd)
cd ${WORK_DIR}

# build.sh -v Nginx版本 -a ALPINE版本 -s 文件sha256
while getopts ":v:a:s:" opt
do
    case $opt in
        v)
            NGINX_VERSION=$OPTARG;;
        a)
            ALPINE_VERSION=$OPTARG;;
        s)
            TAR_SHA256=$OPTARG;;
        ?)
        echo "Unknown parameter"
        exit 1;;
    esac
done

NGINX_VERSION=${NGINX_VERSION:-"1.26.2"}
ALPINE_VERSION=${ALPINE_VERSION:-"3.16"}


#定义函数check_http：
#使用curl命令检查http服务器的状态
#-m设置curl不管访问成功或失败，最大消耗的时间为5秒，5秒连接服务为相应则视为无法连接
#-s设置静默连接，不显示连接时的连接速度、时间消耗等信息
#-o将curl下载的页面内容导出到/dev/null(默认会在屏幕显示页面内容)
#-w设置curl命令需要显示的内容%{http_code}，指定curl返回服务器的状态码
check_http(){
  status_code=$(curl -m 5 -so /dev/null -w %{http_code} $1)
}

# 
# nginx下载地址: http://nginx.org/download/nginx-1.26.2.tar.gz
# 
RELEASE_URL="http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz"

# 
# nginx工作目录 官方默认  /var/www/html
# 
NGINX_WORK_DIR="/var/www/html"

# 替换版本号中的+为 -
VERSION=$(echo ${NGINX_VERSION}|sed -e 's/+/-/g')

# 扩展TAG
TAG_EX="_${ALPINE_VERSION}"

# 最终build的TAG
TAG="${VERSION}${TAG_EX}"

# 获取中间版本号 如： 1.26
MS_VER=$(echo ${NGINX_VERSION}|cut -d'.' -f -2)

BUILD_DATE=`date +%Y-%m-%dT%H:%M:%S`

docker rmi -f tekintian/alpine-nginx:${TAG}

# JAVA_TAR_SC  这个是压缩包对应的 strip-component 即去除的目录层级
docker build -f ${WORK_DIR}/Dockerfile -t tekintian/alpine-nginx:${TAG} \
      -t registry.cn-hangzhou.aliyuncs.com/alpine-docker/nginx:${TAG} \
      --build-arg ALPINE_VERSION="${ALPINE_VERSION}" \
      --build-arg NGINX_VERSION="${NGINX_VERSION}" \
      --build-arg RELEASE_URL="${RELEASE_URL}" \
      --build-arg TAR_SHA256="${TAR_SHA256}" \
      --build-arg NGINX_WORK_DIR="${NGINX_WORK_DIR}" \
      --build-arg BUILD_DATE="${BUILD_DATE}" \
      ${WORK_DIR}

# 运行容器并获取版本号，如果成功，则说明构建成功，否则构建失败
DNGINX_VER=$(docker run --rm tekintian/alpine-nginx:${TAG} nginx -version 2>&1 |cut -d'/' -f2)
# nginx -version 2>&1 |awk '/NGINX /{if (NR==1){print $2}}'
# DNGINX_VER=$(docker run --rm tekintian/alpine-nginx:${TAG} nginx -version 2>&1 | grep "version " | cut -d'"' -f2)
# nginx -version 2>&1 |awk '/NGINX /{if (NR==1){print $2}}'
if [ "$DNGINX_VER" ];then
    docker tag tekintian/alpine-nginx:${TAG} tekintian/alpine-nginx:${DNGINX_VER}${TAG_EX}
    docker tag tekintian/alpine-nginx:${TAG} tekintian/alpine-nginx:${MS_VER}${TAG_EX}
    docker tag tekintian/alpine-nginx:${TAG} tekintian/alpine-nginx:${MS_VER}
    docker tag tekintian/alpine-nginx:${TAG} registry.cn-hangzhou.aliyuncs.com/alpine-docker/nginx:${MS_VER}${TAG_EX}
    docker tag tekintian/alpine-nginx:${TAG} registry.cn-hangzhou.aliyuncs.com/alpine-docker/nginx:${MS_VER}

    echo "构建成功！NGINX_VERSION: ${TAG} TAG: ${DNGINX_VER}${TAG_EX}"
    echo "docker run --rm -it tekintian/alpine-nginx:${DNGINX_VER}${TAG_EX} nginx -version"

    docker push tekintian/alpine-nginx:${DNGINX_VER}${TAG_EX}
    docker push tekintian/alpine-nginx:${MS_VER}${TAG_EX}
    docker push tekintian/alpine-nginx:${MS_VER}
    docker push tekintian/alpine-nginx:${TAG}

    docker push registry.cn-hangzhou.aliyuncs.com/alpine-docker/nginx:${TAG}
    docker push registry.cn-hangzhou.aliyuncs.com/alpine-docker/nginx:${MS_VER}
    docker push registry.cn-hangzhou.aliyuncs.com/alpine-docker/nginx:${MS_VER}${TAG_EX}

else
  echo "获取nginx版本信息异常，构建失败！"
fi
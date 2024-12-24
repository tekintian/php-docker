#!/usr/bin/env bash
# Alpine Openresty docker images maker
# https://github.com/openresty/openresty/releases
# ./build.sh -v RESTY版本号 -a Alpine版本
# 如: ./build.sh -v 1.25.3.2 -a 3.20
# 
WORK_DIR=$(cd $(dirname $0); pwd)
cd ${WORK_DIR}

set -Eeuo pipefail

# build.sh -v TENGINE版本 -a ALPINE版本
while getopts ":v:a:" opt
do
    case $opt in
        v)
            RESTY_VERSION=$OPTARG;;
        a)
            ALPINE_VERSION=$OPTARG;;
        ?)
        echo "Unknown parameter"
        exit 1;;
    esac
done

RESTY_VERSION=${RESTY_VERSION:-"1.25.3.2"}
ALPINE_VERSION=${ALPINE_VERSION:-"3.16"}

# 替换版本号中的+为 -
VERSION=$(echo ${RESTY_VERSION}|sed -e 's/+/-/g')

# 扩展TAG
TAG_EX="_${ALPINE_VERSION}"

# 最终build的TAG
TAG="${VERSION}${TAG_EX}"

# 获取中间版本号 如： 1.27
MS_VER=$(echo ${RESTY_VERSION}|cut -d'.' -f -2)

# 构建时间 2024-12-23T23:43:03
BUILD_DATE=`date +%Y-%m-%dT%H:%M:%S`

RESTY_OPENSSL_VERSION="3.0.15"
RESTY_OPENSSL_PATCH_VERSION="3.0.15"
RESTY_OPENSSL_URL_BASE="https://github.com/openssl/openssl/releases/download/openssl-${RESTY_OPENSSL_VERSION}"
RESTY_OPENSSL_BUILD_OPTIONS="enable-camellia enable-seed enable-rfc3779 enable-cms enable-md2 enable-rc5 \
        enable-weak-ssl-ciphers enable-ssl3 enable-ssl3-method enable-md2 enable-ktls enable-fips \
        "
RESTY_PCRE_VERSION="10.44"
RESTY_PCRE_SHA256="86b9cb0aa3bcb7994faa88018292bc704cdbb708e785f7c74352ff6ea7d3175b"
RESTY_PCRE_BUILD_OPTIONS="--enable-jit --enable-pcre2grep-jit --disable-bsr-anycrlf --disable-coverage --disable-ebcdic --disable-fuzz-support \
    --disable-jit-sealloc --disable-never-backslash-C --enable-newline-is-lf --enable-pcre2-8 --enable-pcre2-16 --enable-pcre2-32 \
    --enable-pcre2grep-callout --enable-pcre2grep-callout-fork --disable-pcre2grep-libbz2 --disable-pcre2grep-libz --disable-pcre2test-libedit \
    --enable-percent-zt --disable-rebuild-chartables --enable-shared --disable-static --disable-silent-rules --enable-unicode --disable-valgrind \
    "

RESTY_CONFIG_OPTIONS="\
    --with-compat \
    --without-http_rds_json_module \
    --without-http_rds_csv_module \
    --without-lua_rds_parser \
    --without-mail_pop3_module \
    --without-mail_imap_module \
    --without-mail_smtp_module \
    --with-http_addition_module \
    --with-http_auth_request_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_geoip_module=dynamic \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_image_filter_module=dynamic \
    --with-http_mp4_module \
    --with-http_random_index_module \
    --with-http_realip_module \
    --with-http_secure_link_module \
    --with-http_slice_module \
    --with-http_ssl_module \
    --with-http_stub_status_module \
    --with-http_sub_module \
    --with-http_v2_module \
    --with-http_xslt_module=dynamic \
    --with-ipv6 \
    --with-mail \
    --with-mail_ssl_module \
    --with-md5-asm \
    --with-sha1-asm \
    --with-stream \
    --with-stream_ssl_module \
    --with-stream_ssl_preread_module \
    --with-threads \
    "

# 构建依赖包
RESTY_ADD_PACKAGE_BUILDDEPS=" pcre-dev "
# 运行依赖包
RESTY_ADD_PACKAGE_RUNDEPS=" pcre "

docker build -t tekintian/alpine-openresty:${TAG} \
    -t tekintian/alpine-openresty:${MS_VER} \
    -t tekintian/alpine-openresty:${VERSION} \
    -t tekintian/alpine-openresty \
    -t registry.cn-hangzhou.aliyuncs.com/alpine-docker/openresty \
    -t registry.cn-hangzhou.aliyuncs.com/alpine-docker/openresty:${VERSION} \
    -t registry.cn-hangzhou.aliyuncs.com/alpine-docker/openresty:${MS_VER} \
    -t registry.cn-hangzhou.aliyuncs.com/alpine-docker/openresty:${TAG} \
    --build-arg ALPINE_VERSION="${ALPINE_VERSION}" \
    --build-arg RESTY_VERSION="${RESTY_VERSION}" \
    --build-arg RESTY_OPENSSL_VERSION="${RESTY_OPENSSL_VERSION}" \
    --build-arg RESTY_OPENSSL_PATCH_VERSION="${RESTY_OPENSSL_PATCH_VERSION}" \
    --build-arg RESTY_OPENSSL_URL_BASE="${RESTY_OPENSSL_URL_BASE}" \
    --build-arg RESTY_OPENSSL_BUILD_OPTIONS="${RESTY_OPENSSL_BUILD_OPTIONS}" \
    --build-arg RESTY_PCRE_VERSION="${RESTY_PCRE_VERSION}" \
    --build-arg RESTY_PCRE_SHA256="${RESTY_PCRE_SHA256}" \
    --build-arg RESTY_PCRE_BUILD_OPTIONS="${RESTY_PCRE_BUILD_OPTIONS}" \
    --build-arg RESTY_CONFIG_OPTIONS="${RESTY_CONFIG_OPTIONS}" \
    --build-arg RESTY_ADD_PACKAGE_BUILDDEPS="${RESTY_ADD_PACKAGE_BUILDDEPS}" \
    --build-arg RESTY_ADD_PACKAGE_RUNDEPS="${RESTY_ADD_PACKAGE_RUNDEPS}" \
    --build-arg BUILD_DATE="${BUILD_DATE}" \
    -f Dockerfile  ${WORK_DIR}


docker push tekintian/alpine-openresty
docker push tekintian/alpine-openresty:${TAG}
docker push tekintian/alpine-openresty:${MS_VER}
docker push tekintian/alpine-openresty:${VERSION}

docker push registry.cn-hangzhou.aliyuncs.com/alpine-docker/openresty
docker push registry.cn-hangzhou.aliyuncs.com/alpine-docker/openresty:${TAG}
docker push registry.cn-hangzhou.aliyuncs.com/alpine-docker/openresty:${MS_VER}
docker push registry.cn-hangzhou.aliyuncs.com/alpine-docker/openresty:${VERSION}

# 拷贝一份1panel的最新版本openresty到ali仓库
# docker pull 1panel/openresty
# docker tag 1panel/openresty registry.cn-hangzhou.aliyuncs.com/alpine-docker/openresty:1panel
# docker push registry.cn-hangzhou.aliyuncs.com/alpine-docker/openresty:1panel

# Dockerfile - alpine
# https://github.com/openresty/docker-openresty

ARG ALPINE_VERSION="3.20"
FROM tekintian/alpine:${ALPINE_VERSION}

# Docker Build Arguments
ARG ALPINE_VERSION="3.20"  \
    RESTY_VERSION="1.27.1.1" \
    RESTY_OPENSSL_VERSION="3.0.15" \
    RESTY_OPENSSL_PATCH_VERSION="3.0.15" \
    RESTY_OPENSSL_URL_BASE="https://github.com/openssl/openssl/releases/download/openssl-${RESTY_OPENSSL_VERSION}" \
    # LEGACY:  "https://www.openssl.org/source/old/1.1.1"
    RESTY_OPENSSL_BUILD_OPTIONS="enable-camellia enable-seed enable-rfc3779 enable-cms enable-md2 enable-rc5 \
        enable-weak-ssl-ciphers enable-ssl3 enable-ssl3-method enable-md2 enable-ktls enable-fips \
        " \
# https://github.com/openresty/openresty-packaging/blob/master/alpine/openresty-pcre2/APKBUILD
    RESTY_PCRE_VERSION="10.44" \
    RESTY_PCRE_SHA256="86b9cb0aa3bcb7994faa88018292bc704cdbb708e785f7c74352ff6ea7d3175b" \
    RESTY_PCRE_BUILD_OPTIONS="--enable-jit --enable-pcre2grep-jit --disable-bsr-anycrlf --disable-coverage --disable-ebcdic --disable-fuzz-support \
    --disable-jit-sealloc --disable-never-backslash-C --enable-newline-is-lf --enable-pcre2-8 --enable-pcre2-16 --enable-pcre2-32 \
    --enable-pcre2grep-callout --enable-pcre2grep-callout-fork --disable-pcre2grep-libbz2 --disable-pcre2grep-libz --disable-pcre2test-libedit \
    --enable-percent-zt --disable-rebuild-chartables --enable-shared --disable-static --disable-silent-rules --enable-unicode --disable-valgrind \
    " \
    RESTY_J="1" \
# https://github.com/openresty/openresty-packaging/blob/master/alpine/openresty/APKBUILD
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
    --with-http_v3_module \
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
    " \
    RESTY_CONFIG_OPTIONS_MORE="" \
    RESTY_LUAJIT_OPTIONS="--with-luajit-xcflags='-DLUAJIT_NUMMODE=2 -DLUAJIT_ENABLE_LUA52COMPAT'" \
    RESTY_PCRE_OPTIONS="--with-pcre-jit" \
    RESTY_ADD_PACKAGE_BUILDDEPS="" \
    RESTY_ADD_PACKAGE_RUNDEPS="" \
    RESTY_EVAL_PRE_CONFIGURE="" \
    RESTY_EVAL_POST_DOWNLOAD_PRE_CONFIGURE="" \
    RESTY_EVAL_POST_MAKE="" \
    # These are not intended to be user-specified
    _RESTY_CONFIG_DEPS="--with-pcre \
    --with-cc-opt='-DNGX_LUA_ABORT_AT_PANIC -I/usr/local/openresty/pcre2/include -I/usr/local/openresty/openssl3/include' \
    --with-ld-opt='-L/usr/local/openresty/pcre2/lib -L/usr/local/openresty/openssl3/lib -Wl,-rpath,/usr/local/openresty/pcre2/lib:/usr/local/openresty/openssl3/lib' \
    "

LABEL maintainer="tekintian <tekintian@gmail.com>" \
    resty_image_base="tekintian/alpine" \
    resty_image_tag="${ALPINE_VERSION}" \
    resty_version="${RESTY_VERSION}" \
    resty_openssl_version="${RESTY_OPENSSL_VERSION}" \
    resty_openssl_patch_version="${RESTY_OPENSSL_PATCH_VERSION}" \
    resty_openssl_url_base="${RESTY_OPENSSL_URL_BASE}" \
    resty_openssl_build_options="${RESTY_OPENSSL_BUILD_OPTIONS}" \
    resty_pcre_version="${RESTY_PCRE_VERSION}" \
    resty_pcre_build_options="${RESTY_PCRE_BUILD_OPTIONS}" \
    resty_pcre_sha256="${RESTY_PCRE_SHA256}" \
    resty_config_options="${RESTY_CONFIG_OPTIONS}" \
    resty_config_options_more="${RESTY_CONFIG_OPTIONS_MORE}" \
    resty_config_deps="${_RESTY_CONFIG_DEPS}" \
    resty_add_package_builddeps="${RESTY_ADD_PACKAGE_BUILDDEPS}" \
    resty_add_package_rundeps="${RESTY_ADD_PACKAGE_RUNDEPS}" \
    resty_eval_pre_configure="${RESTY_EVAL_PRE_CONFIGURE}" \
    resty_eval_post_download_pre_configure="${RESTY_EVAL_POST_DOWNLOAD_PRE_CONFIGURE}" \
    resty_eval_post_make="${RESTY_EVAL_POST_MAKE}" \
    resty_luajit_options="${RESTY_LUAJIT_OPTIONS}" \
    resty_pcre_options="${RESTY_PCRE_OPTIONS}"

RUN apk add --no-cache --virtual .build-deps \
        build-base \
        coreutils \
        curl \
        git \
        gd-dev \
        geoip-dev \
        libxslt-dev \
        linux-headers \
        make \
        perl-dev \
        readline-dev \
        zlib-dev \
        ${RESTY_ADD_PACKAGE_BUILDDEPS} \
    && apk add --no-cache \
        gd \
        geoip \
        libgcc \
        libxslt \
        tzdata \
        zlib \
        ${RESTY_ADD_PACKAGE_RUNDEPS} \
    && cd /tmp \
    && if [ -n "${RESTY_EVAL_PRE_CONFIGURE}" ]; then eval $(echo ${RESTY_EVAL_PRE_CONFIGURE}); fi \
    && cd /tmp \
    && curl -fSL "${RESTY_OPENSSL_URL_BASE}/openssl-${RESTY_OPENSSL_VERSION}.tar.gz" -o openssl-${RESTY_OPENSSL_VERSION}.tar.gz \
    && tar xzf openssl-${RESTY_OPENSSL_VERSION}.tar.gz \
    && cd openssl-${RESTY_OPENSSL_VERSION} \
    && if [ $(echo ${RESTY_OPENSSL_VERSION} | cut -c 1-5) = "3.0.15" ] ; then \
        echo 'patching OpenSSL 3.0.15 for OpenResty' \
        && curl -s https://raw.githubusercontent.com/openresty/openresty/master/patches/openssl-${RESTY_OPENSSL_PATCH_VERSION}-sess_set_get_cb_yield.patch | patch -p1 ; \
    fi \
    && if [ $(echo ${RESTY_OPENSSL_VERSION} | cut -c 1-5) = "1.1.1" ] ; then \
        echo 'patching OpenSSL 1.1.1 for OpenResty' \
        && curl -s https://raw.githubusercontent.com/openresty/openresty/master/patches/openssl-${RESTY_OPENSSL_PATCH_VERSION}-sess_set_get_cb_yield.patch | patch -p1 ; \
    fi \
    && if [ $(echo ${RESTY_OPENSSL_VERSION} | cut -c 1-5) = "1.1.0" ] ; then \
        echo 'patching OpenSSL 1.1.0 for OpenResty' \
        && curl -s https://raw.githubusercontent.com/openresty/openresty/ed328977028c3ec3033bc25873ee360056e247cd/patches/openssl-1.1.0j-parallel_build_fix.patch | patch -p1 \
        && curl -s https://raw.githubusercontent.com/openresty/openresty/master/patches/openssl-${RESTY_OPENSSL_PATCH_VERSION}-sess_set_get_cb_yield.patch | patch -p1 ; \
    fi \
    && ./config \
      shared zlib -g \
      --prefix=/usr/local/openresty/openssl3 \
      --libdir=lib \
      -Wl,-rpath,/usr/local/openresty/openssl3/lib \
      ${RESTY_OPENSSL_BUILD_OPTIONS} \
    && make -j${RESTY_J} \
    && make -j${RESTY_J} install_sw \
    && cd /tmp \
    && curl -fSL "https://github.com/PCRE2Project/pcre2/releases/download/pcre2-${RESTY_PCRE_VERSION}/pcre2-${RESTY_PCRE_VERSION}.tar.gz" -o pcre2-${RESTY_PCRE_VERSION}.tar.gz \
    && echo "${RESTY_PCRE_SHA256}  pcre2-${RESTY_PCRE_VERSION}.tar.gz" | shasum -a 256 --check \
    && tar xzf pcre2-${RESTY_PCRE_VERSION}.tar.gz \
    && cd /tmp/pcre2-${RESTY_PCRE_VERSION} \
    && CFLAGS="-g -O3" ./configure \
        --prefix=/usr/local/openresty/pcre2 \
        --libdir=/usr/local/openresty/pcre2/lib \
        ${RESTY_PCRE_BUILD_OPTIONS} \
    && CFLAGS="-g -O3" make -j${RESTY_J} \
    && CFLAGS="-g -O3" make -j${RESTY_J} install \
    && cd /tmp \
    && curl -fSL https://openresty.org/download/openresty-${RESTY_VERSION}.tar.gz -o openresty-${RESTY_VERSION}.tar.gz \
    && tar xzf openresty-${RESTY_VERSION}.tar.gz \
    && cd /tmp/openresty-${RESTY_VERSION} \
    && if [ -n "${RESTY_EVAL_POST_DOWNLOAD_PRE_CONFIGURE}" ]; then eval $(echo ${RESTY_EVAL_POST_DOWNLOAD_PRE_CONFIGURE}); fi \
    && eval ./configure -j${RESTY_J} ${_RESTY_CONFIG_DEPS} ${RESTY_CONFIG_OPTIONS} ${RESTY_CONFIG_OPTIONS_MORE} ${RESTY_LUAJIT_OPTIONS} ${RESTY_PCRE_OPTIONS} \
    && make -j${RESTY_J} \
    && make -j${RESTY_J} install \
    && cd /tmp \
    && if [ -n "${RESTY_EVAL_POST_MAKE}" ]; then eval $(echo ${RESTY_EVAL_POST_MAKE}); fi \
    && rm -rf \
        openssl-${RESTY_OPENSSL_VERSION}.tar.gz openssl-${RESTY_OPENSSL_VERSION} \
        pcre2-${RESTY_PCRE_VERSION}.tar.gz pcre2-${RESTY_PCRE_VERSION} \
        openresty-${RESTY_VERSION}.tar.gz openresty-${RESTY_VERSION} \
    && if [ -f /usr/local/openresty/nginx/conf/nginx.conf ]; then mv /usr/local/openresty/nginx/conf/nginx.conf /usr/local/openresty/nginx/conf/nginx.conf.bk; fi \
    && if [ -f /etc/nginx/conf.d/default.conf ]; then mv /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf.bk; fi \
    && if [ ! -d /etc/nginx/conf.d ]; then mkdir -p /etc/nginx/conf.d; fi  \
    && if [ ! -d /usr/local/openresty/nginx/conf ]; then mkdir -p /usr/local/openresty/nginx/conf; fi  \
    && curl -fSL https://raw.github.com/tekintian/docker-openresty/refs/heads/master/nginx.conf -o /usr/local/openresty/nginx/conf/nginx.conf \
    && curl -fSL https://raw.github.com/tekintian/docker-openresty/refs/heads/master/nginx.vh.default.conf -o /etc/nginx/conf.d/default.conf \
    && sed -i '/<section class="social/,/<\/body>/d' /usr/local/openresty/nginx/html/index.html \
    && sed -i 's/openresty.com/dev.tekin.cn/g' /usr/local/openresty/nginx/html/index.html \
    && sed -i '/.products/d' /usr/local/openresty/nginx/html/index.html \
    && sed -i '/.social/d' /usr/local/openresty/nginx/html/index.html \
    && sed -i '/.blogs/d' /usr/local/openresty/nginx/html/index.html \
    && sed -i '/<\/html>/i\<\/body>' /usr/local/openresty/nginx/html/index.html \
    && apk del .build-deps \
    && mkdir -p /var/run/openresty \
    && ln -sf /dev/stdout /usr/local/openresty/nginx/logs/access.log \
    && ln -sf /dev/stderr /usr/local/openresty/nginx/logs/error.log

# Add additional binaries into PATH for convenience
ENV PATH=$PATH:/usr/local/openresty/luajit/bin:/usr/local/openresty/nginx/sbin:/usr/local/openresty/bin

# Copy nginx configuration files
# COPY nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
# COPY nginx.vh.default.conf /etc/nginx/conf.d/default.conf

CMD ["/usr/local/openresty/bin/openresty", "-g", "daemon off;"]

# Use SIGQUIT instead of default SIGTERM to cleanly drain requests
# See https://github.com/openresty/docker-openresty/blob/master/README.md#tips--pitfalls
STOPSIGNAL SIGQUIT
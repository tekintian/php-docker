# http://nginx.org/
ARG ALPINE_VERSION=3.15
FROM tekintian/alpine:${ALPINE_VERSION}

ARG NGINX_VERSION \
    RELEASE_URL \
    ALPINE_VERSION \
    BUILD_DATE \
    NGINX_WORK_DIR \
    NGINX_LOG_DIR \
    NGINX_TEMP_PATH

LABEL maintainer="TekinTian <tekintian@gmail.com>" \
      name="alpine-nginx" \
      version="${NGINX_VERSION}" \
      description="Nginx ${NGINX_VERSION} fpm with Alpine ${ALPINE_VERSION} Linux Docker Container" \
      url="http://dev.tekin.cn" \
      build.date="${BUILD_DATE}"

ENV NGINX_VERSION=${NGINX_VERSION:-"1.26.2"} \
	# https://github.com/ADD-SP/ngx_waf/archive/refs/tags/v10.1.2.tar.gz
	# NGX_WAF_VERSION=10.1.2 \
	# https://luajit.org/download.html 官方已经好几年没有更新了，换成 openresty的版本
	# https://github.com/openresty/luajit2/tags
	LUAJIT2_VERSION="2.1-20241113" \
	# https://github.com/simplresty/ngx_devel_kit
	NDK_VERSION="0.3.3" \
	# https://github.com/openresty/lua-nginx-module/releases
	LUA_NGINX_MODULE_VERSION="0.10.27" \
	# https://github.com/openresty/lua-cjson/releases
	LUA_CJSON_VERSION="2.1.0.9" \
	# https://github.com/ledgetech/lua-resty-http/releases
	LUA_RESTY_HTTP_VERSION="0.17.2" \
	# https://github.com/openresty/lua-resty-core/tags
	LUA_RESTY_CORE_VERSION="0.1.30" \
	# https://github.com/openresty/set-misc-nginx-module/tags
	SET_MISC_NGINX_MODULE_VERSION="0.33" \
	# https://github.com/openresty/encrypted-session-nginx-module/tags
	ENCRYPTED_SESSION_NGINX_MODULE_VERSION="0.09" \
	# https://github.com/openresty/echo-nginx-module/tags
	ECHO_NGINX_MODULE_VERSION="0.63" \
	# https://github.com/cloudflare/lua-resty-cookie/tags
	LUA_RESTY_COOKIE_VERSION="0.1.0" \
	# https://github.com/openresty/lua-resty-lrucache/tags
	LUA_RESTY_LRUCACHE_VERSION="0.15" \
	# https://github.com/openresty/lua-resty-redis/tags
	LUA_RESTY_REDIS_VERSION="0.31" \
	# https://github.com/openresty/lua-resty-mysql/tags
	LUA_RESTY_MYSQL_VERSION="0.27" \
	# https://github.com/cloudflare/lua-resty-logger-socket/tags
	LUA_RESTY_LOGGER_SOCKET_VERSION="0.1" \
	# https://github.com/openresty/lua-resty-string/tags
	LUA_RESTY_STRING_VERSION="0.16" \
	\
	# https://github.com/tekintian/lua-resty-core/
	# COPY assets/lua-rest-core/Makefile /tmp/lrc_Makefile
	# COPY src/lua-cjson-2.1.0.7 /tmp/lua-cjson-2.1.0.7 
	# 使用环境配置，默认 Y 开启, 使用环境变量替换nginx.conf中的相关配置项目 如果自己加载配置文件，则把这个设置为 N
    USE_ENV_CONF=${USE_ENV_CONF:-"Y"} \
    NGINX_WORK_DIR=${NGINX_WORK_DIR:-"/var/www/html"} \
    NGINX_SERVER_ROOT=${NGINX_SERVER_ROOT:-"/var/www/html"} \
	NGINX_LOG_DIR=${NGINX_LOG_DIR:-"/var/log/nginx"} \
	NGINX_TEMP_PATH=${NGINX_TEMP_PATH:-"/var/cache/nginx"} \
	NGINX_ROOT_DIR=${NGINX_ROOT_DIR:-"/etc/nginx"} \
	NGINX_CONF_DIR=${NGINX_CONF_DIR:-"/etc/nginx/conf.d"}

# COPY lua-entrypoint /usr/local/bin/docker-entrypoint
RUN set -eux \
	&& mver=$(echo $ALPINE_VERSION | cut -d'.' -f2); \
	# 如果版本小于3.15 则执行 整数比较 使用 -lt 小于； -eq 等于； -gt 大于；-le 小于等于
	if [[ $mver -lt 15 ]]; then \
	  addgroup -g 82 -S www-data;\
	fi; \
	adduser -u 82 -D -S -h ${NGINX_TEMP_PATH} -s /sbin/nologin -G www-data www-data \
	\
	&& for path in \
	  ${NGINX_WORK_DIR} \
	  ${NGINX_LOG_DIR} \
	  /var/www \
	  /var/log \
	  /var/cache \
	  /opt \
	; do \
		# 判断目录是否存在，如果不存在，创建，如果存在，设置拥有者为指定用户
		if [ ! -d ${path} ]; then \
			mkdir -p ${path}; \
		fi; \
		chown -R www-data:www-data ${path}; \
		#如果目录中包含log,则设置目录权限为777，否则设置为755
		if [[ ${path} == *log* ]];then \
			chmod 0777 ${path}; \
		else \
			chmod 0755 ${path}; \
		fi;\
	done \
	\
	&& apk add --no-cache tini libgcc \
	&& apk add --no-cache --virtual .build-deps \
		gcc \
		libc-dev \
		make \
		openssl-dev \
		pcre-dev \
		zlib-dev \
		linux-headers \
		curl \
		gnupg \
		libxslt-dev \
		gd-dev \
		geoip-dev \
		wget \
		unzip \
	&& cd /tmp/ \
	\
	# download entrypoint and set exec perms
	&& wget -O /usr/local/bin/docker-entrypoint https://raw.githubusercontent.com/tekintian/php-docker/refs/heads/master/nginx/lua-entrypoint \
	&& chmod +x /usr/local/bin/docker-entrypoint \
	# nginx install
	&& wget -O nginx.tar.gz ${RELEASE_URL} --no-check-certificate \
	\
	#related module donwload
	# && wget -O ngx_waf.tar.gz  https://github.com/ADD-SP/ngx_waf/archive/refs/tags/v${NGX_WAF_VERSION}.tar.gz \
	&& wget -O ngx_devel_kit.tar.gz  https://github.com/vision5/ngx_devel_kit/archive/refs/tags/v${NDK_VERSION}.tar.gz \
	&& wget -O lua-resty-http.tar.gz  https://github.com/ledgetech/lua-resty-http/archive/refs/tags/v${LUA_RESTY_HTTP_VERSION}.tar.gz \
	&& wget -O lua-resty-cookie.tar.gz   https://github.com/cloudflare/lua-resty-cookie/archive/refs/tags/v${LUA_RESTY_COOKIE_VERSION}.tar.gz  \
	&& wget -O lua-resty-logger-socket.tar.gz  https://github.com/cloudflare/lua-resty-logger-socket/archive/refs/tags/v${LUA_RESTY_LOGGER_SOCKET_VERSION}.tar.gz\
	\
	# openresty module download
	&& wget -O luajit2.tar.gz https://github.com/openresty/luajit2/archive/refs/tags/v${LUAJIT2_VERSION}.tar.gz \
	&& wget -O lua-cjson.tar.gz  https://github.com/openresty/lua-cjson/archive/refs/tags/${LUA_CJSON_VERSION}.tar.gz \
	&& wget -O lua-nginx-module.tar.gz  https://github.com/openresty/lua-nginx-module/archive/refs/tags/v${LUA_NGINX_MODULE_VERSION}.tar.gz \
	&& wget -O lua-resty-core.tar.gz  https://github.com/openresty/lua-resty-core/archive/refs/tags/v${LUA_RESTY_CORE_VERSION}.tar.gz \
	&& wget -O set-misc-nginx-module.tar.gz  https://github.com/openresty/set-misc-nginx-module/archive/refs/tags/v${SET_MISC_NGINX_MODULE_VERSION}.tar.gz \
	&& wget -O encrypted-session-nginx-module.tar.gz  https://github.com/openresty/encrypted-session-nginx-module/archive/refs/tags/v${ENCRYPTED_SESSION_NGINX_MODULE_VERSION}.tar.gz \
	&& wget -O echo-nginx-module.tar.gz   https://github.com/openresty/echo-nginx-module/archive/refs/tags/v${ECHO_NGINX_MODULE_VERSION}.tar.gz \
	&& wget -O lua-resty-lrucache.tar.gz  https://github.com/openresty/lua-resty-lrucache/archive/refs/tags/v${LUA_RESTY_LRUCACHE_VERSION}.tar.gz \
	&& wget -O lua-resty-redis.tar.gz  https://github.com/openresty/lua-resty-redis/archive/refs/tags/v${LUA_RESTY_REDIS_VERSION}.tar.gz \
	&& wget -O lua-resty-mysql.tar.gz  https://github.com/openresty/lua-resty-mysql/archive/refs/tags/v${LUA_RESTY_MYSQL_VERSION}.tar.gz\
	&& wget -O lua-resty-string.tar.gz  https://github.com/openresty/lua-resty-string/archive/refs/tags/v${LUA_RESTY_STRING_VERSION}.tar.gz \
	\
	# 这里使用for循环创建相关的目录并设置权限
	&& for path in \
		nginx \
		luajit2 \
		lua-cjson \
		lua-nginx-module \
		lua-resty-core \
		set-misc-nginx-module \
		encrypted-session-nginx-module \
		echo-nginx-module \
		lua-resty-lrucache \
		lua-resty-redis \
		lua-resty-mysql \
		lua-resty-string \
		ngx_devel_kit \
		lua-resty-http \
		lua-resty-cookie \
		lua-resty-logger-socket \
	; do \
		# 判断目录是否存在，如果不存在，创建
		if [ ! -d "/usr/src/${path}" ]; then \
			mkdir -p /usr/src/${path}; \
		fi; \
		tar -zxC /usr/src/${path} -f ${path}.tar.gz --strip-components=1; \
	done \
	# modsecurity install
	# && cd /usr/src/modsecurity \
	# && ./build.sh \
	# && ./configure \
	# && make \
	# && make install \
	# LuaJIT 2.1.x install \
	&& cd /usr/src/luajit2 \
	&& make \
	&& make install PREFIX=/usr/local \
	# 新版本这个名称变了 luajit-2.1.1731486438 ,而且默认已有这个/usr/local/bin/luajit 
	# && ln -sf /usr/local/bin/luajit-$LUAJIT2_VERSION /usr/local/bin/luajit \
	# lua-resty-core install \
	&& cd /usr/src/lua-resty-core \
	# 修正lib路径
	&& sed -i "s@^OPENRESTY_PREFIX=.*@OPENRESTY_PREFIX=/usr@" ./Makefile \
	&& sed -i "s@^PREFIX ?=.*@PREFIX ?=  /etc/nginx/lua@" ./Makefile \
	&& sed -i "s@^LUA_LIB_DIR ?=.*@LUA_LIB_DIR ?= \$(PREFIX)/lib/\$(LUA_VERSION)@" ./Makefile \
	&& sed -i "s@/nginx/sbin@/sbin@" ./Makefile \
	&& make && make install \
	# lua-json install more https://www.kyne.com.au/~mark/software/lua-cjson-manual.html#_installation \
	&& cd /usr/src/lua-cjson \
	# 修正编译路径
	# && sed -i "s@^PREFIX =            /usr/local@PREFIX = /usr/local@" ./Makefile \
	&& sed -i "s@^LUA_INCLUDE_DIR ?=   \$(PREFIX)/include@LUA_INCLUDE_DIR ?=   \$(PREFIX)/include/luajit-2.1@" ./Makefile \
	&& make && make install \
	# Lua resty core install \
	# Nginx compile and install
	&& cd /usr/src/nginx \
	&& export LUAJIT_LIB=/usr/local/lib \
	&& export LUAJIT_INC=/usr/local/include/luajit-2.1 \
	&& CONFIG="\
		--prefix=/etc/nginx \
		--sbin-path=/usr/sbin/nginx \
		--modules-path=/usr/lib/nginx/modules \
		--conf-path=/etc/nginx/nginx.conf \
		--error-log-path=${NGINX_LOG_DIR}/error.log \
		--http-log-path=${NGINX_LOG_DIR}/access.log \
		--pid-path=/var/run/nginx.pid \
		--lock-path=/var/run/nginx.lock \
		--http-client-body-temp-path=${NGINX_TEMP_PATH}/client_temp \
		--http-proxy-temp-path=${NGINX_TEMP_PATH}/proxy_temp \
		--http-fastcgi-temp-path=${NGINX_TEMP_PATH}/fastcgi_temp \
		--http-uwsgi-temp-path=${NGINX_TEMP_PATH}/uwsgi_temp \
		--http-scgi-temp-path=${NGINX_TEMP_PATH}/scgi_temp \
		--user=www-data \
		--group=www-data \
		--with-http_ssl_module \
		--with-http_realip_module \
		--with-http_addition_module \
		--with-http_sub_module \
		--with-http_dav_module \
		--with-http_flv_module \
		--with-http_mp4_module \
		--with-http_gunzip_module \
		--with-http_gzip_static_module \
		--with-http_random_index_module \
		--with-http_secure_link_module \
		--with-http_stub_status_module \
		--with-http_auth_request_module \
		--with-http_xslt_module=dynamic \
		--with-http_image_filter_module=dynamic \
		--with-http_geoip_module=dynamic \
		--with-threads \
		--with-stream \
		--with-stream_ssl_module \
		--with-stream_ssl_preread_module \
		--with-stream_realip_module \
		--with-stream_geoip_module=dynamic \
		--with-http_slice_module \
		--with-mail \
		--with-mail_ssl_module \
		--with-compat \
		--with-file-aio \
		--with-http_v2_module \
		--with-ld-opt="-Wl,-rpath,/usr/local/lib" \
        --add-dynamic-module=/usr/src/ngx_devel_kit \
        --add-dynamic-module=/usr/src/lua-nginx-module \
        --add-dynamic-module=/usr/src/set-misc-nginx-module \
        --add-dynamic-module=/usr/src/encrypted-session-nginx-module \
        --add-dynamic-module=/usr/src/echo-nginx-module \
	" \
	&& ./configure $CONFIG \
	&& sed -i 's/^\(CFLAGS.*\)/\1 -fstack-protector-strong -Wno-sign-compare/' objs/Makefile \
	&& make -j$(getconf _NPROCESSORS_ONLN) \
	&& make install \
	&& rm -rf /etc/nginx/html/ \
	&& mkdir /etc/nginx/conf.d/ \
	&& install -m644 html/index.html ${NGINX_WORK_DIR} \
	&& install -m644 html/50x.html ${NGINX_WORK_DIR} \
	&& ln -s ../../usr/lib/nginx/modules /etc/nginx/modules \
	&& strip /usr/sbin/nginx* \
	&& strip /usr/lib/nginx/modules/*.so \
	# && cp -a -r /usr/src/ngx_waf/assets/rules /etc/nginx/waf_rules \
	&& LUA_RESTY_LIB_PATH=/etc/nginx/lua/lib/${LUA_NGINX_MODULE_VERSION}/resty \
	&& mkdir -p ${LUA_RESTY_LIB_PATH} \
	&& cp -a -r /usr/src/lua-resty-lrucache/lib/resty/* ${LUA_RESTY_LIB_PATH}/ \
	&& cp -a -r /usr/src/lua-resty-redis/lib/resty/* ${LUA_RESTY_LIB_PATH}/ \
	&& cp -a -r /usr/src/lua-resty-mysql/lib/resty/* ${LUA_RESTY_LIB_PATH}/ \
	&& cp -a -r /usr/src/lua-resty-logger-socket/lib/resty/* ${LUA_RESTY_LIB_PATH}/ \
	&& cp -a -r /usr/src/lua-resty-string/lib/resty/* ${LUA_RESTY_LIB_PATH}/ \
	&& cp -a -r /usr/src/lua-resty-http/lib/resty/* ${LUA_RESTY_LIB_PATH}/ \
	&& cp -a -r /usr/src/lua-resty-cookie/lib/resty/* ${LUA_RESTY_LIB_PATH}/ \
	\
	&& runDeps="$( \
		scanelf --needed --nobanner --format '%n#p' /usr/sbin/nginx /usr/lib/nginx/modules/*.so /usr/bin/envsubst \
			| tr ',' '\n' \
			| sort -u \
			| awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
	)" \
	&& apk add --no-cache --virtual .nginx-rundeps $runDeps \
	&& cd /tmp/ \
	# install the diy index.html
	&& echo $'<!DOCTYPE html>\n\
<html>\n\
<head>\n\
<title>Welcome to tekintian/alpine-nginx!</title>\n\
<style>body {width: 35em;margin: 0 auto;font-family: Tahoma, Verdana, Arial, sans-serif;}</style>\n\
</head>\n\
<body>\n\
<h1>Welcome to Alpine Nginx, tekintian/alpine-nginx  !</h1>\n\
<p>If you see this page, the nginx web server is successfully installed and\n\
working. Further configuration is required.</p>\n\
<p><a href="/hello">check the lua hello demo</a></p>\n\
<p><a href="/lua_content">check the lua lua_content demo</a></p>\n\
<p><a href="/nginx_var">check the lua nginx_var demo</a></p>\n\
<p><a href="/redis_demo">check the lua redis_demo demo</a></p>\n\
<p><a href="/cookie_test">check the lua cookie_test demo</a></p>\n\
<br><br>\n\
<p>For Docker Nginx images documentation and support please refer to\n\
<a href="http://github.com/tekintian/alpine-nginx/" target="_blank">alpine-nginx</a>.</p>\n\
<br/>\n\
<h2>Support: tekintian@gmail.com   <a href="http://dev.tekin.cn" target="_blank">Dev Center</a></h2>\n\
<br/>  \n\
<p>For nginx online documentation and support please refer to\n\
<a href="http://nginx.org/" target="_blank">nginx.org</a>.<br/>\n\
<p><em>Thank you for using nginx.</em></p>\n\
</body>\n\
</html>\
	 '>${NGINX_WORK_DIR}/index.html \
	 \
	&& apk del .build-deps \
	\
	&& ln -s /etc/nginx/lua/lib/resty/core  /etc/nginx/lua/lib/${LUA_NGINX_MODULE_VERSION}/resty/core \
	&& ln -s /etc/nginx/lua/lib/resty/core.lua  /etc/nginx/lua/lib/${LUA_NGINX_MODULE_VERSION}/resty/core.lua \
	# 替换默认的NGINX配置中的lua路径
	# && sed -i "s#/etc/nginx/lua/lib/0.10.15#/etc/nginx/lua/lib/${LUA_NGINX_MODULE_VERSION}#g" /etc/nginx/nginx.conf \
	# && sed -i "s@#fastcgi_pass php:9000;@#fastcgi_pass php:9000;@g" /etc/nginx/conf.d/default.conf \
	# forward request and error logs to docker log collector
	# ln -sf /proc/self/fd/2 /var/log/nginx/access.log
	&& ln -sf /proc/self/fd/2 ${NGINX_LOG_DIR}/access.log \
	&& ln -sf /proc/self/fd/2 ${NGINX_LOG_DIR}/error.log \
	&& rm -rf /tmp/* \
	&& rm -rf /usr/src

STOPSIGNAL SIGTERM

WORKDIR ${NGINX_WORK_DIR}
EXPOSE 80 443
ENTRYPOINT ["tini", "--", "/usr/local/bin/docker-entrypoint"]
CMD ["nginx", "-g", "daemon off;"]

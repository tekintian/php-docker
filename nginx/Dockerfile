# http://nginx.org/
ARG ALPINE_VERSION=3.15
FROM tekintian/alpine:${ALPINE_VERSION}

ARG NGINX_VERSION \
    RELEASE_URL \
    ALPINE_VERSION \
    TAR_SHA256 \
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

# http://nginx.org/en/download.html
ENV NGINX_VERSION=${NGINX_VERSION:-"1.22.1"} \
	# 使用环境配置，默认 Y 开启, 使用环境变量替换nginx.conf中的相关配置项目 如果自己加载配置文件，则把这个设置为 N
    USE_ENV_CONF=${USE_ENV_CONF:-"Y"} \
    NGINX_WORK_DIR=${NGINX_WORK_DIR:-"/var/www/html"} \
    NGINX_SERVER_ROOT=${NGINX_SERVER_ROOT:-"/var/www/html"} \
	NGINX_LOG_DIR=${NGINX_LOG_DIR:-"/var/log/nginx"} \
	NGINX_TEMP_PATH=${NGINX_TEMP_PATH:-"/var/cache/nginx"} \
	NGINX_ROOT_DIR=${NGINX_ROOT_DIR:-"/etc/nginx"} \
	NGINX_CONF_DIR=${NGINX_CONF_DIR:-"/etc/nginx/conf.d"}

# COPY docker-entrypoint /usr/local/bin/
RUN set -eux \
	# ensure www-data user and group exists
	# alpine 3.15以下版本需要手动增加组
	# 获取alpine版本号的.后面的内容，如 3.12 获取 12
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
	  ${NGINX_TEMP_PATH} \
	  ${NGINX_CONF_DIR} \
	  ${NGINX_ROOT_DIR} \
	  /var/www \
	  /var/log \
	  /var/cache \
	  /var/run \
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
	# install the runtime app
	&& apk add --no-cache tini \
	# install build-deps
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
	&& wget -O /usr/local/bin/docker-entrypoint https://raw.githubusercontent.com/tekintian/php-docker/refs/heads/master/nginx/docker-entrypoint \
	&& chmod +x /usr/local/bin/docker-entrypoint \
	# nginx install
	&& wget -O nginx.tar.gz ${RELEASE_URL} --no-check-certificate \
	&& mkdir -p /usr/src/nginx \
	&& tar -zxvf nginx.tar.gz -C /usr/src/nginx --strip-components=1 \
	&& rm -rf *.tar.gz \
	&& cd /usr/src/nginx \
	&& CONFIG="--prefix=${NGINX_ROOT_DIR} \
		--sbin-path=/usr/sbin/nginx \
		--modules-path=/usr/lib/nginx/modules \
		--conf-path=${NGINX_ROOT_DIR}/nginx.conf \
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
	 " \
	&& ./configure ${CONFIG} \
	&& make -j$(getconf _NPROCESSORS_ONLN) \
	&& make install \
	&& rm -rf ${NGINX_ROOT_DIR}/html \
	&& install -m644 html/index.html ${NGINX_WORK_DIR} \
	&& install -m644 html/50x.html ${NGINX_WORK_DIR} \
	&& ln -s ../../usr/lib/nginx/modules ${NGINX_ROOT_DIR}/modules \
	&& strip /usr/sbin/nginx* \
	&& strip /usr/lib/nginx/modules/*.so \
	&& rm -rf /usr/src/nginx \
	\
	&& runDeps="$( \
		scanelf --needed --nobanner --format '%n#p' /usr/sbin/nginx /usr/lib/nginx/modules/*.so /usr/bin/envsubst \
			| tr ',' '\n' \
			| sort -u \
			| awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
	)" \
	&& apk add --no-cache --virtual .nginx-rundeps $runDeps \
	# wget the conf file
	\
    && chmod +x /usr/local/bin/docker-entrypoint \
	\
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
	# forward request and error logs to docker log collector
	&& ln -sf /proc/self/fd/2 ${NGINX_LOG_DIR}/access.log \
	&& ln -sf /proc/self/fd/2 ${NGINX_LOG_DIR}/error.log \
	&& rm -rf /tmp/* \
	&& rm -rf /usr/src

STOPSIGNAL SIGTERM

WORKDIR ${NGINX_WORK_DIR}
EXPOSE 80 443

ENTRYPOINT ["tini", "--", "/usr/local/bin/docker-entrypoint"]
CMD ["nginx", "-g", "daemon off;"]

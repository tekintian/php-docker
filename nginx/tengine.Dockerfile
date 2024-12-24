#
# This is the alpine linux work with tengine docker images
# @author tekintian
# @url http://github.com/tekintian/alpine-tengine
# @tengineTENGINE_VERSION  http://tengine.taobao.org/download.html
#
ARG ALPINE_VERSION=3.16
FROM tekintian/alpine:${ALPINE_VERSION}

ARG TENGINE_VERSION \
    RELEASE_URL \
    ALPINE_VERSION \
    BUILD_DATE \
    NGINX_WORK_DIR \
    NGINX_LOG_DIR \
    NGINX_TEMP_PATH

LABEL maintainer="TekinTian <tekintian@gmail.com>" \
      name="alpine-tengine" \
      version="${TENGINE_VERSION}" \
      description="Tengine ${TENGINE_VERSION} with Alpine ${ALPINE_VERSION} Linux Docker Container" \
      url="http://dev.tekin.cn" \
      build.date="${BUILD_DATE}"

#Tengine http://tengine.taobao.org/download.html
ENV TENGINE_VERSION=${TENGINE_VERSION:-"3.1.0"} \
	# 使用环境配置，默认 Y 开启, 使用环境变量替换nginx.conf中的相关配置项目 如果自己加载配置文件，则把这个设置为 N
    USE_ENV_CONF=${USE_ENV_CONF:-"Y"} \
    NGINX_WORK_DIR=${NGINX_WORK_DIR:-"/var/www/html"} \
    NGINX_SERVER_ROOT=${NGINX_SERVER_ROOT:-"/var/www/html"} \
	NGINX_LOG_DIR=${NGINX_LOG_DIR:-"/var/log/nginx"} \
	NGINX_TEMP_PATH=${NGINX_TEMP_PATH:-"/var/cache/nginx"} \
	NGINX_ROOT_DIR=${NGINX_ROOT_DIR:-"/etc/nginx"} \
	NGINX_CONF_DIR=${NGINX_CONF_DIR:-"/etc/nginx/conf.d"}

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
	  ${NGINX_TEMP_PATH}/client-body \
	  ${NGINX_TEMP_PATH}/proxy \
	  ${NGINX_TEMP_PATH}/fastcgi \
	  ${NGINX_TEMP_PATH}/scgi \
	  ${NGINX_TEMP_PATH}/uwsgi \
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
	&& apk add --no-cache --virtual .persistent-deps \
		openssl \
		pcre \
		zlib \
		jemalloc \
		geoip \
		tini \
	\
	# install make Dependence
	&& apk add --no-cache --virtual .build-deps \
		gcc \
		libc-dev \
		make \
		openssl-dev \
		pcre-dev \
		zlib-dev \
		linux-headers \
		jemalloc-dev \
		geoip-dev \
		tzdata \
		wget \
		tar \
		gzip \
	# compile & install 
	&& cd /tmp \
    # download entrypoint and set exec perms
	&& wget -O /usr/local/bin/docker-entrypoint https://raw.githubusercontent.com/tekintian/php-docker/refs/heads/master/nginx/tengine-entrypoint \
	&& chmod +x /usr/local/bin/docker-entrypoint \
    # src download
	&& wget -O tengine.tar.gz ${RELEASE_URL} --no-check-certificate \
	&& mkdir -p /usr/src/tengine \
	&& tar -zxvf tengine.tar.gz -C /usr/src/tengine --strip-components=1 \
	&& cd /usr/src/tengine \
	&& ./configure \
		--prefix=${NGINX_ROOT_DIR} \
		--conf-path=${NGINX_ROOT_DIR}/nginx.conf \
		--sbin-path=/usr/sbin/nginx \
		--pid-path=/var/run/nginx.pid \
		--lock-path=/var/run/lock/nginx.lock \
		--user=www-data \
		--group=www-data \
		--http-log-path=${NGINX_LOG_DIR}/access.log \
		--error-log-path=${NGINX_LOG_DIR}/error.log \
		--http-client-body-temp-path=${NGINX_TEMP_PATH}/client-body \
		--http-proxy-temp-path=${NGINX_TEMP_PATH}/proxy \
		--http-fastcgi-temp-path=${NGINX_TEMP_PATH}/fastcgi \
		--http-scgi-temp-path=${NGINX_TEMP_PATH}/scgi \
		--http-uwsgi-temp-path=${NGINX_TEMP_PATH}/uwsgi \
		--with-imap \
		--with-imap_ssl_module \
		--with-ipv6 \
		--with-pcre-jit \
		--with-http_dav_module \
		--with-http_gunzip_module \
		--with-http_gzip_static_module \
		--with-http_random_index_module \
		--with-http_realip_module \
		--with-http_ssl_module \
		--with-http_v2_module \
		--with-http_stub_status_module \
		--with-http_addition_module \
		--with-http_degradation_module \
		--with-file-aio \
		--with-mail \
		--with-mail_ssl_module \
		--with-jemalloc \
		 # --with-debug \
	&& make install \
	&& install -d ${NGINX_TEMP_PATH} ${NGINX_WORK_DIR} \
	\
	&& echo $'proxy_connect_timeout 300s;\n\
proxy_send_timeout 900;\n\
proxy_read_timeout 900;\n\
proxy_buffer_size 32k;\n\
proxy_buffers 4 64k;\n\
proxy_busy_buffers_size 128k;\n\
proxy_redirect off;\n\
proxy_hide_header Vary;\n\
proxy_set_header Accept-Encoding '';\n\
proxy_set_header Referer \$http_referer;\n\
proxy_set_header Cookie \$http_cookie;\n\
proxy_set_header Host \$host;\n\
proxy_set_header X-Real-IP \$remote_addr;\n\
proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;\n\
proxy_set_header X-Forwarded-Proto \$scheme;\
	'> ${NGINX_ROOT_DIR}/proxy.conf \
	# install the diy index.html
	&& echo $'<!DOCTYPE html>\n\
<html>\n\
<head>\n\
<title>Welcome to tekintian/alpine-tengine!</title>\n\
<style>body {width: 35em;margin: 0 auto;font-family: Tahoma, Verdana, Arial, sans-serif;}</style>\n\
</head>\n\
<body>\n\
<h1>Welcome to Alpine Nginx, tekintian/alpine-tengine  !</h1>\n\
<p>If you see this page, the tengine web server is successfully installed and\n\
working. Further configuration is required.</p>\n\
<br><br>\n\
<p>For Docker tengine images documentation and support please refer to\n\
<a href="http://github.com/tekintian/alpine-tengine/" target="_blank">alpine-tengine</a>.</p>\n\
<br/>\n\
<h2>Support: tekintian@gmail.com   <a href="http://dev.tekin.cn" target="_blank">Dev Center</a></h2>\n\
<br/>  \n\
<p>For tengine online doc please refer to\n\
<a href="http://tengine.taobao.org/documentation.html" target="_blank">Tengine</a>.<br/>\n\
<p><em>Thank you for using tengine.</em></p>\n\
</body>\n\
</html>\
	 '>${NGINX_WORK_DIR}/index.html \
	 \
	# forward request and error logs to docker log collector
	&& ln -sf /dev/stdout ${NGINX_LOG_DIR}/access.log \
	&& ln -sf /dev/stderr ${NGINX_LOG_DIR}/error.log \
	&& apk del .build-deps \
	&& rm -rf ~/* ~/.git ~/.gitignore ~/.travis.yml ~/.ash_history \
	&& rm -rf /tmp/* \
	&& rm -rf /usr/src \
	&& rm -rf /var/cache/apk/*

STOPSIGNAL SIGTERM

WORKDIR ${NGINX_WORK_DIR}
EXPOSE 80 443
ENTRYPOINT ["tini", "--", "/usr/local/bin/docker-entrypoint"]
CMD ["nginx", "-g", "daemon off;"]
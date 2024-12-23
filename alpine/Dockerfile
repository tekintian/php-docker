#定义FROM 中用的alpine版本,注意这个只能放到这里,否则无法识别
ARG ALPINE_VERSION="3.17"

# builder container
# 在运行容器中使用 COPY --from=builder "/xxx" "/xxx" 即可将builder容器中创建的内容拷贝到运行容器中
FROM alpine:3.15 as builder

ENV ALPINE_VERSION=${ALPINE_VERSION:-3.17} \
    APK_MIRROR=${APK_MIRROR:-"dl-cdn.alpinelinux.org"}

RUN set -eux; \
	sed -r -i -e "s|([a-zA-Z0-9\-]+)\.([^\/]+)\.([a-z]{2,})|${APK_MIRROR}|g" /etc/apk/repositories;\
	# sed -i -e "s|dl-cdn.alpinelinux.org|${APK_MIRROR}|g" /etc/apk/repositories;\
	# 增加testing分支到apk仓库
	# echo "https://${APK_MIRROR}/alpine/edge/testing" >> /etc/apk/repositories ;\
	# 注意 因为有测试分支,所以下面的所有的apk xx操作后面都需要带上 --allow-untrusted
	# apk update --allow-untrusted; \
	# install envsubst to /usr/bin/envsubst
	# apk add envsubst --allow-untrusted; \
	\
	apk update; \
	# install src build deps
	apk add --no-cache --virtual .build-deps \
	    wget unzip \
	    g++ gcc libc-dev make \
	  # autoconf pkgconf re2c \
	; \
	cd /tmp; \
	wget -O /tmp/envsubst-main.tar.gz https://github.com/tekintian/envsubst/archive/refs/heads/main.tar.gz --no-check-certificate; \
	mkdir -p /tmp/envsubst; \
	tar -zxvf envsubst-main.tar.gz -C /tmp/envsubst --strip-components=1; \
	cd /tmp/envsubst; \
	make; \
	# default install to /usr/local/bin/envsubst
	make install; \
	# \
	# gettext中包含的envsubst安装路径为 /usr/bin/envsubst
	# apk add --no-cache gettext --allow-untrusted; \
	\
	cd /tmp; \
	apk add --no-cache tzdata;\
	#按需拷贝tz数据
	mkdir -p /opt/zoneinfo;\
	cp -a /usr/share/zoneinfo/GMT /opt/zoneinfo/;\
	cp -a /usr/share/zoneinfo/PRC /opt/zoneinfo/;\
	cp -a /usr/share/zoneinfo/EST /opt/zoneinfo/;\
	cp -a /usr/share/zoneinfo/UTC /opt/zoneinfo/;\
	\
	# clear the build deps
	apk del --no-network .build-deps; \
	# clear cache and tmp file
	[ -d /var/cache/apk ]; \
	rm -rf /var/cache/apk/*; \
	rm -rf /tmp/*

FROM alpine:${ALPINE_VERSION}

ARG BUILD_DATE

LABEL org.opencontainers.image.authors="Tekin<tekintian@gmail.com>" \
      org.opencontainers.image.description="alpine ${ALPINE_VERSION} Small. Simple. Secure base docker images with PRC TZ and envsubst app, by http://dev.tekin.cn Build ${BUILD_DATE}" \
      org.opencontainers.image.ref.name="alpine" \
      org.opencontainers.image.source="https://github.com/tekintian/alpine" \
      org.opencontainers.image.title="alpine ${ALPINE_VERSION} base docker images " \
      org.opencontainers.image.vendor="tekintian" \
      org.opencontainers.image.version="${ALPINE_VERSION}" \
      org.opencontainers.image.updated="${BUILD_DATE}"

ENV ALPINE_VERSION=${ALPINE_VERSION:-3.17} \
    APK_MIRROR=${APK_MIRROR:-"dl-cdn.alpinelinux.org"} \
    TZ=PRC

# copy envsubst from builder
COPY --from=builder "/usr/local/bin/envsubst" "/usr/bin/envsubst"

# 从tzdata包中按需拷贝需要的TZ数据
COPY --from=builder "/opt/zoneinfo" "/usr/share/zoneinfo"

RUN set -eux; \
	sed -r -i -e "s|([a-zA-Z0-9\-]+)\.([^\/]+)\.([a-z]{2,})|${APK_MIRROR}|g" /etc/apk/repositories;\
	cd /tmp/ ;\
	\
	# apk add --no-cache libintl;\
	chmod +x /usr/bin/envsubst ; \
	\
	rm -rf /etc/localtime ;\
	mkdir -p /usr/share/zoneinfo/Asia ;\
	ln -s /usr/share/zoneinfo/PRC /etc/localtime ;\
	ln -s /usr/share/zoneinfo/PRC /usr/share/zoneinfo/Asia/Shanghai ;\
	echo "Asia/Shanghai" >  /etc/timezone ;\
	\
	rm -rf /var/cache/apk/* ;\
	rm -rf /tmp/*
# Tengine-ingress

https://codeload.github.com/alibaba/tengine-ingress/tar.gz/refs/tags/Tengine-Ingress-v1.1.0

## Tengine镜像构建
~~~
docker build --no-cache --build-arg BASE_IMAGE="tekintian/alpine:3.16" --build-arg LINUX_RELEASE="alpine" -t tekintian/alpine-tengine:3.1.0 images/tengine/rootfs/
~~~







## tengine-ingress镜像构建
~~~
docker build --no-cache --build-arg BASE_IMAGE="tekintian/alpine-tengine:3.1.0" --build-arg VERSION="1.1.0" -f build/Dockerfile -t tekintian/tengine-ingress:1.1.0 .
~~~





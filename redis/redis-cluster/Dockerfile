FROM  ruby:2.5-alpine
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
  && apk add  gcc g++ libc-dev  wget vim  openssl-dev make  linux-headers  bash \
  && rm -rf /var/cache/apk/*

RUN wget https://rubygems.org/downloads/redis-4.0.2.gem  &&  gem install -l ./redis-4.0.2.gem \
&&  rm -f redis-4.0.2.gem

#通过选择更小的镜像，删除不必要文件清理不必要的安装缓存，从而瘦身镜像
#创建相关目录能够看到日志信息跟数据跟配置文件
RUN mkdir -p /usr/src/redis \
      && mkdir -p /usr/src/redis/data \
      && mkdir -p /usr/src/redis/conf \
      && mkdir -p /usr/src/sh         \
      && mkdir -p /usr/src/redis/log

RUN wget  -O /usr/src/redis/redis-4.0.11.tar.gz  "http://download.redis.io/releases/redis-4.0.11.tar.gz" \
   && tar -xzf /usr/src/redis/redis-4.0.11.tar.gz  -C /usr/src/redis \
   && cp  /usr/src/redis/redis-4.0.11/src/redis-trib.rb  /usr/src/redis/ \
   && rm -rf /usr/src/redis/redis-4.0.11.tar.tgz

RUN cd /usr/src/redis/redis-4.0.11 &&  make && make PREFIX=/usr/local/redis install \
&& ln -s /usr/local/redis/bin/*  /usr/local/bin/  && rm -rf /usr/src/redis/redis-4.0.11

COPY ./sh/cluster.sh   /usr/src/sh
COPY ./sh/redis-trib.rb   /usr/src/sh/redis-trib.rb
RUN  chmod +x  /usr/src/sh/cluster.sh && chmod +x  /usr/src/sh/redis-trib.rb

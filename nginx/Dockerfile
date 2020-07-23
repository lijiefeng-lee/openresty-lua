FROM centos:centos7
RUN  mkdir /data  && mkdir /conf && groupadd -r nginx && useradd -r -g nginx nginx \
      && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo 'Asia/Shanghai' >/etc/timezone \
      && yum install  -y wget && wget -O /etc/yum.repos.d/epel.repo   http://mirrors.aliyun.com/repo/Centos-7.repo \
      && yum update -y \
      &&  yum clean all  \
      &&  yum makecache  \
      &&  yum -y install  gcc gcc-c++ autoconf automake make zlib zlib-devel net-tools openssl* pcre* wget \
      &&  yum clean all  && rm -rf /var/cache/yum/* \
      &&  cd /data \
      && wget http://nginx.org/download/nginx-1.14.1.tar.gz \
      && tar -zxvf nginx-1.14.1.tar.gz \
      && cd nginx-1.14.1 \
      && ./configure --prefix=/usr/local/nginx --user=nginx --group=nginx \
      && make && make install && rm -rf  /data/nginx-1.14.1.tar.gz  && rm -rf  /data/nginx-1.14.1 \
      && ln -s /usr/local/nginx/sbin/*  /usr/local/sbin

#进入容器时默认打开的目录
WORKDIR /conf

#声明匿名卷
VOLUME /data

COPY ./conf/nginx.conf   /conf

#声明端口
EXPOSE 80

#容器启动的时候执行,在docker run过程当中是会被其他指令替代
#CMD ["/usr/local/redis 安装 nginx/sbin/redis 安装 nginx","-c","/conf/redis 安装 nginx.conf","-g","daemon off;"]

#执行一条指令不会替代
ENTRYPOINT ["/usr/local/nginx/sbin/nginx","-c","/conf/nginx.conf","-g","daemon off;"]
FROM php:7.3-fpm-alpine

# Version
ENV PHPREDIS_VERSION 4.0.0

# Libs
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
    && apk  add  \
        curl \
        vim  \
        wget \
        git \
        openssl-dev\
        zip \
        unzip \
        g++  make autoconf

# Composer
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer \
    && composer self-update --clean-backups

# docker方式安装PDO extension                                                                                # 安装扩展
RUN   mv "$PHP_INI_DIR/php.ini-production"  "$PHP_INI_DIR/php.ini" &&  docker-php-ext-install pdo_mysql &&   docker-php-ext-install pcntl && docker-php-ext-install sysvmsg

# Redis extension
RUN wget http://pecl.php.net/get/redis-${PHPREDIS_VERSION}.tgz -O /tmp/redis.tar.tgz \
    && pecl install /tmp/redis.tar.tgz \
    && rm -rf /tmp/redis.tar.tgz \
    && docker-php-ext-enable redis
 # 修改php.ini的文件 extension=redis.so

#切换镜像
RUN  composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/ && mkdir /www && chown www-data /www

#设置工作目录
WORKDIR  /www






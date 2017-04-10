FROM php:7.0.6-fpm-alpine
MAINTAINER sergey.motorny@vanderbilt.edu
RUN apk add --no-cache nginx mysql-client supervisor curl bash redis imagemagick-dev libpng-dev curl-dev tzdata
ENV CFLAGS -I/usr/src/php
RUN apk add --no-cache libtool build-base autoconf libxml2 libxml2-dev \
    && docker-php-ext-install -j$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) iconv gd mbstring fileinfo curl xmlreader xmlwriter spl ftp mysqli opcache dom \
    && pecl install imagick \
    && docker-php-ext-enable imagick
ENV WP_ROOT /usr/src/wordpress
ENV WP_VERSION 4.7.3
ENV WP_SHA1 35adcd8162eae00d5bc37f35344fdc06b22ffc98
ENV WP_DOWNLOAD_URL https://wordpress.org/wordpress-$WP_VERSION.tar.gz
RUN curl -o wordpress.tar.gz -SL $WP_DOWNLOAD_URL \
    && echo "$WP_SHA1 *wordpress.tar.gz" | sha1sum -c - \
    && tar -xzf wordpress.tar.gz -C $(dirname $WP_ROOT) \
    && rm wordpress.tar.gz
RUN adduser -D deployer -s /bin/bash -G www-data
VOLUME /var/www/wp-content
WORKDIR /var/www/wp-content
COPY wp-config.php $WP_ROOT
RUN chown -R deployer:www-data $WP_ROOT \
    && chmod 640 $WP_ROOT/wp-config.php
COPY cron.conf /etc/crontabs/deployer
RUN chmod 600 /etc/crontabs/deployer
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp
COPY nginx.conf /etc/nginx/nginx.conf
COPY vhost.conf /etc/nginx/conf.d/
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log \
    && chown -R www-data:www-data /var/lib/nginx
RUN ln -sf /usr/share/zoneinfo/America/Chicago /etc/localtime
RUN echo "America/Chicago" > /etc/timezone
COPY docker-entrypoint.sh /usr/bin
RUN chmod 755 /usr/bin/docker-entrypoint.sh
ENTRYPOINT [ "/usr/bin/docker-entrypoint.sh" ]
RUN mkdir -p /var/log/supervisor
COPY supervisord.conf /etc/supervisord.conf
CMD [ "/usr/bin/supervisord", "-c", "/etc/supervisord.conf" ]

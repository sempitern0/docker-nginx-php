FROM php:8.4-fpm-alpine


RUN apk add --no-cache tzdata \
    && docker-php-ext-install -j"$(nproc)" pdo_mysql \
    && docker-php-ext-enable opcache

RUN { \
        echo '[www]'; \
        echo 'user = www-data'; \
        echo 'group = www-data'; \
        echo 'listen = 9000'; \
        echo 'clear_env = no'; \
        echo 'catch_workers_output = yes'; \
        echo 'decorate_workers_output = no'; \
        echo 'pm = dynamic'; \
        echo 'pm.max_children = 10'; \
        echo 'pm.start_servers = 2'; \
        echo 'pm.min_spare_servers = 1'; \
        echo 'pm.max_spare_servers = 3'; \
        echo 'pm.max_requests = 500'; \
        echo 'request_terminate_timeout = 60s'; \
    } > /usr/local/etc/php-fpm.d/zz-app.conf

RUN { \
        echo 'opcache.enable=1'; \
        echo 'opcache.enable_cli=1'; \
        echo 'opcache.memory_consumption=128'; \
        echo 'opcache.interned_strings_buffer=16'; \
        echo 'opcache.max_accelerated_files=10000'; \
        echo 'opcache.validate_timestamps=1'; \
        echo 'opcache.revalidate_freq=2'; \
        echo 'opcache.save_comments=1'; \
    } > /usr/local/etc/php/conf.d/10-opcache.ini

RUN php -m | grep -q '^PDO$' \
    && php -m | grep -q '^pdo_mysql$' \
    && php -r 'exit(in_array("mysql", PDO::getAvailableDrivers(), true) ? 0 : 1);'

WORKDIR /usr/share/nginx/html

CMD ["php-fpm", "-F"]
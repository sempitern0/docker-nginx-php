FROM php:8.4.25-fpm-alpine3.24

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

RUN apk add --no-cache tzdata libpq \
    && apk add --no-cache --virtual .build-deps postgresql-dev \
    && docker-php-ext-install -j"$(nproc)" pdo_mysql pdo_pgsql pgsql \
    && apk del .build-deps \
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
        echo 'opcache.enable_cli=0'; \
        echo 'opcache.memory_consumption=128'; \
        echo 'opcache.interned_strings_buffer=16'; \
        echo 'opcache.max_accelerated_files=10000'; \
        echo 'opcache.validate_timestamps=1'; \
        echo 'opcache.save_comments=1'; \
    } > /usr/local/etc/php/conf.d/10-opcache.ini

RUN { \
        echo 'expose_php = Off'; \
        echo 'display_errors = Off'; \
        echo 'display_startup_errors = Off'; \
        echo 'log_errors = On'; \
        echo 'error_reporting = E_ALL'; \
        echo 'allow_url_fopen = Off'; \
        echo 'allow_url_include = Off'; \
        echo 'disable_functions = exec,passthru,shell_exec,system,proc_open,popen,parse_ini_file,show_source'; \
        echo 'max_execution_time = 30'; \
        echo 'max_input_time = 60'; \
        echo 'memory_limit = 128M'; \
        echo 'post_max_size = 12M'; \
        echo 'upload_max_filesize = 10M'; \
        echo 'session.cookie_httponly = 1'; \
        echo 'session.cookie_secure = 1'; \
        echo 'session.cookie_samesite = Lax'; \
        echo 'session.use_strict_mode = 1'; \
        echo 'session.use_only_cookies = 1'; \
    } > /usr/local/etc/php/conf.d/99-security.ini

WORKDIR /usr/share/nginx/html
COPY sites /usr/share/nginx/html

RUN php -m | grep -q '^PDO$' \
    && php -m | grep -q '^pdo_mysql$' \
    && php -m | grep -q '^pdo_pgsql$' \
    && php -r 'exit(in_array("mysql", PDO::getAvailableDrivers(), true) && in_array("pgsql", PDO::getAvailableDrivers(), true) ? 0 : 1);'

CMD ["php-fpm", "-F"]
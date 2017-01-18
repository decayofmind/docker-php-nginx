#!/usr/bin/env bats

_webdir=/var/www/web
if [ -d "$_webdir" ]; then
    rm -rf "$_webdir"
fi

@test "composer ${COMPOSER_VERSION} is installed" {
    run composer --version
    [ "$status" -eq 0 ]
    [[ "$output" =~ "${COMPOSER_VERSION}" ]]
}

@test "nginx ${NGINX_VERSION} is installed" {
    run nginx -v
    [ "$status" -eq 0 ]
    [[ "$output" =~ "${NGINX_VERSION}" ]]
}

@test "php ${PHP_VERSION} is installed" {
    run php -v
    [ "$status" -eq 0 ]
    [[ "$output" =~ "${PHP_VERSION}" ]]
}

@test "check timezone is ${TIMEZONE} for php" {
    run bash -c "php -i | grep -q 'date.timezone => ${TIMEZONE}'"
    [ "$status" -eq 0 ]
}

@test "nginx is accepting HTTPS on ${VIRTUAL_HOST} and forwarding to php-fpm" {
    run curl -ks https://${VIRTUAL_HOST}
    [ "$status" -eq 0 ]
    [[ "$output" = "No input file specified." ]]
}

@test "nginx is accepting HTTP ${VIRTUAL_HOST} and forwarding to php-fpm" {
    run curl -s http://${VIRTUAL_HOST}
    [ "$status" -eq 0 ]
    [[ "$output" = "No input file specified." ]]
}

@test "PHP execution by phpinfo" {
    mkdir "$_webdir"
    echo "<?php phpinfo(); ?>" > "$_webdir"/phpinfo.php
    chown -R apache:apache "$_webdir"
    run curl -I http://${VIRTUAL_HOST}/phpinfo.php
    [ "$status" -eq 0 ]
    [[ "$output" =~ "200 OK" ]]
    rm -rf "$_webdir"
}

#!/bin/bash
NAME='PHP OPcache'

if [ ${#} -ne 1 ]; then
    echo "=== Turn OFF/ON - ${NAME} ==="
    echo "Usage: $0 0|1" >&2
    echo
    exit 1
fi

if [ "$1" -eq 0 ]; then
    echo " * Turn OFF - ${NAME} * "
    sed -r -i "s:^zend_extension=opcache.so$:;zend_extension=opcache.so:g" /etc/php.d/opcache.ini
else
    echo " * Turn ON - ${NAME} * "
    sed -r -i "s:^;zend_extension=opcache.so$:zend_extension=opcache.so:g" /etc/php.d/opcache.ini
fi

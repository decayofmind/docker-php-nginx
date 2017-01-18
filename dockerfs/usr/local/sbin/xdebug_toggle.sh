#!/bin/bash
NAME='PHP Xdebug'

if [ ${#} -ne 1 ] && [ ${#} -ne 2 ]; then
    echo "=== Turn OFF/ON - ${NAME} ==="
    echo "Usage: $0 0|1" >&2
    echo
    exit 1
fi

if [ "$1" -eq 0 ]; then
    echo " * Turn OFF - ${NAME} * "
    sed -r -i "s:^zend_extension=/usr/lib64/php/modules/xdebug.so$:;zend_extension=/usr/lib64/php/modules/xdebug.so:g" /etc/php.d/xdebug.ini
else
    echo " * Turn ON - ${NAME} * "
    sed -r -i "s:^;zend_extension=/usr/lib64/php/modules/xdebug.so$:zend_extension=/usr/lib64/php/modules/xdebug.so:g" /etc/php.d/xdebug.ini
fi

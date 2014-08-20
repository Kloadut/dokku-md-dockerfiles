#!/bin/bash
set -x
if [[ ! -f /opt/mysql/initialized ]]; then
    mkdir -p /opt/mysql
    cp -a /var/lib/mysql/* /opt/mysql/
    chown -R mysql:mysql /opt/mysql
    chmod -R 755 /opt/mysql
fi
sleep 2
mysqld_safe --skip-syslog --log-error=/var/log/mysql.err &
# Wait for socket to be ready
while [ ! -S /var/run/mysqld/mysqld.sock ]; do sleep 1; done
if [[ ! -f /opt/mysql/initialized ]]; then
    echo "CREATE DATABASE db;" | mysql -u root --password=a_stronk_password
    echo "UPDATE mysql.user SET Password=PASSWORD('$1') WHERE User='root'; FLUSH PRIVILEGES;" | mysql -u root --password=a_stronk_password mysql
    echo "GRANT ALL ON *.* to root@'%' IDENTIFIED BY '$1'; FLUSH PRIVILEGES;" | mysql -u root --password="$1" mysql
    touch /opt/mysql/initialized
fi
touch /var/log/mysql/mariadb-slow.log
tail -f /var/log/mysql.log /var/log/mysql.err /var/log/mysql/mariadb-slow.log

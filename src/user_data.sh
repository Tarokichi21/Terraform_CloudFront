#!/bin/bash
set -eux

dnf update -y

dnf install -y \
  httpd \
  php \
  php-cli \
  php-mysqlnd \
  php-gd \
  php-mbstring \
  php-xml \
  wget \
  tar

systemctl enable httpd
systemctl start httpd

cd /tmp
wget https://ja.wordpress.org/latest-ja.tar.gz
tar -xzf latest-ja.tar.gz

rm -rf /var/www/html/*
cp -r wordpress/* /var/www/html/

chown -R apache:apache /var/www/html
chmod -R 755 /var/www/html

rm -f /var/www/html/index.html
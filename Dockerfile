# Use Ubuntu 24.04 as the base image
FROM ubuntu:24.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV PHP_VERSION=8.3
ENV MYSQL_ROOT_PASSWORD=root

# Update and install necessary packages
RUN apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository ppa:ondrej/php && \
    apt-get update && \
    apt-get install -y \
    nginx \
    php${PHP_VERSION} \
    php${PHP_VERSION}-fpm \
    php${PHP_VERSION}-mysql \
    php${PHP_VERSION}-xml \
    php${PHP_VERSION}-mbstring \
    php${PHP_VERSION}-curl \
    php${PHP_VERSION}-zip \
    php${PHP_VERSION}-gd \
    php${PHP_VERSION}-intl \
    php${PHP_VERSION}-bcmath \
    php${PHP_VERSION}-soap \
    php${PHP_VERSION}-redis \
    php${PHP_VERSION}-memcached \
    php${PHP_VERSION}-opcache \
    php${PHP_VERSION}-imagick \
    php${PHP_VERSION}-xmlrpc \
    php${PHP_VERSION}-cli \
    php${PHP_VERSION}-common \
    php${PHP_VERSION}-mbstring \
    php${PHP_VERSION}-readline \
    php${PHP_VERSION}-simplexml \
    php${PHP_VERSION}-tokenizer \
    php${PHP_VERSION}-xdebug \
    mariadb-server \
    phpmyadmin \
    redis-server \
    memcached \
    unzip \
    curl \
    wget \
    git && \
    apt-get clean

# Set MariaDB root password
RUN service mariadb start && \
    mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';" && \
    mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "FLUSH PRIVILEGES;"

# Phpmyadmin config
RUN sed -i "s/\$dbuser='[^']*';/\$dbuser='root';/" /etc/phpmyadmin/config-db.php && \
    sed -i "s/\$dbpass='[^']*';/\$dbpass='${MYSQL_ROOT_PASSWORD}';/" /etc/phpmyadmin/config-db.php

# PHP config
COPY ./components/php/conf.d/* /etc/php/8.3/fpm/conf.d

# Start services
CMD ["sh", "-c", "service nginx start && service php${PHP_VERSION}-fpm start && service mariadb start && service redis-server start && service memcached start && tail -f /dev/null"]

# Expose ports
EXPOSE 80 443 3306 6379 11211


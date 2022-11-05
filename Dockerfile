FROM ubuntu:20.04
LABEL org.opencontainers.image.source="https://github.com/inadsan/docker-webmail-lite"
LABEL org.opencontainers.image.authors="Daniel Sánchez"
LABEL maintainer="AfterLogic Support <support@afterlogic.com>"

LABEL version="9.6.0"
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get upgrade -y

RUN apt-get install -y \
    wget \
    zip \
    unzip \
    php7.4 \
    php7.4-cli \
    php7.4-common \
    php7.4-curl \
    php7.4-json \
    php7.4-mbstring \
    php7.4-mysql \
    php7.4-xml \
    apache2 \
    libapache2-mod-php7.4 \
    mariadb-common \
    mariadb-server \
    mariadb-client \
    jq

ENV LOG_STDOUT **Boolean**
ENV LOG_STDERR **Boolean**
ENV LOG_LEVEL warn
ENV ALLOW_OVERRIDE All
ENV DATE_TIMEZONE UTC

COPY run-lamp.sh /usr/sbin/
RUN chmod +x /usr/sbin/run-lamp.sh
COPY apache.conf /etc/apache2/sites-available/000-default.conf
RUN a2enmod rewrite

RUN rm -rf /tmp/alwm && \
    mkdir -p /tmp/alwm && \
    wget -P /tmp/alwm https://afterlogic.org/download/webmail_php.zip && \
    unzip -q /tmp/alwm/webmail_php.zip -d /tmp/alwm/ && \
    rm /tmp/alwm/webmail_php.zip

RUN rm -rf /var/www/html && \
    mkdir -p /var/www/html && \
    cp -r /tmp/alwm/* /var/www/html && \
    chown -R www-data:www-data /var/www/html && \
    chmod -R 0777 /var/www/html/data
    
RUN rm -f /var/www/html/afterlogic.php
COPY afterlogic.php /var/www/html/afterlogic.php
RUN rm -rf /tmp/alwm

VOLUME ["/var/www/html/data", "/var/log/apache2", "/var/lib/mysql", "/var/log/mysql"]

EXPOSE 80 3306

CMD ["/usr/sbin/run-lamp.sh"]

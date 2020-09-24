FROM php:5.6-apache
MAINTAINER Rommel de Torres <detorresrc@gmail.com>

RUN requirements="libpng-dev libxslt-dev libpng16-16 libjpeg-dev libjpeg62-turbo libmcrypt4 libmcrypt-dev libcurl3-dev libxml2-dev libxslt-dev libicu-dev libicu57" \
    && apt-get update && apt-get install -y $requirements && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-install pdo_mysql \
    && docker-php-ext-install mysql \
    && docker-php-ext-configure gd --with-jpeg-dir=/usr/lib \
    && docker-php-ext-install gd \
    && docker-php-ext-install mcrypt \
    && docker-php-ext-install mbstring \
    && docker-php-ext-install soap \
    && docker-php-ext-install xsl \
    && docker-php-ext-install intl \
    && docker-php-ext-install opcache \
    && docker-php-ext-install xsl \
    # PHP Config
    && mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini" \
    && echo "always_populate_raw_post_data=-1" >> /usr/local/etc/php/php.ini \
    && sed -i 's/expose_php = On/expose_php = Off/g' /usr/local/etc/php/php.ini

#PHP Composer
RUN curl -sSL https://getcomposer.org/composer.phar -o /usr/bin/composer \
    && chmod +x /usr/bin/composer \
    && apt-get update && apt-get install -y zlib1g-dev git && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-install zip \
    && apt-get purge -y --auto-remove zlib1g-dev \
    && composer selfupdate

VOLUME ["/var/www"]
WORKDIR /var/www

# Apache2 Config
RUN usermod -u 1000 www-data && chown -R www-data:www-data /var/www
RUN a2enmod rewrite && a2enmod headers && a2enmod cache && a2enmod cache_disk

COPY config/apache2.conf /etc/apache2/
COPY config/000-default.conf /etc/apache2/sites-available/
COPY config/security.conf /etc/apache2/conf-available/
COPY config/cache_disk.conf /etc/apache2/mods-available/

# Update Package
RUN apt update && apt install apache2 -y

ADD src/ /var/www/
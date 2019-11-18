FROM php:7.3-apache
MAINTAINER zlin <leolin0312@gmail.com>

# enable apache rewrite module, modify the first non-root user as www-data, and set the owner for the document root folder
RUN a2enmod rewrite && usermod -u 1000 www-data && chown -R www-data:www-data /var/www

# install additional PHP extensions
RUN requirements="libxml2-dev libpq-dev libmcrypt-dev libmcrypt4 libcurl3-dev libfreetype6 libjpeg62-turbo-dev libfreetype6-dev libpng-dev libzip-dev libicu-dev libxslt1-dev mariadb-client" \
    && apt-get update \
    && apt-get install -y $requirements \
    && docker-php-ext-install pcntl \
    && docker-php-ext-install pdo \
    && docker-php-ext-install pdo_pgsql \
    && docker-php-ext-install pdo_mysql \
    && docker-php-ext-install mysqli \
    && docker-php-ext-install mbstring \
    && docker-php-ext-install zip \
    && docker-php-ext-install intl \
    && docker-php-ext-install xsl \
    && docker-php-ext-install soap \
    && docker-php-ext-install bcmath \
    && docker-php-ext-install opcache \
    && docker-php-ext-configure gd \
		--with-freetype-dir=/usr \
		--with-jpeg-dir=/usr \
		--with-png-dir=/usr \
    && docker-php-ext-install gd

RUN apt-get update && apt-get install -y git nano ssh

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=2'; \
		echo 'opcache.fast_shutdown=1'; \
		echo 'opcache.enable_cli=1'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini

# Sets extra php.ini settings.
RUN { \
		echo 'date.timezone = Europe/Paris'; \
		echo 'upload_max_filesize = 64M'; \
		echo 'post_max_size = 128M'; \
		echo 'xdebug.max_nesting_level = 256'; \
		echo 'memory_limit = 256M'; \
	} > /usr/local/etc/php/conf.d/custom-settings.ini

# Install extra utils
# Add composer
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer \
    && chmod a+x /usr/local/bin/composer
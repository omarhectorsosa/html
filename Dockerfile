ARG php_version=7.2.24-apache
ARG composer_version=latest-2.2.x
FROM php:${php_version}

RUN a2enmod rewrite

RUN apt-get update \
  && apt-get install -y acl ssh nodejs npm libzip-dev \
  git wget libicu-dev libmcrypt-dev libedit-dev libreadline-dev \
  libfreetype6-dev libjpeg62-turbo-dev libpng-dev \
  libldap2-dev libxml2-dev \
  --no-install-recommends \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
 
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/
RUN docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu
RUN docker-php-ext-install  -j$(nproc) gd mysqli pdo_mysql zip mbstring intl ldap opcache readline soap xml bcmath

COPY apache.conf /etc/apache2/sites-enabled/000-default.conf 

ARG composer_version
RUN wget https://getcomposer.org/download/${composer_version}/composer.phar \
    && mv composer.phar /usr/bin/composer && chmod +x /usr/bin/composer

COPY build/ /var/wwww/
WORKDIR /var/www/

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
CMD ["apache2-foreground"]
ENTRYPOINT ["/entrypoint.sh"]
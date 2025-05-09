# Stage 1: common base for all projects
FROM php:8.3-apache AS base

# System dependencies for all stacks (PHP, MySQL and MongoDB)
RUN apt-get update && apt-get install -y \
    git curl zip unzip \
    libpng-dev libonig-dev libxml2-dev \
    libssl-dev pkg-config

# PHP Native extensions (support for MySQL)
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# MongoDB vía PECL extension
RUN pecl install mongodb \
 && echo "extension=mongodb.so" > /usr/local/etc/php/conf.d/mongodb.ini

# Always enable rewrite, required for all frameworks
RUN a2enmod rewrite proxy proxy_http

# Install composer into container
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy the dashboard default virtual host config
COPY ./etc/templates/apache2/sites-available/000-default.conf /etc/apache2/sites-available

# Copy the local generated virtual host config
COPY ./etc/docker/apache2/sites-available/* /etc/apache2/sites-available

# Create symbolyc links automatically for all .conf files already into the container
RUN for site in /etc/apache2/sites-available/*.conf; do \
      ln -s "$site" "/etc/apache2/sites-enabled/$(basename $site)"; \
    done

# Disable default host SSL (not required, copied with placeholder *.conf)
RUN a2dissite default-ssl.conf

# Redirect stdout/stderr logs apache to docker log
RUN ln -sf /dev/stdout /var/log/apache2/access.log \
 && ln -sf /dev/stderr /var/log/apache2/error.log

WORKDIR /var/www/html

# Stage 2: Build development environment
FROM base AS development

# php-xdebug is not available as apt package on official image of php:8.3-apache, therefore we need to install it via PECL
RUN pecl install xdebug \
 && docker-php-ext-enable xdebug

# Configure Xdebug
# If some day is available via docker-php-ext-enable
# RUN echo "zend_extension=xdebug.so" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

RUN echo "xdebug.mode=develop,debug" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
 && echo "xdebug.start_with_request=yes" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
 && echo "xdebug.client_host=host.docker.internal" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
 && echo "xdebug.client_port=9003" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

CMD ["apache2-foreground"]

# Stage 3: Production
FROM base AS production

# Setup directory permissions
RUN chown -R www-data:www-data /var/www/html && chmod -R 755 /var/www/html

CMD ["apache2-foreground"]

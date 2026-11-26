FROM php:8.2-apache

# Install MariaDB server and required PHP extensions
RUN apt-get update && apt-get install -y \
    mariadb-server \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd pdo pdo_mysql \
    && a2enmod rewrite \
    && rm -rf /var/lib/apt/lists/*

# Set Apache DocumentRoot and permissions
WORKDIR /var/www/html
COPY . /var/www/html/

# Ensure upload directory exists and is writable
RUN mkdir -p /var/www/html/assets/images/uploads \
    && chown -R www-data:www-data /var/www/html \
    && chmod -R 775 /var/www/html/assets/images/uploads

# Configure Entrypoint
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE 80

ENTRYPOINT ["docker-entrypoint.sh"]

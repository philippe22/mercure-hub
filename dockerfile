# Étape 1 : PHP 8.2 Alpine pour Symfony
FROM php:8.2-fpm-alpine AS php

# Installer dépendances système et extensions PHP
RUN apk add --no-cache \
    bash \
    git \
    unzip \
    curl \
    icu-dev \
    libzip-dev \
    zlib-dev \
    libxml2-dev \
    autoconf \
    gcc \
    g++ \
    make \
    pkgconfig \
    shadow \
    && docker-php-ext-install intl pdo pdo_mysql zip opcache xml

# Installer Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Copier le code Symfony
WORKDIR /var/www/html
COPY . .

# Installer les dépendances PHP
# RUN composer install --no-dev --optimize-autoloader --prefer-dist --no-interaction
RUN composer install --no-dev --optimize-autoloader --prefer-dist -vvv

# Étape 2 : Télécharger Mercure
RUN curl -L https://github.com/dunglas/mercure/releases/download/v0.14.0/mercure_0.14.0_linux_amd64.tar.gz \
    | tar xz -C /usr/local/bin \
    && chmod +x /usr/local/bin/mercure

# Définir les variables d’environnement pour Mercure
ENV MERCURE_PUBLISH_ALLOWED_ORIGINS=*
ENV MERCURE_SUBSCRIBE_ALLOWED_ORIGINS=*
ENV JWT_KEY=!MaCleSecreteMercure!
ENV ADDR=0.0.0.0:80

# Exposer le port pour Render
EXPOSE 80

# Lancer Mercure et PHP-FPM ensemble
CMD sh -c "mercure run & php-fpm"

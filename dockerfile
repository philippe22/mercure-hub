# Étape 1 : Image PHP + extensions nécessaires pour Symfony
FROM php:8.2-fpm-alpine

# Installer les extensions et utilitaires
RUN apk add --no-cache \
    bash \
    git \
    unzip \
    curl \
    libzip-dev \
    icu-dev \
    oniguruma-dev \
    && docker-php-ext-install intl pdo pdo_mysql zip opcache

# Installer Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Copier le code Symfony
WORKDIR /var/www/html
COPY . .

# Installer les dépendances PHP
RUN composer install --no-dev --optimize-autoloader

# Étape 2 : Installer Mercure (Douglas v0.14)
FROM dunglas/mercure:v0.14.0 AS mercure

# Étape 3 : Image finale combinée
FROM php:8.2-fpm-alpine

# Copier Symfony
WORKDIR /var/www/html
COPY --from=0 /var/www/html /var/www/html

# Copier Mercure
COPY --from=mercure /mercure /usr/local/bin/mercure

# Définir les variables d’environnement pour Mercure
ENV MERCURE_PUBLISH_ALLOWED_ORIGINS=*
ENV MERCURE_SUBSCRIBE_ALLOWED_ORIGINS=*
ENV JWT_KEY=ChangeMoiParTaCleJWTSympa
ENV ADDR=0.0.0.0:80

# Exposer le port pour Render
EXPOSE 80

# Lancer Mercure en arrière-plan et PHP-FPM
CMD sh -c "mercure run & php-fpm"

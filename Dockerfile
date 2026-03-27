# ============================================================
# Dockerfile — Contratos IDAF/AC
# Base: PHP 8.1 + Apache
# ============================================================

FROM php:8.1-apache

# ── Dependências do sistema ──────────────────────────────────
RUN apt-get update && apt-get install -y \
        libzip-dev \
        zip \
        unzip \
        git \
        curl \
        python3 \
        python3-pip \
    && docker-php-ext-install \
        pdo \
        pdo_mysql \
        mbstring \
        fileinfo \
        zip \
    && pip3 install pdfplumber --break-system-packages \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# ── Apache: habilita mod_rewrite ────────────────────────────
RUN a2enmod rewrite

# Permite .htaccess sobrescrever configurações
RUN sed -i 's/AllowOverride None/AllowOverride All/g' \
        /etc/apache2/apache2.conf

# ── PHP: ajustes de upload e memória ────────────────────────
RUN printf "upload_max_filesize = 25M\n\
post_max_size = 25M\n\
memory_limit = 256M\n\
max_execution_time = 120\n" \
    > /usr/local/etc/php/conf.d/contratos.ini

# ── Composer ────────────────────────────────────────────────
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# ── Código da aplicação ──────────────────────────────────────
WORKDIR /var/www/html

COPY . .

# Instala dependências PHP (sem dev)
RUN composer install --no-dev --optimize-autoloader --no-interaction

# ── Permissões dos uploads ───────────────────────────────────
RUN mkdir -p uploads/pdfs uploads/imports \
    && chown -R www-data:www-data uploads \
    && chmod -R 775 uploads

EXPOSE 80

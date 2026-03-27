# ============================================================
# Dockerfile — Contratos IDAF/AC
# Base: PHP 8.1 + Apache (Debian Bullseye)
# ============================================================

FROM php:8.3-apache

# ── 1. Pacotes do sistema ─────────────────────────────────────
# libpng/libjpeg/libfreetype → necessários para ext-gd (phpspreadsheet)
RUN apt-get update && apt-get install -y --no-install-recommends \
        libzip-dev \
        libpng-dev \
        libjpeg62-turbo-dev \
        libfreetype6-dev \
        zip \
        unzip \
        git \
        curl \
        python3 \
        python3-pip \
        python3-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# ── 2. Extensões PHP ─────────────────────────────────────────
# gd: configura suporte a jpeg e freetype antes de compilar
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo pdo_mysql zip gd

# ── 3. Biblioteca Python para extração de PDF ────────────────
# --break-system-packages necessário no Debian Bookworm (PEP 668)
RUN pip3 install --no-cache-dir --break-system-packages pdfplumber

# ── 4. Apache: mod_rewrite + AllowOverride ───────────────────
RUN a2enmod rewrite \
    && sed -i 's/AllowOverride None/AllowOverride All/g' \
        /etc/apache2/apache2.conf

# ── 5. PHP: ajustes de upload e memória ──────────────────────
RUN printf "upload_max_filesize = 25M\npost_max_size = 25M\nmemory_limit = 256M\nmax_execution_time = 120\n" \
    > /usr/local/etc/php/conf.d/contratos.ini

# ── 6. Composer ──────────────────────────────────────────────
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# ── 7. Código da aplicação ───────────────────────────────────
WORKDIR /var/www/html

# Copia composer.json primeiro para aproveitar cache de dependências
COPY composer.json composer.lock ./
RUN composer install --no-dev --optimize-autoloader --no-interaction --no-scripts

# Copia o restante do projeto
COPY . .

# ── 8. Permissões dos uploads ────────────────────────────────
RUN mkdir -p uploads/pdfs uploads/imports \
    && chown -R www-data:www-data uploads \
    && chmod -R 775 uploads

EXPOSE 80

FROM php:8.3-fpm-bookworm
LABEL maintainer="mkraibt <mkraibt@gmail.com>"
# Install base OS packages and dependencies
RUN apt-get update && \
    apt-get -y install --no-install-recommends \
        apt-utils \
        g++ \
        gcc \
        git \
        bash-completion \
        curl \
        wget \
        mlocate \
        libmemcached-dev \
        imagemagick \
        libfreetype6-dev \
        libcurl4-openssl-dev \
        libicu-dev \
        libmcrypt-dev \
        libfreetype6-dev \
        libjpeg-dev \
        libmagickwand-dev \
        libmcrypt-dev \
        libpq-dev \
        libpng-dev \
        libzip-dev \
        zlib1g-dev \
        default-mysql-client \
        openssh-client \
        libxml2-dev \
        nano \
        linkchecker \
        vim \
        iputils-ping \
        ghostscript \
        percona-toolkit \
        nagios-nrpe-server \
        nagios-plugins \
        pdftk \
        rsync \
        s3cmd \
        libtidy-dev \
        libgearman-dev \
        libssh2-1-dev \
        netcat-traditional \
        inotify-tools \
        unzip \
        libssl-dev \
        build-essential && \
    # Setup Node.js LTS (22.x)
    curl -sL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get -y install nodejs && \
    # Clean up
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


# Update npm & Install Less Compiler and other globals
RUN npm -g install npm@latest && \
    npm install -g \
        less \
        lesshint \
        uglify-js \
        uglifycss

# Install LockRun
RUN cd /tmp && \
    curl -L https://raw.githubusercontent.com/pushcx/lockrun/master/lockrun.c \
        -o lockrun.c && \
    gcc lockrun.c -o lockrun && \
    cp lockrun /usr/local/bin/
# Install PHP extensions using mlocati installer (handles core and PECL)
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN chmod +x /usr/local/bin/install-php-extensions && \
    install-php-extensions \
        soap \
        zip \
        curl \
        bcmath \
        exif \
        gd \
        iconv \
        intl \
        opcache \
        pdo_mysql \
        pdo_pgsql \
        mysqli \
        pcntl \
        calendar \
        tidy \
        apcu \
        igbinary \
        msgpack \
        memcached \
        imagick \
        mailparse
    # Note: Gearman disabled - no PHP 8.3 support yet

# Install Composer (latest version)
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
    composer clear-cache

# Install Yii framework bash autocompletion
RUN curl -L https://raw.githubusercontent.com/yiisoft/yii2/master/contrib/completion/bash/yii \
         -o /etc/bash_completion.d/yii

# Install codeception
RUN curl -L https://codeception.com/codecept.phar \
         -o /usr/local/bin/codecept && \
    chmod +x /usr/local/bin/codecept

# Install psysh
RUN curl -L https://psysh.org/psysh \
         -o /usr/local/bin/psysh && \
    chmod +x /usr/local/bin/psysh

# Install Robo
RUN curl -L http://robo.li/robo.phar \
         -o /usr/local/bin/robo && \
    chmod +x /usr/local/bin/robo

# Copy Executable (entrypoint)
COPY setup/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod 700 /usr/local/bin/entrypoint.sh

# Switch to non-root user for security
USER www-data

# Override work directory
WORKDIR /app

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
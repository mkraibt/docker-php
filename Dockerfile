FROM mkraibt/php:8.1.23-fpm
MAINTAINER mkraibt <mkraibt@gmail.com>

#--------------------------------------------------------------------------
# Install base OS packages
#--------------------------------------------------------------------------
RUN pwd && \
    # Setup node
   curl -sL https://deb.nodesource.com/setup_18.x | bash - && \
    # Install packages
    apt-get update && \
    apt-get -y install \
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
            libcurl3-dev \
            libicu-dev \
            libmcrypt-dev \
            libfreetype6-dev \
            libjpeg-dev \
            libjpeg62-turbo-dev \
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
            nodejs \
            libtidy-dev \
            libgearman-dev \
            libssh2-1-dev \
            netcat-traditional \
            inotify-tools \
            unzip \
        --no-install-recommends

#--------------------------------------------------------------------------
# Clean up
#--------------------------------------------------------------------------
RUN apt-get clean

#--------------------------------------------------------------------------
# Update npm & Install Less Compiler
#--------------------------------------------------------------------------
RUN npm -g install npm@latest && \
    npm install -g \
        less \
        lesshint \
        uglify-js \
        uglifycss

#--------------------------------------------------------------------------
# Install LockRun
#--------------------------------------------------------------------------
RUN cd /tmp && \
    curl -L https://raw.githubusercontent.com/pushcx/lockrun/master/lockrun.c \
        -o lockrun.c && \
    gcc lockrun.c -o lockrun && \
    cp lockrun /usr/local/bin/


#--------------------------------------------------------------------------
# Install PHP extensions
#--------------------------------------------------------------------------
RUN docker-php-ext-configure gd \
        --with-freetype=/usr/include/ \
#        --with-png=/usr/include/ \
        --with-jpeg=/usr/include/ && \
    docker-php-ext-configure bcmath && \
    docker-php-ext-install \
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
            ssh2
    #gearman - disabled as it has no support in php 8.1 yet https://github.com/php/pecl-networking-gearman/issues/12

#--------------------------------------------------------------------------
# Install PECL extensions \
# see http://stackoverflow.com/a/8154466/291573) for usage of `printf`
#--------------------------------------------------------------------------
RUN printf "\n" | pecl install \
        apcu \
        memcached \
        imagick \
        mailparse && \
    docker-php-ext-enable \
        apcu \
        memcached \
        imagick \
        mailparse

#--------------------------------------------------------------------------
# Install composer
#--------------------------------------------------------------------------
COPY --from=composer:2.6.5 /usr/bin/composer /usr/local/bin/composer
RUN composer clear-cache

#--------------------------------------------------------------------------
# Install Yii framework bash autocompletion
#--------------------------------------------------------------------------
RUN curl -L https://raw.githubusercontent.com/yiisoft/yii2/master/contrib/completion/bash/yii \
         -o /etc/bash_completion.d/yii

#--------------------------------------------------------------------------
# Install codeception
#--------------------------------------------------------------------------
RUN curl -L https://codeception.com/codecept.phar \
         -o /usr/local/bin/codecept

#--------------------------------------------------------------------------
# Install psysh
#--------------------------------------------------------------------------
RUN curl -L https://psysh.org/psysh \
         -o /usr/local/bin/psysh

#--------------------------------------------------------------------------
# Install Robo
#--------------------------------------------------------------------------
RUN curl -L http://robo.li/robo.phar \
         -o /usr/local/bin/robo
#--------------------------------------------------------------------------
# Clean Up
#--------------------------------------------------------------------------
RUN apt-get -y autoremove && \
     apt-get clean && \
     rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#--------------------------------------------------------------------------
# Update
#--------------------------------------------------------------------------
RUN apt-get update

#--------------------------------------------------------------------------
# Override work directory from php:8.1.23-fpm
#--------------------------------------------------------------------------
WORKDIR /app

#--------------------------------------------------------------------------
# Copy Executable
#--------------------------------------------------------------------------
COPY  setup/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod 700 /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]



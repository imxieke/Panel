#!/usr/bin/env bash
###
 # @Author: Cloudflying
 # @Date: 2021-09-17 18:29:53
 # @LastEditTime: 2023-10-15 20:39:03
 # @LastEditors: Cloudflying
 # @Description: General-purpose scripting language
 #  			 Build PHP Source Code on Alpine Linux && Ubuntu && Debian
###

# export PATH="$PATH:/usr/local/boxs/php/56/bin:/usr/local/boxs/php/56/sbin"

. "$(dirname $(readlink -f $0))/../env.sh"

# CORES=$(grep -c '^processor' /proc/cpuinfo)
# ARCH=$(uname -m)
# ext_dir=$(php-config --extension-dir)
# ini_dir=$(php-config --ini-dir)
# ini_file=$(php --ini | grep '^Loaded Configuration File' | awk -F ' ' '{print $4}')
# php_two_bit_ver=$(php-config  --version | awk -F '.' '{print $1"."$2}')
# php_two_bit_ver=$(php -v | head -n 1 | awk -F ' ' '{print $2}' | awk -F '.' '{print $1"."$2}')

BOXS_PREFIX="/opt/boxs"

php_56()
{
    VER=$1
    PHP_VER=$(eval echo \$"PHP${VER}_VER")
    URL=${MIRRORS}"/php/php-${PHP_VER}.tar.gz"
    mkdir -p /tmp/.build && cd /tmp/.build
    echo "Fetch ${PHP_VER} Source Code"
    wget -c ${URL}  > /dev/null 2>&1 && tar -xvf php-${PHP_VER}.tar.gz > /dev/null 2>&1 && cd php-${PHP_VER}
    PREFIX_PHP=${PREFIX}/php/${VER}
    mkdir -p ${PREFIX_PHP}/{bin,sbin,etc,conf.d}

    ENABLE_OPENSSL=''
    if [[ -z "$(grep 'VERSION_ID="2' /etc/os-release)" ]]; then
        ENABLE_OPENSSL='--with-openssl'
    fi

    ./configure \
		--prefix=${PREFIX_PHP} \
		--bindir="${PREFIX_PHP}"/bin \
		--sbindir="${PREFIX_PHP}"/sbin \
		--with-config-file-path="${PREFIX_PHP}"/etc \
		--with-config-file-scan-dir="${PREFIX_PHP}"/conf.d \
		--with-fpm-user=www \
		--with-fpm-group=www \
		--enable-bcmath \
		--enable-calendar \
		--enable-exif \
		--enable-fpm \
		--enable-inline-optimization \
		--enable-mbregex \
		--enable-mbstring \
		--enable-mysqlnd \
		--enable-pcntl \
		--enable-shmop \
		--enable-soap \
		--enable-sockets \
		--enable-sysvsem \
		--enable-wddx \
		--enable-zip \
		--with-bz2 \
		--with-curl \
		--with-enchant \
		--with-gettext \
		--with-gmp \
		--with-iconv \
		--with-jpeg-dir \
		--with-libxml-dir \
		--with-libzip \
		--with-mcrypt \
		--with-mhash \
		--with-mysql=mysqlnd \
		--with-mysqli=mysqlnd \
		--with-kerberos \
		--with-pcre-jit \
		--with-pdo-mysql=mysqlnd \
		--with-pdo-pgsql \
		--with-pic \
		--with-pgsql \
		--with-png-dir \
		--with-recode \
		--with-readline \
		--with-regex \
		--with-tidy \
		--with-xmlrpc \
		--with-xsl \
		--with-zlib \
		--without-pear \
		--disable-fileinfo \
		--disable-rpath $ENABLE_OPENSSL
        make -j${CORES}
        make install
        cp php.ini* ${PREFIX_PHP}/etc/
        mv ${PREFIX_PHP}/etc/php-fpm.conf.default ${PREFIX_PHP}/etc/php-fpm.conf
        cp php.ini-development ${PREFIX_PHP}/etc/php.ini
        # 没什么卵用
        # --with-mssql
}

php_70()
{
    URL=${MIRRORS}"/php/php-${PHP70_VER}.tar.gz"
    mkdir -p /tmp/.build && cd /tmp/.build
    wget -c ${URL} > /dev/null 2>&1 && tar -xvf php-${PHP70_VER}.tar.gz > /dev/null 2>&1 && cd php-${PHP70_VER}
    PREFIX_PHP=${PREFIX}/php/70
    mkdir -p ${PREFIX_PHP}/{bin,sbin,etc,conf.d}
    ./configure --prefix=${PREFIX_PHP} \
		--bindir="${PREFIX_PHP}"/bin \
		--sbindir="${PREFIX_PHP}"/sbin \
		--with-config-file-path="${PREFIX_PHP}"/etc \
		--with-config-file-scan-dir="${PREFIX_PHP}"/conf.d \
		--with-fpm-user=www \
		--with-fpm-group=www \
		--enable-bcmath \
		--enable-calendar \
		--enable-exif \
		--enable-fpm \
		--enable-ftp \
		--enable-mbregex \
		--enable-mbstring \
		--enable-mysqlnd \
		--enable-pcntl \
		--enable-shmop \
		--enable-soap \
		--enable-sockets \
		--enable-sysvsem \
		--enable-wddx \
		--enable-zip \
		--with-bz2 \
		--with-curl \
		--with-enchant \
		--with-webp-dir \
		--with-jpeg-dir \
		--with-png-dir \
		--with-gettext \
		--with-gmp \
		--with-iconv \
		--with-libxml-dir \
		--with-libzip \
		--with-mcrypt \
		--with-mhash \
		--with-mysqli=mysqlnd \
		--with-openssl \
		--with-kerberos \
		--with-pdo-mysql=mysqlnd \
		--with-pdo-pgsql \
		--with-pic \
		--with-pgsql \
		--with-pspell \
		--with-png-dir \
		--with-recode \
		--with-readline \
		--with-tidy \
		--with-xmlrpc \
		--with-xsl \
		--with-zlib \
		--without-pear
        make -j${CORES}
        make install
        mv ${PREFIX_PHP}/etc/php-fpm.conf.default ${PREFIX_PHP}/etc/php-fpm.conf
        cp php.ini* ${PREFIX_PHP}/etc/
        cp php.ini-development ${PREFIX_PHP}/etc/php.ini
}

php_71()
{
    URL=${MIRRORS}"/php/php-${PHP71_VER}.tar.gz"
    mkdir -p /tmp/.build && cd /tmp/.build
    wget -c ${URL} > /dev/null 2>&1 && tar -xvf php-${PHP71_VER}.tar.gz > /dev/null 2>&1 && cd php-${PHP71_VER}
    PREFIX_PHP=${PREFIX}/php/71
    mkdir -p ${PREFIX_PHP}/{bin,sbin,etc,conf.d}
    ./configure --prefix=${PREFIX_PHP} --bindir="${PREFIX_PHP}"/bin --sbindir="${PREFIX_PHP}"/sbin --with-config-file-path="${PREFIX_PHP}"/etc --with-config-file-scan-dir="${PREFIX_PHP}"/conf.d --with-fpm-user=www --with-fpm-group=www --enable-bcmath --enable-calendar --enable-exif --enable-fpm --enable-ftp --enable-mbregex --enable-mbstring --enable-mysqlnd --enable-pcntl --enable-shmop --enable-soap --enable-sockets --enable-sysvsem --enable-wddx --enable-zip --with-bz2 --with-curl --with-enchant --with-webp-dir --with-jpeg-dir --with-png-dir --with-gettext --with-gmp --with-iconv --with-libxml-dir --with-libzip --with-mcrypt --with-mhash --with-mysqli=mysqlnd --with-openssl --with-kerberos --with-pdo-mysql=mysqlnd --with-pdo-pgsql --with-pic --with-pgsql --with-pspell --with-png-dir --with-recode --with-readline --with-tidy --with-xmlrpc --with-xsl --with-zlib --without-pear
        make -j${CORES}
        make install
        mv ${PREFIX_PHP}/etc/php-fpm.conf.default ${PREFIX_PHP}/etc/php-fpm.conf
        cp php.ini* ${PREFIX_PHP}/etc/
        cp php.ini-development ${PREFIX_PHP}/etc/php.ini
        # --enable-dmalloc \
}

php_72()
{
    VER=$1
    PHP_VER=$(eval echo \$"PHP${VER}_VER")
    URL=${MIRRORS}"/php/php-${PHP_VER}.tar.gz"
    mkdir -p /tmp/.build && cd /tmp/.build
    echo "Fetch ${PHP_VER} Source Code"
    wget -c ${URL}  > /dev/null 2>&1 && tar -xvf php-${PHP_VER}.tar.gz > /dev/null 2>&1 && cd php-${PHP_VER}
    PREFIX_PHP=${PREFIX}/php/${VER}
    mkdir -p ${PREFIX_PHP}/{bin,sbin,etc,conf.d}
    ./configure --prefix=${PREFIX_PHP} --bindir="${PREFIX_PHP}"/bin --sbindir="${PREFIX_PHP}"/sbin --with-config-file-path="${PREFIX_PHP}"/etc --with-config-file-scan-dir="${PREFIX_PHP}"/conf.d --with-fpm-user=www --with-fpm-group=www --enable-bcmath --enable-calendar --enable-exif --enable-fpm --enable-ftp --enable-mbregex --enable-mbstring --enable-mysqlnd --enable-pcntl --enable-shmop --enable-soap --enable-sockets --enable-sysvsem --enable-wddx --enable-zip --with-bz2 --with-curl --with-enchant --with-webp-dir --with-jpeg-dir --with-png-dir --with-gettext --with-gmp --with-iconv --with-libxml-dir --with-libzip --with-mhash --with-mysqli=mysqlnd --with-openssl --with-kerberos --with-pcre-jit --with-pdo-mysql=mysqlnd --with-pdo-pgsql --with-pic --with-pgsql --with-pspell --with-png-dir --with-recode --with-readline --with-sodium --with-tidy --with-xmlrpc --with-xsl --with-zlib --without-pear
        make -j${CORES}
        make install
        mv ${PREFIX_PHP}/etc/php-fpm.conf.default ${PREFIX_PHP}/etc/php-fpm.conf
        cp php.ini* ${PREFIX_PHP}/etc/
        cp php.ini-development ${PREFIX_PHP}/etc/php.ini
        # --enable-dmalloc \
}

php_73()
{
    VER=$1
    PHP_VER=$(eval echo \$"PHP${VER}_VER")
    URL=${MIRRORS}"/php/php-${PHP_VER}.tar.gz"
    mkdir -p /tmp/.build && cd /tmp/.build
    echo "Fetch ${PHP_VER} Source Code"
    wget -c ${URL}  > /dev/null 2>&1 && tar -xvf php-${PHP_VER}.tar.gz > /dev/null 2>&1 && cd php-${PHP_VER}
    PREFIX_PHP=${PREFIX}/php/${VER}
    mkdir -p ${PREFIX_PHP}/{bin,sbin,etc,conf.d}
    ./configure --prefix=${PREFIX_PHP} --bindir="${PREFIX_PHP}"/bin --sbindir="${PREFIX_PHP}"/sbin --with-config-file-path="${PREFIX_PHP}"/etc --with-config-file-scan-dir="${PREFIX_PHP}"/conf.d --with-fpm-user=www --with-fpm-group=www --enable-bcmath --enable-calendar --enable-exif --enable-fpm --enable-ftp --enable-mbregex --enable-mbstring --enable-mysqlnd --enable-pcntl --enable-shmop --enable-soap --enable-sockets --enable-sysvsem --enable-wddx --enable-zip --with-bz2 --with-curl --with-enchant --with-webp-dir --with-jpeg-dir --with-png-dir --with-gettext --with-gmp --with-iconv --with-libxml-dir --with-libzip --with-mhash --with-mysqli=mysqlnd --with-openssl --with-kerberos --with-pcre-jit --with-pdo-mysql=mysqlnd --with-pdo-pgsql --with-pic --with-pgsql --with-pspell --with-png-dir --with-recode --with-readline --with-sodium --with-tidy --with-xmlrpc --with-xsl --with-zlib --without-pear
        make -j${CORES}
        make install
        # mv ${PREFIX_PHP}/etc/php-fpm.conf.default ${PREFIX_PHP}/etc/php-fpm.conf
        cp php.ini* ${PREFIX_PHP}/etc/
        cp php.ini-development ${PREFIX_PHP}/etc/php.ini
        # --enable-dmalloc \
}

php_74()
{
    VER=$1
    PHP_VER=$(eval echo \$"PHP${VER}_VER")
    URL=${MIRRORS}"/php/php-${PHP_VER}.tar.gz"
    mkdir -p /tmp/.build && cd /tmp/.build
    echo "Fetch ${PHP_VER} Source Code"
    wget -c ${URL}  > /dev/null 2>&1 && tar -xvf php-${PHP_VER}.tar.gz > /dev/null 2>&1 && cd php-${PHP_VER}
    PREFIX_PHP=${PREFIX}/php/${VER}
    mkdir -p ${PREFIX_PHP}/{bin,sbin,etc,conf.d}
    ./configure \
		--prefix=${PREFIX_PHP} \
		--bindir="${PREFIX_PHP}"/bin \
		--sbindir="${PREFIX_PHP}"/sbin \
		--with-config-file-path="${PREFIX_PHP}"/etc \
		--with-config-file-scan-dir="${PREFIX_PHP}"/conf.d \
		--with-fpm-user=www \
		--with-fpm-group=www \
		--enable-bcmath \
		--enable-calendar \
		--enable-exif \
		--enable-fpm \
		--enable-ftp \
		--enable-mbregex \
		--enable-mbstring \
		--enable-mysqlnd \
		--enable-pcntl \
		--enable-shmop \
		--enable-soap \
		--enable-sockets \
		--enable-sysvsem \
		--with-bz2 \
		--with-curl \
		--with-enchant \
		--with-webp \
		--with-jpeg \
		--with-xpm \
		--with-png-dir \
		--with-gettext \
		--with-gmp \
		--with-iconv \
		--with-mhash \
		--with-mysqli=mysqlnd \
		--with-openssl \
		--with-kerberos \
		--with-pcre-jit \
		--with-pdo-mysql=mysqlnd \
		--with-pdo-pgsql \
		--with-pic \
		--with-pgsql \
		--with-pspell \
		--with-png-dir \
		--with-recode \
		--with-readline \
		--with-sodium \
		--with-tidy \
		--with-xmlrpc \
		--with-xsl \
		--with-zip \
		--with-zlib \
		--without-pear
        make -j${CORES}
        make install
        # mv ${PREFIX_PHP}/etc/php-fpm.conf.default ${PREFIX_PHP}/etc/php-fpm.conf
        cp php.ini* ${PREFIX_PHP}/etc/
        cp php.ini-development ${PREFIX_PHP}/etc/php.ini
        # --enable-dmalloc \
}

php_80()
{
    URL=${MIRRORS}"/php/php-${PHP80_VER}.tar.gz"
    mkdir -p /tmp/.build && cd /tmp/.build
    wget -c ${URL} > /dev/null 2>&1 && tar -xvf php-${PHP80_VER}.tar.gz > /dev/null 2>&1 && cd php-${PHP80_VER}
    PREFIX_PHP=${PREFIX}/php/80
    mkdir -p ${PREFIX_PHP}/{bin,sbin,etc,conf.d}
    ./configure \
		--prefix=${PREFIX_PHP} \
		--bindir="${PREFIX_PHP}"/bin \
		--sbindir="${PREFIX_PHP}"/sbin \
		--with-config-file-path="${PREFIX_PHP}"/etc \
		--with-config-file-scan-dir="${PREFIX_PHP}"/conf.d \
		--with-fpm-user=www \
		--with-fpm-group=www \
		--enable-bcmath \
		--enable-calendar \
		--enable-exif \
		--enable-fpm \
		--enable-ftp \
		--enable-mbregex \
		--enable-mbstring \
		--enable-mysqlnd \
		--enable-pcntl \
		--enable-shmop \
		--enable-soap \
		--enable-sockets \
		--enable-sysvsem \
		--with-bz2 \
		--with-curl \
		--with-enchant \
		--with-expat \
		--with-webp \
		--with-jpeg \
		--with-xpm \
		--with-gettext \
		--with-gmp \
		--with-iconv \
		--with-mhash \
		--with-mysqli=mysqlnd \
		--with-openssl \
		--with-kerberos \
		--with-pdo-mysql=mysqlnd \
		--with-pdo-pgsql \
		--with-pic \
		--with-pgsql \
		--with-pspell \
		--with-readline \
		--with-sodium \
		--with-tidy \
		--with-xsl \
		--with-zip \
		--with-zlib \
		--without-pear
        make -j${CORES}
        make install
        # mv ${PREFIX_PHP}/etc/php-fpm.conf.default ${PREFIX_PHP}/etc/php-fpm.conf
        cp php.ini* ${PREFIX_PHP}/etc/
        cp php.ini-development ${PREFIX_PHP}/etc/php.ini
        # --enable-dmalloc \
}

php_81()
{
    URL=${MIRRORS}"/php/php-${PHP81_VER}.tar.gz"
    mkdir -p /tmp/.build && cd /tmp/.build
    wget -c ${URL} > /dev/null 2>&1 && tar -xvf php-${PHP81_VER}.tar.gz > /dev/null 2>&1 && cd php-${PHP81_VER}
    PREFIX_PHP=${PREFIX}/php/81
    mkdir -p ${PREFIX_PHP}/{bin,sbin,etc,conf.d}
    ./configure --prefix=${PREFIX_PHP} \
	--bindir="${PREFIX_PHP}"/bin \
	--sbindir="${PREFIX_PHP}"/sbin \
	--with-config-file-path="${PREFIX_PHP}"/etc \
	--with-config-file-scan-dir="${PREFIX_PHP}"/conf.d \
	--with-fpm-user=www \
	--with-fpm-group=www \
	--enable-bcmath \
	--enable-calendar \
	--enable-exif \
	--enable-fpm \
	--enable-ftp \
	--enable-mbregex \
	--enable-mbstring \
	--enable-mysqlnd \
	--enable-pcntl \
	--enable-shmop \
	--enable-soap \
	--enable-sockets \
	--enable-sysvsem \
	--with-bz2 \
	--with-curl \
	--with-enchant \
	--with-expat \
	--with-webp \
	--with-jpeg \
	--with-xpm \
	--with-gettext \
	--with-gmp \
	--with-iconv \
	--with-mhash \
	--with-mysqli=mysqlnd \
	--with-openssl \
	--with-kerberos \
	--with-pdo-mysql=mysqlnd \
	--with-pdo-pgsql \
	--with-pic \
	--with-pgsql \
	--with-pspell \
	--with-readline \
	--with-sodium \
	--with-tidy \
	--with-xsl \
	--with-zip \
	--with-zlib \
	--without-pear
        make -j${CORES}
        make install
        # mv ${PREFIX_PHP}/etc/php-fpm.conf.default ${PREFIX_PHP}/etc/php-fpm.conf
        cp php.ini* ${PREFIX_PHP}/etc/
        cp php.ini-development ${PREFIX_PHP}/etc/php.ini
        # --enable-dmalloc \
        # --with-avif 手动编译依赖
}

# php 5.6 安装在 Ubuntu 16.04 否则很多依赖需要手动编译
_deps()
{
    # libbz2-dev  libwebp-dev  libtidy-dev libmagic-dev libjpeg-dev libvpx-dev libxpm-dev libharfbuzz-dev libbrotli-dev zlib1g-dev libldap2-dev
    # libbison-dev libxpm-dev
    if [[ "${VERSION_ID_SHORT}" == '16' ]]; then
        spt libfreetype6-dev libpng12-dev libenchant-dev > /dev/null 2>&1
    elif [[ "${VERSION_ID_SHORT}" == '20' ]]; then
        spt libfreetype6-dev libpng-dev libenchant-dev > /dev/null 2>&1
    elif [[ "${VERSION_ID_SHORT}" == '21' ]]; then
        spt libfreetype-dev libpng-dev libenchant-2-dev > /dev/null 2>&1
    fi

    # php5
    # 似乎并用不到
    # libmsgpack-dev
    apt install --no-install-recommends -y librecode-dev libmcrypt-dev

    # imap libc-client2007e-dev libkrb5-dev
    apt install --no-install-recommends -y libtidy-dev libssl-dev libsnmp-dev libldap-dev libc-client2007e-dev libkrb5-dev \
        libpspell-dev libpq-dev libxml2-dev libsodium-dev libxslt1-dev libzip-dev
    # php 7+
    # oniguruma libonig-dev
    # amqp librabbitmq-dev
    # event libevent-dev
    # gmagick libgraphicsmagick1-dev
    # gnupg libgpgme-dev
    # imagick libmagickwand-dev
    # leveldb libleveldb-dev
    # mssql sqlsrv unixodbc-dev freetds-dev
    # libzookeeper-st-dev
    apt install --no-install-recommends -y librabbitmq-dev libevent-dev libgraphicsmagick1-dev libgpgme-dev libmagickwand-dev \
        libleveldb-dev libmcrypt-dev libmemcached-dev unixodbc-dev librdkafka-dev libsmbclient-dev libssh2-1-dev libyaml-dev \
        libzookeeper-mt-dev libffi-dev libonig-dev

    # Compile PHP 8.1
    apt install --no-install-recommends -y libsqlite3-dev libcurl4-openssl-dev libreadline-dev libgmp-dev
}

# exts :
# Precompile
# ioncube
# third-party
# pear ZendGuardLoader xcache phalcon
# php source ext
# imap ldap
# recode not incompatible
# record < 7.4
# gd gmagick opcache
# pkcs11 0.1 7.0.0 - 8.0.99
# pkcs11 1.0 >= 7.4.0
# igbinary 3 >= 7
# igbinary 2 >= 5
# leveldb 0.3 >= 7
# leveldb 0.15 >= 5.2
# msgpack 2.1.0 >= 7
# msgpack 2.0.3 >= 7
# msgpack 0.5.7 >= 5
# mecache 3.0.8 >= 5
# memcached 2.x >= 5.2 - 5.6
# memcached 3.x >= 7.0 - 7.4
# mongodb 1.7.5 >= 5 最后一个支持 5 的版本
# protobuf 3.12.4 >=5
# libsodium 似乎和 php 源码自带的 sodium 冲突
# simple_kafka_client Ubuntu 21.10
# has build from php source zip
# grpc 文件过大
# php 5.6 不支持 sqlsrv 使用 mssql 代替

php_exts()
{
    mkdir -p /tmp/.build/exts && cd /tmp/.build/exts

    ver=$1
    full_version=$(eval echo \$$"PHP${ver}_VER")
    php_src_path="/tmp/.build/php-${full_version}/ext/"

    ext_url=${MIRRORS}/php-exts/
    ext_dir=$(/usr/local/boxs/php/${ver}/bin/php-config --extension-dir)
    ioncube_path="/tmp/.build/exts/ioncube"
    ioncube_file="ioncube_loader_lin_${ver:0:1}.${ver:1:2}.so"

    if [[ ! -f "${ext_dir}/$ioncube_file" ]]; then
        echo '==>ioncube installing'

        if [[ ! -d "$ioncube_path" ]]; then
            wget -c "${MIRRORS}/php-exts/ioncube/ioncube_loaders_lin_x86-64.tar.gz"
            tar -xvf ioncube_loaders_lin_x86-64.tar.gz > /dev/null
        fi

        if [[ -f "${ioncube_path}/$ioncube_file" ]]; then
            cp "${ioncube_path}/$ioncube_file" "${ext_dir}/ioncube.so"
            echo "zend_extension=ioncube.so" > /usr/local/boxs/php/${ver}/conf.d/ioncube.ini
        else
            echo "php version ${ver} is not supported"
        fi
    fi

    # 通用扩展
    exts='amqp crypto ev event gnupg hprose igbinary imagick leveldb msgpack memcache memcached mongodb protobuf rar rdkafka redis scrypt stomp smbclient ssh2 yac yaf swoole xhprof xdebug yaml zookeeper zstd'
    if [[ "$ver" == 74 ]]; then
        exts="${exts} pkcs11 mcrypt pdo_sqlsrv sqlsrv yaconf"
    elif [[ "$ver" == 73 ]]; then
        PHP_EXT_PKCS11_VER=0.1
        exts="${exts} mcrypt pdo_sqlsrv sqlsrv yaconf"
    elif [[ "$ver" == 56 ]]; then
        exts="${exts}"
        PHP_EXT_IGBINARY_VER=2.0.8
        PHP_EXT_LEVELDB_VER=0.1.5
        PHP_EXT_MSGPACK_VER=0.5.7
        PHP_EXT_MEMCACHE_VER=3.0.8
        PHP_EXT_MEMCACHED_VER=2.2.0RC1
        PHP_EXT_MONGODB_VER=1.7.5
        PHP_EXT_PROTOBUF_VER=3.12.4
        PHP_EXT_SQLSRV_VER=3.0.1
        PHP_EXT_PDO_SQLSRV_VER=3.0.1
        PHP_EXT_RDKAFKA_VER=4.1.2
        PHP_EXT_REDIS_VER=4.3.0
        PHP_EXT_STOMP_VER=1.0.9
        PHP_EXT_SWOOLE_VER=2.0.11
        PHP_EXT_XHPROF_VER=0.9.4
        PHP_EXT_XDEBUG_VER=2.5.5
        PHP_EXT_ZOOKEEPER_VER=0.5.0
        PHP_EXT_YAC_VER=0.9.2
        PHP_EXT_YAML_VER=1.3.1
        PHP_EXT_SSH2_VER=0.13
        PHP_EXT_YAF_VER=2.3.5
    fi
    for ext in ${exts}; do
        ext_ver=$(eval echo \$"PHP_EXT_$(strtoupper $ext)_VER")
        echo "Fetch ${ext} Source Code"
        if [[ ! -f "${ext}/${ext}-${ext_ver}.tgz" ]]; then
            wget -cq http://mirrors.xieke.org/Src/php-exts/${ext}/${ext}-${ext_ver}.tgz
        fi
        echo "DeCompress ${ext} Source Code"
        if [[ ! -d "${ext}-${ext_ver}" ]]; then
            tar -xvf ${ext}-${ext_ver}.tgz >> /dev/null
        fi
        echo "Start Compile ${ext}"
        build_ext ${ext}-${ext_ver} $ver $ext
    done

    # 版本可用或高版本被弃用
    # 系统自带扩展
    # no-config need
    # snmp PHP 5 会查找 snmp 配置文件 不建议安装
    sys_exts='sysvshm sysvmsg  ldap opcache gd'
    if [[ "$ver" == 74 ]]; then
        sys_exts="${sys_exts} ffi intl snmp"
    elif [[ "$ver" == 73 ]]; then
        sys_exts="${sys_exts} intl snmp"
    elif [[ "$ver" == 72 ]]; then
        sys_exts="${sys_exts} intl snmp"
        ln -s /usr/include/freetype2/* /usr/include/ > /dev/null 2>&1
    elif [[ "$ver" == 56 ]]; then
        sys_exts="${sys_exts} pspell openssl mssql ftp"
    fi

    if [[ ! -d "$php_src_path" ]]; then
        cd /tmp/.build/
        wget "${MIRRORS}/php/php-${full_version}.tar.gz"
        tar -xvf php-${full_version}.tar.gz -C /tmp/.build/
    fi

    cd $php_src_path
    for ext in ${sys_exts}; do
        echo "Build extension ${ext} "
        if [ "$ver" == 56 ] && [ "$ext" == 'intl' ];then
             build_ext $ext $ver $ext  '--with-icu-dir=/opt/icu55'
        else
            build_ext $ext $ver $ext  $params
        fi
    done
    exit
    # manual config need
    # imap
    build_ext "${php_src_path}/imap" $ver imap '--with-kerberos --with-imap-ssl'
}

php_82()
{
    ./configure \
        --prefix=/opt/boxs-php/82 \
        --sysconfdir=/opt/boxs-php/82/etc/conf.d \
        --with-config-file-path=/opt/boxs-php/82/etc/conf.d \
        --with-config-file-scan-dir=/opt/boxs-php/82/etc/conf.d \
        --disable-pear \
        --enable-bcmath \
        --enable-calendar \
        --enable-dba \
        --enable-exif \
        --enable-ftp \
        --enable-fpm \
        --enable-gd \
        --enable-intl \
        --enable-mbregex \
        --enable-mbstring \
        --enable-mysqlnd \
        --enable-pcntl \
        --enable-phpdbg \
        --enable-phpdbg-readline \
        --enable-shmop \
        --enable-soap \
        --enable-sockets \
        --enable-sysvmsg \
        --enable-sysvsem \
        --enable-sysvshm \
        --with-apxs2 \
        --with-bz2 \
        --with-curl \
        --with-external-gd \
        --with-external-pcre \
        --with-ffi \
        --with-fpm-user=www \
        --with-fpm-group=www \
        --with-gettext \
        --with-gmp \
        --with-iconv \
        --with-kerberos \
        --with-layout=GNU \
        --with-ldap= \
        --with-libxml \
        --with-libedit \
        --with-mhash \
        --with-mysql-sock=/tmp/mysql.sock \
        --with-mysqli=mysqlnd \
        --with-ndbm \
        --with-openssl \
        --with-password-argon2 \
        --with-pdo-dblib \
        --with-pdo-mysql=mysqlnd \
        --with-pdo-odbc \
        --with-pdo-pgsql \
        --with-pdo-sqlite \
        --with-pgsql \
        --with-pic \
        --with-pspell \
        --with-sodium \
        --with-sqlite3 \
        --with-tidy \
        --with-unixODBC \
        --with-xsl \
        --with-zip \
        --with-zlib
}

php_83()
{
	adduser -u 82 -D -S -G www www
	mkdir -p /etc/php/83/conf.d
	gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)"
	export PHP_CFLAGS="-fstack-protector-strong -fpic -fpie -O2 -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64"
	export PHP_CPPFLAGS="$PHP_CFLAGS"
	export PHP_LDFLAGS="-Wl,-O1 -pie"

	apk add --no-cache --virtual .deps
		autoconf \
		bison \
		curl \
		dpkg-dev dpkg \
		file \
		g++ \
		gcc \
		libc-dev \
		make \
		pkgconf \
		tar \
		re2c \
		xz \
		argon2-dev \
		coreutils \
		curl-dev \
        gd-dev \
        gmp-dev \
        imap-dev \
        icu-dev \
		gnu-libiconv-dev \
		libsodium-dev \
		libxml2-dev \
		linux-headers \
		oniguruma-dev \
		openssl-dev \
		readline-dev \
		sqlite-dev \
        openldap-dev \
        freetds-dev \
        unixodbc-dev \
        tidyhtml-dev \
        krb5-dev \
        pcre2-dev \
        bzip2-dev \
        libzip-dev \
        libxslt-dev \
        libffi-dev \
        enchant2-dev \

	./configure \
		--with-config-file-path="/etc/php/83" \
		--with-config-file-scan-dir="/etc/php/83/conf.d" \
		--disable-cgi \
		--enable-bcmath \
		--enable-calendar \
		--enable-dba \
		--enable-dba \
		--enable-exif \
		--enable-fpm \
		--enable-ftp \
		--enable-gd \
		--enable-intl \
		--enable-mbstring \
		--enable-mysqlnd \
		--enable-phpdbg \
		--enable-phpdbg-readline \
		--enable-pcntl \
		--enable-shmop \
		--enable-soap \
		--enable-sockets \
		--enable-sysvmsg \
		--enable-sysvsem \
		--enable-sysvshm \
		--with-bz2 \
		--with-curl \
		--with-enchant \
		--with-ffi \
		--with-avif \
		--with-webp \
		--with-jpeg \
		--with-xpm \
		--with-freetype \
		--with-gettext \
		--with-mhash \
		--with-gmp \
		--with-pic \
		--with-password-argon2 \
		--with-sodium=shared \
		--with-pdo-sqlite=/usr \
		--with-pdo-dblib \
		--with-pdo-mysql \
		--with-pdo-pgsql \
		--with-pgsql \
		--with-sqlite3=/usr \
		--with-iconv=/usr \
		--with-imap \
		--with-imap-ssl \
		--with-ldap \
		--with-mysqli \
		--with-snmp \
		--with-tidy \
		--with-unixODBC \
		--with-openssl \
		--with-kerberos \
		--with-system-ciphers \
		--with-external-libcrypt \
		--with-password-argon2 \
		--with-external-pcre \
		--with-readline \
		--with-xsl \
		--with-zip \
		--with-pic \
		--with-zlib \
		--with-fpm-user=www \
		--with-fpm-group=www

	make -j "$(nproc)"
	# make install

	# apk del --no-network .deps;
	# Conflict
# --with-pdo-oci \
# --with-oci8 \
}

build_ext()
{
    dir=$1
    ver=$2
    ext=$3
    params=$4
    if [[ ! -d $dir ]]; then
        echo "${ext} directory not found"
        exit 1
    fi

    ext_dir=$(/usr/local/boxs/php/${ver}/bin/php-config --extension-dir)
    if [[ ! -f "${ext_dir}/$ext.so" ]]; then
        if [[ "${ext}" == 'xhprof' ]]; then
            cd ${dir}/extension
        else
            cd $dir
        fi
        echo "Build extension ${ext}"
        pwd
        /usr/local/boxs/php/${ver}/bin/phpize
        ./configure --with-php-config=/usr/local/boxs/php/${ver}/bin/php-config $params
        make -j${CORES} && make install
    
        # 编译后没有编译产物则编译失败
        if [[ -f "${ext_dir}/$ext.so" ]]; then
            if [[ "$ext" == 'opcache' ]] || [[ "$ext" == 'xdebug' ]]; then
                echo "zend_extension=${ext}.so" > /usr/local/boxs/php/${ver}/conf.d/${ext}.ini
            else
                echo "extension=${ext}.so" > /usr/local/boxs/php/${ver}/conf.d/${ext}.ini
            fi
        else
            echo "$ext build fail"
            exit 1
        fi
        cd ..
    else
        echo "$ext already compile"
    fi
}

VER=$1
case $VER in
    56|70|71|72|73|74|80|81|82|83|84 )
        php_$VER $VER
        ;;
    exts )
        case $2 in
            56|70|71|72|73|74|80|81|82|83|84)
                # php_${2}_exts $2
                php_exts $2
                ;;
            *)
                echo "Unknow php version $2"
                ;;
        esac
        ;;
    * )
        echo 'unknown php version: ' $VER
        ;;
esac
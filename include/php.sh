#!/usr/bin/env bash
###
# @Author: Cloudflying
# @Date: 2021-09-17 18:29:53
# @LastEditTime: 2024-04-27 10:03:42
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

# php 5.6 安装在 Ubuntu 16.04 否则很多依赖需要手动编译
_deps() {
  # libbz2-dev libvpx-dev libxpm-dev libharfbuzz-dev
  if [[ "${VERSION_ID_SHORT}" == '16' ]]; then
    spt libfreetype6-dev libpng12-dev libenchant-dev >/dev/null 2>&1
  elif [[ "${VERSION_ID_SHORT}" == '20' ]]; then
    spt libfreetype6-dev libpng-dev libenchant-dev >/dev/null 2>&1
  elif [[ "${VERSION_ID_SHORT}" == '21' ]]; then
    spt libfreetype-dev libpng-dev libenchant-2-dev >/dev/null 2>&1
  fi
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

php_exts() {
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
      tar -xvf ioncube_loaders_lin_x86-64.tar.gz >/dev/null
    fi

    if [[ -f "${ioncube_path}/$ioncube_file" ]]; then
      cp "${ioncube_path}/$ioncube_file" "${ext_dir}/ioncube.so"
      echo "zend_extension=ioncube.so" >/usr/local/boxs/php/${ver}/conf.d/ioncube.ini
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
      tar -xvf ${ext}-${ext_ver}.tgz >>/dev/null
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
    ln -s /usr/include/freetype2/* /usr/include/ >/dev/null 2>&1
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
    if [ "$ver" == 56 ] && [ "$ext" == 'intl' ]; then
      build_ext $ext $ver $ext '--with-icu-dir=/opt/icu55'
    else
      build_ext $ext $ver $ext $params
    fi
  done
  exit
  # manual config need
  # imap
  build_ext "${php_src_path}/imap" $ver imap '--with-kerberos --with-imap-ssl'
}

build_ext() {
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
        echo "zend_extension=${ext}.so" >/usr/local/boxs/php/${ver}/conf.d/${ext}.ini
      else
        echo "extension=${ext}.so" >/usr/local/boxs/php/${ver}/conf.d/${ext}.ini
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
56 | 70 | 71 | 72 | 73 | 74 | 80 | 81 | 82 | 83 | 84)
  php_$VER $VER
  ;;
exts)
  case $2 in
  56 | 70 | 71 | 72 | 73 | 74 | 80 | 81 | 82 | 83 | 84)
    # php_${2}_exts $2
    php_exts $2
    ;;
  *)
    echo "Unknow php version $2"
    ;;
  esac
  ;;
*)
  echo 'unknown php version: ' $VER
  ;;
esac

#!/usr/bin/env bash
## Boxs Env

export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export DEBIAN_FRONTEND=noninteractive

ROOT_PATH=$(dirname $(dirname $(realpath $0)))

APP_DEBUG=true
# Packages version

# export MIRRORS='https://mirrors.xie.ke/Src/php'
# export MIRRORS='http://mirrors.xieke.org/Src/'
export MIRRORS='https://hk.mirrors.xieke.org/Src/'
export PREFIX='/usr/local/boxs'

export TIMEZONE='Asia/Shanghai'

# 设置安装版本
export PHP56_VER=5.6.40
export PHP70_VER=7.0.33
export PHP71_VER=7.1.30
export PHP72_VER=7.2.34
export PHP73_VER=7.3.33
export PHP74_VER=7.4.33
export PHP80_VER='8.0.30'
export PHP81_VER='8.1.31'
export PHP82_VER='8.2.26'
export PHP83_VER='8.3.14'
export PHP84_VER='8.4.1'
export PHP85_VER='8.5.0-dev'

export PHP56_DL_URL="https://github.com/php/php-src/archive/refs/tags/php-${PHP56_VER}.tar.gz"
export PHP70_DL_URL="https://github.com/php/php-src/archive/refs/tags/php-${PHP70_VER}.tar.gz"
export PHP71_DL_URL="https://github.com/php/php-src/archive/refs/tags/php-${PHP71_VER}.tar.gz"
export PHP72_DL_URL="https://github.com/php/php-src/archive/refs/tags/php-${PHP72_VER}.tar.gz"
export PHP73_DL_URL="https://github.com/php/php-src/archive/refs/tags/php-${PHP73_VER}.tar.gz"
export PHP74_DL_URL="https://github.com/php/php-src/archive/refs/tags/php-${PHP74_VER}.tar.gz"

export PHP80_DL_URL="https://github.com/php/php-src/archive/refs/tags/php-${PHP80_VER}.tar.gz"
export PHP81_DL_URL="https://github.com/php/php-src/archive/refs/tags/php-${PHP81_VER}.tar.gz"
export PHP82_DL_URL="https://github.com/php/php-src/archive/refs/tags/php-${PHP82_VER}.tar.gz"
export PHP83_DL_URL="https://github.com/php/php-src/archive/refs/tags/php-${PHP83_VER}.tar.gz"
export PHP84_DL_URL="https://github.com/php/php-src/archive/refs/tags/php-${PHP84_VER}.tar.gz"

# https://github.com/php/php-src/blob/master/main/php_version.h
export PHP85_DL_URL="https://github.com/php/php-src/archive/2b80b2e5ecb2c4e769790d43f13b977a18cb61ac.tar.gz"

export NGINX_VER=1.21.3
export REDIS_VER=6.2.5
export MEMCACHED_VER=1.6.12

export MYSQL56_VER=5.6.51
export MYSQL57_VER=5.7.34
export MYSQL80_VER=8.0.25

export MARIADB55=5.5.68
export MARIADB101=10.1.48
export MARIADB102=10.2.38
export MARIADB103=10.3.29
export MARIADB104=10.4.19

# export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:/usr/lib/x86_64-linux-gnu/pkgconfig"
# export AVIF_CFLAGS='/usr/lib/x86_64-linux-gnu'

# Ubuntu 14.04 及以下版本不适用
export CORES=$(grep -c '^processor' /proc/cpuinfo)
export CODENAME=$(cat /etc/os-release | grep '^VERSION_CODENAME' | awk -F '=' '{print $2}')
export VERSION_ID_SHORT=$(grep 'VERSION_ID' /etc/os-release | awk -F '"' '{print $2}' | awk -F '.' '{print $1}')

# 修复 PHP7.3 及以下版本依赖 freetype-config
# if [[ -z "$(command -v freetype-config)" ]]; then
# export FREETYPE2_DIR='/bin/freetype-config'
# export FREETYPE2_CONFIG='pkg-config freetype2'
# fi

_env()
{
  [ "$(id -u)" != 0 ] && echo 'super user please' && exit 1
  if [[ ! -f /etc/environment ]]; then
    echo 'PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games"' >/etc/environment
    echo "LC_ALL=en_US.UTF-8" >>/etc/environment
  else
    [ -z "$(grep "en_US\.UTF-8" /etc/environment)" ] && echo "LC_ALL=en_US.UTF-8" >>/etc/environment
  fi

  if [[ ! -f /etc/environment ]]; then
    echo "en_US.UTF-8 UTF-8" >/etc/locale.gen
  else
    [ -z "$(grep "en_US\.UTF-8" /etc/locale.gen)" ] && echo "en_US.UTF-8 UTF-8" >>/etc/locale.gen
  fi

  if [[ ! -f /etc/locale.conf ]]; then
    echo "LANG=en_US.UTF-8" >/etc/locale.conf
  else
    [ -z "$(grep 'LANG' /etc/locale.conf)" ] && echo "LANG=en_US.UTF-8" >>/etc/locale.conf
  fi

  # export LANG='en_US.UTF-8';
  # export LC_ALL='en_US.UTF-8';

  # [ -n "$(grep 'LANG' /etc/locale.conf )" ] && locale-gen en_US.UTF-8 >> /dev/null

  MEMORY=$(free -m | grep '^Mem' | awk -F ' ' '{print $2}')
  SWAP=$(free -m | grep '^Swap' | awk -F ' ' '{print $2}')

}

_red()
{
  printf '\033[1;31;31m%b\033[0m' "$1"
}

_green()
{
  printf '\033[1;31;32m%b\033[0m' "$1"
}

_yellow()
{
  printf '\033[1;31;33m%b\033[0m' "$1"
}

# 输出红色文字
_rmsg()
{
  _red "$1"
  printf "\n"
}

# 输出绿色文字
_gmsg()
{
  _green "$1"
  printf "\n"
}

# 输出黄色文字
_ymsg()
{
  _yellow "$1"
  printf "\n"
}

_info()
{
  _green "[Info] "
  printf -- "%s" "$1"
  printf "\n"
}

_warn()
{
  _yellow "[Warning] "
  printf -- "%s" "$1"
  printf "\n"
}

_error()
{
  _red "[Error] "
  printf -- "%s" "$1"
  printf "\n"
  exit 1
}

_usage()
{
  clear
  # 命令行顶部展示的数据
  echo "
    +----------------------------------------------------------------------
    | 		$(_gmsg 'Boxs Env') For Ubuntu
    +----------------------------------------------------------------------
    | Script Only for Ubuntu
    +----------------------------------------------------------------------
    | Copyright © 2015-2021 Cloudflying All rights reserved.
    +----------------------------------------------------------------------
    "

  echo -e "
$(_ymsg Usage:)
  $(_gmsg install)       Install env
  $(_gmsg remove)        remove installed env package
  $(_gmsg ext)           php extension install
  $(_gmsg help)          this help
"

}

# 安装完成展示的内容
_install_success_msg()
{
  echo -e "=================================================================="
  echo -e "	\033[32mCongratulations! Installed successfully!\033[0m"
  echo -e "=================================================================="
  echo "	url: http://ip:8888"
  echo -e "	username: cloudflying"
  echo -e "	password: 123456"
  echo -e "\033[33mWarning:\033[0m"
  echo -e "\033[33mIf you cannot access the panel, \033[0m"
  echo -e "\033[33mrelease the following port (20|21|443|80|8888) in the security group\033[0m"
  echo -e "=================================================================="
}

spt()
{
  apt install --no-install-recommends -y $*
}

_depency()
{
  # groupadd www && useradd -g www -M -s /sbin/nologin www
  # groupadd --system www  > /dev/null 2>&1
  # useradd --system --gid www www  > /dev/null 2>&1
  [ -z "$(ls /var/lib/apt/lists | grep 'ubuntu_dists')" ] && apt update -y
  [ -z "$(command -v less)" ] && spt less
  [ -z "$(command -v make)" ] && spt wget curl ca-certificates make gcc g++ autoconf automake locales pkg-config

  # for pkg in ${PKGS} ; do
  # 	if [[ -z $(dpkg -l | awk -F ' ' '{print $2}' | grep -v '^Name$' | grep -v '^Err?' | grep -v '^Status=' | grep "^${pkg}$") ]]; then
  # 		echo "Package: " ${pkg} "Not Install !"
  # 		echo "=> Install " ${pkg}
  # 		spt ${pkg}
  # 	fi
  # done
}
# _depency

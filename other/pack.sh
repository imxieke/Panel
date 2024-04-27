#!/usr/bin/env bash
###
 # @Author: Cloudflying
 # @Date: 2021-11-11 16:22:57
 # @LastEditTime: 2021-11-13 11:40:34
 # @LastEditors: Cloudflying
 # @Description: 
 # @FilePath: /Panel/pack.sh
###

. "$(dirname $(readlink -f $0))/env.sh"

cd "$(dirname $(readlink -f $0))/"
mkdir -p pack && cd pack

ARCH=$(uname -m)
OS_NAME=$(grep '^ID=' /etc/os-release | awk -F '=' '{print $2}')
OS_ID=$(grep '^VERSION_ID=' /etc/os-release | awk -F '=' '{print $2}' | awk -F '"' '{print $2}')

_pack_backup()
{
	if [[ -f /usr/local/boxs/redis/bin/redis-cli ]]; then
		REDIS_VER=$(/usr/local/boxs/redis/bin/redis-cli --version | awk -F ' ' '{print $2}')
		tar -zcvf redis-${REDIS_VER}-${OS_NAME}-${OS_ID}-${ARCH}.tar.gz /usr/local/boxs/redis
	fi

	if [[ -f /usr/local/boxs/nginx/sbin/nginx ]]; then
		NGINX_VER=$(/usr/local/boxs/nginx/sbin/nginx -v 2>&1 | awk -F '/' '{print $2}')
		tar -zcvf nginx-${NGINX_VER}-${OS_NAME}-${OS_ID}-${ARCH}.tar.gz /usr/local/boxs/nginx
	fi

	if [[ -f /usr/local/boxs/memcached/bin/memcached ]]; then
		MEMCACHED_VER=$(/usr/local/boxs/memcached/bin/memcached --version 2>&1 | awk -F ' ' '{print $2}')
		tar -zcvf memcached-${MEMCACHED_VER}-${OS_NAME}-${OS_ID}-${ARCH}.tar.gz /usr/local/boxs/memcached
	fi

	for phpver in 56 70 71 72 73 74 80 81; do
		echo $phpver
		if [[ -f "/usr/local/boxs/php/${phpver}/bin/php" ]]; then
			php_full_ver=$(/usr/local/boxs/php/${phpver}/bin/php-config --version)
			tar -zcvf php-${php_full_ver}-${OS_NAME}-${OS_ID}-${ARCH}.tar.gz /usr/local/boxs/php/${phpver}/
		fi
	done
}

_pack_restore()
{
	for pkg in nginx redis memcached; do
		PKG_NAME=$(strtoupper "${pkg}")
		PKG_VER=$(eval echo \$$(strtoupper "${pkg}_VER"))
		if [[ ! -d "/usr/local/boxs/${pkg}" ]]; then
			if [[ -f "${pkg}-${PKG_VER}-${OS_NAME}-${OS_ID}-${ARCH}.tar.gz" ]]; then
				echo "==> restore ${pkg}"
				tar -zxvf ${pkg}-${PKG_VER}-${OS_NAME}-${OS_ID}-${ARCH}.tar.gz -C / > /dev/null
			fi
		fi
	done

	# for phpver in 56 70 71 72 73 74 80 81; do
	for phpver in 56 74 80 81; do
		PKG_VER=$(eval echo \$$(strtoupper "PHP${phpver}_VER"))
		if [[ ! -f "/usr/local/boxs/php/${phpver}/bin/php" ]]; then
			if [[ -f "php-${PKG_VER}-${OS_NAME}-${OS_ID}-${ARCH}.tar.gz" ]]; then
				echo "==> restore php $phpver"
				tar -zxvf php-${PKG_VER}-${OS_NAME}-${OS_ID}-${ARCH}.tar.gz -C / > /dev/null
			fi
		fi
	done
}

case $1 in
	restore )
		_pack_restore
		;;
	backup )
		_pack_backup
		;;
	* )
		echo 'Usage: backup|restore'
		;;
esac
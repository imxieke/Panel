#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

Install_gmp()
{
	if [ ! -f "/www/server/php/$version/bin/php-config" ];then
		echo "php-$vphp 未安装,请选择其它版本!"
		echo "php-$vphp not install, Plese select other version!"
		return
	fi
	
	isInstall=`cat /www/server/php/$version/etc/php.ini|grep 'gmp.so'`
	if [ "${isInstall}" != "" ];then
		echo "php-$vphp 已安装过gmp,请选择其它版本!"
		echo "php-$vphp is installed gmp, Plese select other version!"
		return
	fi
	
	public_file=/www/server/panel/install/public.sh
	if [ ! -f $public_file ];then
		wget -O $public_file http://download.bt.cn/install/public.sh -T 5;
	fi
	. $public_file
	download_Url=$NODE_URL

	if [ "${PM}" == "yum" ] || [ "${PM}" == "dnf" ];then
		Pack="gmp gmp-devel"
		${PM} install ${Pack} -y
	elif [ "${PM}" == "apt-get" ];then
		Pack="libgmp3-dev"
		${PM} install ${Pack} -y
		if [ -f "/usr/include/x86_64-linux-gnu/gmp.h" ];then
			ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/include/gmp.h
		fi
	fi
	
	if [ ! -d "/www/server/php/$version/src/ext/gmp" ];then
		mkdir -p /www/server/php/$version/src
		wget -O $version-ext.tar.gz $download_Url/install/ext/$version-ext.tar.gz
		tar -zxf $version-ext.tar.gz -C /www/server/php/$version/src/ 
		rm -f $version-ext.tar.gz
	fi
	
	case "${version}" in 
		'52')
		extFile="/www/server/php/52/lib/php/extensions/no-debug-non-zts-20060613/gmp.so"
		;;
		'53')
		extFile="/www/server/php/53/lib/php/extensions/no-debug-non-zts-20090626/gmp.so"
		;;
		'54')
		extFile="/www/server/php/54/lib/php/extensions/no-debug-non-zts-20100525/gmp.so"
		;;
		'55')
		extFile="/www/server/php/55/lib/php/extensions/no-debug-non-zts-20121212/gmp.so"
		;;
		'56')
		extFile="/www/server/php/56/lib/php/extensions/no-debug-non-zts-20131226/gmp.so"
		;;
		'70')
		extFile="/www/server/php/70/lib/php/extensions/no-debug-non-zts-20151012/gmp.so"
		;;
		'71')
		extFile="/www/server/php/71/lib/php/extensions/no-debug-non-zts-20160303/gmp.so"
		;;
		'72')
		extFile="/www/server/php/72/lib/php/extensions/no-debug-non-zts-20170718/gmp.so"
		;;
		'73')
		extFile='/www/server/php/73/lib/php/extensions/no-debug-non-zts-20180731/gmp.so'
		;;
		'74')
		extFile='/www/server/php/74/lib/php/extensions/no-debug-non-zts-20190902/gmp.so'
		;;
	esac
	
	if [ ! -f "${extFile}" ];then
		cd /www/server/php/$version/src/ext/gmp
		/www/server/php/$version/bin/phpize
		./configure --with-php-config=/www/server/php/$version/bin/php-config
		make && make install
	fi
	
	if [ ! -f "${extFile}" ];then
		echo 'error';
		exit 0;
	fi

	echo -e "extension = " ${extFile} >> /www/server/php/$version/etc/php.ini
	service php-fpm-$version reload
	echo '==============================================='
	echo 'successful!'
}

Uninstall_gmp()
{
	if [ ! -f "/www/server/php/$version/bin/php-config" ];then
		echo "php-$vphp 未安装,请选择其它版本!"
		echo "php-$vphp not install, Plese select other version!"
		return
	fi
	
	isInstall=`cat /www/server/php/$version/etc/php.ini|grep 'gmp.so'`
	if [ "${isInstall}" = "" ];then
		echo "php-$vphp 未安装gmp,请选择其它版本!"
		echo "php-$vphp not install gmp, Plese select other version!"
		return
	fi

	sed -i '/gmp.so/d' /www/server/php/$version/etc/php.ini

	service php-fpm-$version reload
	echo '==============================================='
	echo 'successful!'
}

actionType=$1
version=$2
vphp=${version:0:1}.${version:1:1}
if [ "$actionType" == 'install' ];then
	Install_gmp
elif [ "$actionType" == 'uninstall' ];then
	Uninstall_gmp
fi

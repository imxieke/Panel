#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
Install_xdebug()
{
	if [ ! -f "/www/server/php/$version/bin/php-config" ];then
		echo "php-$vphp 未安装,请选择其它版本!"
		echo "php-$vphp not install, Plese select other version!"
		exit 0
	fi
	
	isInstall=`cat /www/server/php/$version/etc/php.ini|grep 'xdebug.so'`
	if [ "${isInstall}" != "" ];then
		echo "php-$vphp 已安装过xdebug,请选择其它版本!"
		echo "php-$vphp not install, Plese select other version!"
		exit 0
	fi
	
	case "${version}" in 
		'52')
		extFile='/www/server/php/52/lib/php/extensions/no-debug-non-zts-20060613/xdebug.so'
		;;
		'53')
		extFile='/www/server/php/53/lib/php/extensions/no-debug-non-zts-20090626/xdebug.so'
		;;
		'54')
		extFile='/www/server/php/54/lib/php/extensions/no-debug-non-zts-20100525/xdebug.so'
		;;
		'55')
		extFile='/www/server/php/55/lib/php/extensions/no-debug-non-zts-20121212/xdebug.so'
		;;
		'56')
		extFile='/www/server/php/56/lib/php/extensions/no-debug-non-zts-20131226/xdebug.so'
		;;
		'70')
		extFile='/www/server/php/70/lib/php/extensions/no-debug-non-zts-20151012/xdebug.so'
		;;
		'71')
		extFile='/www/server/php/71/lib/php/extensions/no-debug-non-zts-20160303/xdebug.so'
		;;
		'72')
		extFile='/www/server/php/72/lib/php/extensions/no-debug-non-zts-20170718/xdebug.so'
		;;
		'73')
		extFile='/www/server/php/73/lib/php/extensions/no-debug-non-zts-20180731/xdebug.so'
		;;
		'74')
		extFile='/www/server/php/74/lib/php/extensions/no-debug-non-zts-20190902/xdebug.so'
		;;
	esac
	if [ ! -f "$extFile" ];then
		
		public_file=/www/server/panel/install/public.sh
		if [ ! -f $public_file ];then
			wget -O $public_file http://download.bt.cn/install/public.sh -T 5;
		fi
		. $public_file

		download_Url=$NODE_URL
		
		if [ "$version" -ge '70' ];then
			wget -c -O xdebug-2.8.0.tgz $download_Url/src/xdebug-2.8.0.tgz -T 5
			tar zxvf xdebug-2.8.0.tgz
			rm -f xdebug-2.8.0.tgz
			cd xdebug-2.8.0
		else
			wget -c -O xdebug-2.2.7.tgz $download_Url/install/src/xdebug-2.2.7.tgz -T 5
			tar zxvf xdebug-2.2.7.tgz
			rm -f xdebug-2.2.7.tgz
			cd xdebug-2.2.7
		fi
		/www/server/php/$version/bin/phpize
		./configure  --with-php-config=/www/server/php/$version/bin/php-config
		make && make install
		cd ..
		rm -rf xdebug-*
	fi
	if [ ! -f "$extFile" ];then
		echo '安装失败!';
		exit 0
	fi
	
	
	echo "zend_extension=$extFile" >> /www/server/php/$version/etc/php.ini
	service php-fpm-$version reload
	echo '==========================================================='
	echo 'successful!'
	
	rm -f *.zip
	rm -f *.tar.gz
	rm -f *.tgz
	
}

Uninstall_xdebug()
{
	if [ ! -f "/www/server/php/$version/bin/php-config" ];then
		echo "php-$vphp 未安装,请选择其它版本!"
		return
	fi
	isInstall=`cat /www/server/php/$version/etc/php.ini|grep 'xdebug.so'`
	if [ "${isInstall}" == "" ];then
		echo "php-$vphp 未安装xdebug,请选择其它版本!"
		return
	fi
	
	sed -i '/xdebug/d'  /www/server/php/$version/etc/php.ini
	service php-fpm-$version reload
	echo '==============================================='
	echo 'successful!'
}

actionType=$1
version=$2
vphp=${version:0:1}.${version:1:1}

if [ "$actionType" == 'install' ];then
	Install_xdebug
elif [ "$actionType" == 'uninstall' ];then
	Uninstall_xdebug
fi

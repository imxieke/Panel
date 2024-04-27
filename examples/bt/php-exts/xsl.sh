#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

Install_Xsl()
{
	public_file=/www/server/panel/install/public.sh
	if [ ! -f $public_file ];then
		wget -O $public_file http://download.bt.cn/install/public.sh -T 5;
	fi
	. $public_file

	download_Url=$NODE_URL
	
	isInstall=`cat /www/server/php/$version/etc/php.ini|grep 'xsl.so'`
	if [ "${isInstall}" != "" ];then
		echo "php-$vphp 已安装xsl,请选择其它版本!"
		return
	fi
	
	if [ ! -d "/www/server/php/$version/src/ext/xsl" ];then
		mkdir -p /www/server/php/$version/src
		wget -O ext-$version.zip $download_Url/install/ext/ext-$version.zip
		unzip -o ext-$version.zip -d /www/server/php/$version/src/ > /dev/null
		mv /www/server/php/$version/src/ext-$version /www/server/php/$version/src/ext
		rm -f ext-$version.zip
	fi
	
	case "${version}" in
		'53')
		extFile='/www/server/php/53/lib/php/extensions/no-debug-non-zts-20090626/xsl.so'
		;;
		'54')
		extFile='/www/server/php/54/lib/php/extensions/no-debug-non-zts-20100525/xsl.so'
		;;
		'55')
		extFile='/www/server/php/55/lib/php/extensions/no-debug-non-zts-20121212/xsl.so'
		;;
		'56')
		extFile='/www/server/php/56/lib/php/extensions/no-debug-non-zts-20131226/xsl.so'
		;;
		'70')
		extFile='/www/server/php/70/lib/php/extensions/no-debug-non-zts-20151012/xsl.so'
		;;
		'71')
		extFile='/www/server/php/71/lib/php/extensions/no-debug-non-zts-20160303/xsl.so'
		;;
		'72')
		extFile='/www/server/php/72/lib/php/extensions/no-debug-non-zts-20170718/xsl.so'
		;;
		'73')
		extFile='/www/server/php/73/lib/php/extensions/no-debug-non-zts-20180731/xsl.so'
		;;
		'74')
		extFile='/www/server/php/74/lib/php/extensions/no-debug-non-zts-20190902/xsl.so'
		;;

	esac
	
	
	if [ ! -f "$extFile" ];then
		cd /www/server/php/$version/src/ext/xsl
		/www/server/php/$version/bin/phpize
		./configure --with-php-config=/www/server/php/$version/bin/php-config
		make && make install
	fi
	
	if [ ! -f "${extFile}" ];then
		echo "ERROR!"
		return;
	fi
	
	echo "extension=$extFile" >> /www/server/php/$version/etc/php.ini
	service php-fpm-$version reload
	echo '==========================================================='
	echo 'successful!'
}


Uninstall_Xsl()
{
	if [ ! -f "/www/server/php/$version/bin/php-config" ];then
		echo "php-$vphp 未安装,请选择其它版本!"
		return
	fi
	isInstall=`cat /www/server/php/$version/etc/php.ini|grep 'xsl.so'`
	if [ "${isInstall}" == "" ];then
		echo "php-$vphp 未安装xsl,请选择其它版本!"
		return
	fi
	
	sed -i '/xsl.so/d'  /www/server/php/$version/etc/php.ini
	service php-fpm-$version reload
	echo '==============================================='
	echo 'successful!'
}


actionType=$1
version=$2
vphp=${version:0:1}.${version:1:1}
if [ "$actionType" == 'install' ];then
	Install_Xsl
elif [ "$actionType" == 'uninstall' ];then
	Uninstall_Xsl
fi

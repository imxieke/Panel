#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
LANG=en_US.UTF-8
runPath="/root"

os_bit=$(getconf LONG_BIT)
is_arm=$(uname -a|grep -E 'aarch64|arm|ARM')

if [ "$os_bit" = "32" ] || [ "$is_arm" != "" ];then
        echo "========================================="
        echo "错误: 不支持32位和ARM/AARCH64平台的系统!"
        echo "========================================="
        exit 0;
fi


extFile(){
	case "${version}" in 
		'54')
		extFile='/www/server/php/54/lib/php/extensions/no-debug-non-zts-20100525/bt_safe.so'
		;;
		'55')
		extFile='/www/server/php/55/lib/php/extensions/no-debug-non-zts-20121212/bt_safe.so'
		;;
		'56')
		extFile='/www/server/php/56/lib/php/extensions/no-debug-non-zts-20131226/bt_safe.so'
		;;
		'70')
		extFile='/www/server/php/70/lib/php/extensions/no-debug-non-zts-20151012/bt_safe.so'
		;;
		'71')
		extFile='/www/server/php/71/lib/php/extensions/no-debug-non-zts-20160303/bt_safe.so'
		;;
		'72')
		extFile='/www/server/php/72/lib/php/extensions/no-debug-non-zts-20170718/bt_safe.so'
		;;
		'73')
		extFile='/www/server/php/73/lib/php/extensions/no-debug-non-zts-20180731/bt_safe.so'
		;;
		'74')
		extFile='/www/server/php/74/lib/php/extensions/no-debug-non-zts-20190902/bt_safe.so'
		;;
		'80')
		extFile='/www/server/php/80/lib/php/extensions/no-debug-non-zts-20200930/bt_safe.so'
		;;
	esac;
}
Install_btsafe()
{
	extFile
	
	isInstall=`cat /www/server/php/$version/etc/php.ini|grep ${extFile}`
	if [ "${isInstall}" != "" ];then
		echo "php-$vphp 已安装btsafe,请选择其它版本!"
		return
	fi

	if [ ! -f "$extFile" ];then
		public_file=/www/server/panel/install/public.sh
		if [ ! -f $public_file ];then
			wget -O $public_file http://download.bt.cn/install/public.sh -T 5;
		fi
		. $public_file

		download_Url=$NODE_URL
		
		case "${version}" in 
			'54')
			mkdir -p /www/server/php/54/lib/php/extensions/no-debug-non-zts-20100525/
			;;
			'55')
			mkdir -p /www/server/php/55/lib/php/extensions/no-debug-non-zts-20121212/
			;;
			'56')
			mkdir -p /www/server/php/56/lib/php/extensions/no-debug-non-zts-20131226/
			;;
			'70')
			mkdir -p /www/server/php/70/lib/php/extensions/no-debug-non-zts-20151012/
			;;
			'71')
			mkdir -p /www/server/php/71/lib/php/extensions/no-debug-non-zts-20160303/
			;;
			'72')
			mkdir -p /www/server/php/72/lib/php/extensions/no-debug-non-zts-20170718/
			;;
			'73')
			mkdir -p /www/server/php/73/lib/php/extensions/no-debug-non-zts-20180731/
			;;
			'74')
			mkdir -p /www/server/php/74/lib/php/extensions/no-debug-non-zts-20190902/
			;;
			'80')
			mkdir -p /www/server/php/80/lib/php/extensions/no-debug-non-zts-20200930/
			;;
		esac;
		wget -O ${extFile} http://download.bt.cn/install/plugin/php_safe/modules/bt_safe_${version}.so

	fi

	if [ ! -f "$extFile" ];then
		echo "ERROR!"
		return;
	fi

	echo "[bt_safe]" >> /www/server/php/$version/etc/php.ini
	echo "extension=$extFile" >> /www/server/php/$version/etc/php.ini
	echo "bt_safe.enable = 1" >> /www/server/php/$version/etc/php.ini
	service php-fpm-$version reload
	echo '==========================================================='
	echo 'successful!'

}
Uninstall_btsafe()
{
	if [ ! -f "/www/server/php/$version/bin/php-config" ];then
		echo "php-$vphp 未安装,请选择其它版本!"
		return;
	fi

	extFile

	if [ ! -f "$extFile" ];then
		echo "php-$vphp 未安装bt_safe,请选择其它版本!"
		return
	fi

	sed -i '/bt_safe/d'  /www/server/php/$version/etc/php.ini
		
	rm -f $extFile
	/etc/init.d/php-fpm-$version reload
	echo '==============================================='
	echo 'successful!'
}
actionType=$1
version=$2
vphp=${version:0:1}.${version:1:1}
if [ "$actionType" == 'install' ];then
	Install_btsafe
elif [ "$actionType" == 'uninstall' ];then
	Uninstall_btsafe
fi


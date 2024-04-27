#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
os_bit=$(getconf LONG_BIT)
is_arm=$(uname -a|grep -E 'aarch64|arm|ARM')

if [ "$os_bit" = "32" ] || [ "$is_arm" != "" ];then
	echo "========================================="
	echo "错误: 不支持32位和ARM/AARCH64平台的系统!"
	echo "========================================="
	exit 0;
fi

install_tmp='/tmp/bt_install.pl'
public_file=/www/server/panel/install/public.sh
if [ ! -f $public_file ];then
	wget -O $public_file http://download.bt.cn/install/public.sh -T 5;
fi
. $public_file

download_Url=$NODE_URL
pluginPath=/www/server/panel/plugin/php_filter
extFile=""
version=""


Ext_Path(){
	case "${version}" in 
		'53')
		extFile='/www/server/php/53/lib/php/extensions/no-debug-non-zts-20090626'
		;;
		'54')
		extFile='/www/server/php/54/lib/php/extensions/no-debug-non-zts-20100525'
		;;
		'55')
		extFile='/www/server/php/55/lib/php/extensions/no-debug-non-zts-20121212'
		;;
		'56')
		extFile='/www/server/php/56/lib/php/extensions/no-debug-non-zts-20131226'
		;;
		'70')
		extFile='/www/server/php/70/lib/php/extensions/no-debug-non-zts-20151012'
		;;
		'71')
		extFile='/www/server/php/71/lib/php/extensions/no-debug-non-zts-20160303'
		;;
		'71')
		extFile='/www/server/php/71/lib/php/extensions/no-debug-non-zts-20160303'
		;;
		'72')
		extFile='/www/server/php/72/lib/php/extensions/no-debug-non-zts-20170718'
		;;
		'73')
		extFile='/www/server/php/73/lib/php/extensions/no-debug-non-zts-20180731'
		;;
		'74')
		extFile='/www/server/php/74/lib/php/extensions/no-debug-non-zts-20190902'
		;;
	esac

	if [ ! -d $extFile ];then
		mkdir -p $extFile
	fi

	extFile=${extFile}/bt_filter.so

}

Install_php_filter()
{
	mkdir -p $pluginPath
	mkdir -p $pluginPath/config
	mkdir -p $pluginPath/total

	echo '正在安装脚本文件...' > $install_tmp
	wget -O $pluginPath/php_filter_main.so $download_Url/install/plugin/php_filter/php_filter_main.so -T 5
	wget -O $pluginPath/php_filter_main.cpython-36m-x86_64-linux-gnu.so $download_Url/install/plugin/php_filter/php_filter_main.cpython-36m-x86_64-linux-gnu.so -T 5
	wget -O $pluginPath/php_filter_main.cpython-37m-x86_64-linux-gnu.so $download_Url/install/plugin/php_filter/php_filter_main.cpython-37m-x86_64-linux-gnu.so -T 5

	echo > $pluginPath/php_filter_main.py
	wget -O $pluginPath/index.html $download_Url/install/plugin/php_filter/index.html -T 5
	wget -O $pluginPath/info.json $download_Url/install/plugin/php_filter/info.json -T 5

	if [ ! -f $pluginPath/config.json ];then
		wget -O $pluginPath/config.json $download_Url/install/plugin/php_filter/config.json -T 5
	fi

	if [ ! -f $pluginPath/rule.json ];then
		wget -O $pluginPath/user.json $download_Url/install/plugin/php_filter/rule.json -T 5
	fi
	
	wget -O $pluginPath/icon.png $download_Url/install/plugin/php_filter/icon.png -T 5
	php_versions="53 54 55 56 70 71 72 73 74"
	for i in $php_versions then
	do
		version=$i
		if [ -f /www/server/php/$version/bin/php ];then
			Ext_Path
			if [ $extFile != "" ];then
				wget -O ${extFile}.tmp $download_Url/install/plugin/php_filter/modules/bt_filter_${version}.so -T 5
				f_size=$(du -b ${extFile}.tmp|awk '{print $1}')
				echo "size: $f_size"
				if [ $f_size -gt 8192 ];then
					if [ -f ${extFile} ];then
						rm -f ${extFile}
					fi
					mv -f ${extFile}.tmp ${extFile}
					/etc/init.d/php-fpm-${version} start &> /dev/null
					/etc/init.d/php-fpm-${version} restart
				else
					rm -f ${extFile}.tmp
				fi
			fi
		fi
	done
	echo > /www/server/panel/data/reload.pl
	echo '安装完成' > $install_tmp
}


Uninstall_php_filter()
{
	rm -rf $pluginPath
}


action=$1
if [ "${1}" == 'install' ];then
	Install_php_filter
else
	Uninstall_php_filter
fi

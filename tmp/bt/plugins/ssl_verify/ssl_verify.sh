#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
pluginPath=/www/server/panel/plugin/ssl_verify
public_file=/www/server/panel/install/public.sh
if [ ! -f $public_file ];then
	wget -O $public_file https://node.aapanel.com/install/public.sh --no-check-certificate -T 5;
fi
. $public_file
download_Url=$NODE_URL

install_ssl_v()
{

	mkdir -p $pluginPath
	echo > /www/server/panel/plugin/ssl_verify/ssl_verify_main.py
	wget -O /www/server/panel/plugin/ssl_verify/ssl_verify.zip $download_Url/install/plugin/ssl_verify/ssl_verify.zip --no-check-certificate -T 5
	cd $pluginPath
	unzip -o ssl_verify.zip
	rm -f ssl_verify.zip
#	/usr/bin/pip install requests prettytable
	\cp -a -r /www/server/panel/plugin/ssl_verify/icon.png /www/server/panel/BTPanel/static/img/soft_ico/ico-ssl_verify.png
	echo 'Successify'
}

uninstall_ssl_v()
{
	rm -rf $pluginPath
	echo 'Successify'
}

if [ "${1}" == 'install' ];then
	install_ssl_v
	echo > /www/server/panel/data/restart.pl
elif [ "${1}" == 'uninstall' ];then
	uninstall_ssl_v
	echo > /www/server/panel/data/restart.pl
fi

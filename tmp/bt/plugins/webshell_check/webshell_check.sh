#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
install_tmp='/tmp/bt_install.pl'
public_file=/www/server/panel/install/public.sh

if [ ! -f $public_file ];then
	wget -O $public_file http://download.bt.cn/install/public.sh -T 5;
fi
. $public_file
download_Url=$NODE_URL
Install_webhook()
{
	echo '正在安装脚本文件...' > $install_tmp
	mkdir /www/server/panel/plugin/webshell_check
	wget -O /www/server/panel/plugin/webshell_check/index.html $download_Url/install/plugin/webshell_check/index.html -T 5
	wget -O /www/server/panel/plugin/webshell_check/info.json $download_Url/install/plugin/webshell_check/info.json -T 5
	wget -O /www/server/panel/plugin/webshell_check/icon.png $download_Url/install/plugin/webshell_check/icon.png -T 5
	wget -O /www/server/panel/plugin/webshell_check/webshell_check_main.py $download_Url/install/plugin/webshell_check/webshell_check_main.py -T 5
}

Uninstall_webhook()
{
	rm -rf /www/server/panel/plugin/webshell_check
}

action=$1
if [ "${1}" == 'install' ];then
	Install_webhook
else
	Uninstall_webhook
fi

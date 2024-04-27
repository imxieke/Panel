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
pluginPath=/www/server/panel/plugin/bt_ssh_auth


Install_clear()
{
	mkdir -p $pluginPath
	echo 'Installing script file...' > $install_tmp
    wget -O $pluginPath/bt_ssh_auth_main.py $download_Url/install/plugin/bt_ssh_auth/bt_ssh_auth_main.py -T 5
    wget -O $pluginPath/index.html $download_Url/install/plugin/bt_ssh_auth/index.html -T 5
    wget -O $pluginPath/info.json $download_Url/install/plugin/bt_ssh_auth/info.json -T 5
    wget -O $pluginPath/icon.png $download_Url/install/plugin/bt_ssh_auth/icon.png -T 5
	\cp -a -r /www/server/panel/plugin/bt_ssh_auth/icon.png /www/server/panel/BTPanel/static/img/soft_ico/ico-bt_ssh_auth.png
	echo '安装完成' > $install_tmp
}

Uninstall_clear()
{
	rm -rf $pluginPath
}

if [ "${1}" == 'install' ];then
	Install_clear
elif  [ "${1}" == 'update' ];then
	Install_clear
elif [ "${1}" == 'uninstall' ];then
	Uninstall_clear
fi

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
pluginPath=/www/server/panel/plugin/users
aacher=$(uname -a |grep -Po aarch64|awk 'NR==1')
Install_users()
{
	mkdir -p $pluginPath
	echo '正在安装脚本文件...' > $install_tmp
	if [ "$aacher" == "aarch64" ];then 
		wget -O $pluginPath/users_main.so $download_Url/install/plugin/users/aachar64/users_main.so -T 5
		wget -O $pluginPath/users_main.cpython-36m-aarch64-linux-gnu.so $download_Url/install/plugin/users/aachar64/users_main.cpython-36m-aarch64-linux-gnu.so -T 5
		wget -O $pluginPath/users_main.cpython-37m-aarch64-linux-gnu.so $download_Url/install/plugin/users/aachar64/users_main.cpython-37m-aarch64-linux-gnu.so -T 5
	else
		wget -O $pluginPath/users_main.so $download_Url/install/plugin/users/users_main.so -T 5
		wget -O $pluginPath/users_main.cpython-34m.so $download_Url/install/plugin/users/users_main.cpython-34m.so -T 5
		wget -O $pluginPath/users_main.cpython-36m-x86_64-linux-gnu.so $download_Url/install/plugin/users/users_main.cpython-36m-x86_64-linux-gnu.so -T 5
		wget -O $pluginPath/users_main.cpython-37m-x86_64-linux-gnu.so $download_Url/install/plugin/users/users_main.cpython-37m-x86_64-linux-gnu.so -T 5
	fi
	wget -O $pluginPath/info.json $download_Url/install/plugin/users/info.json -T 5	
	echo > $pluginPath/users_main.py
	wget -O $pluginPath/index.html $download_Url/install/plugin/users/index.html -T 5	
	wget -O $pluginPath/icon.png $download_Url/install/plugin/users/icon.png -T 5
	chmod -R 600 $pluginPath
	echo > /www/server/panel/data/reload.pl
	echo '安装完成' > $install_tmp
}

Uninstall_users()
{
	rm -rf $pluginPath
	rm -f $initSh
}


action=$1
if [ "${1}" == 'install' ];then
	Install_users
else
	Uninstall_users
fi

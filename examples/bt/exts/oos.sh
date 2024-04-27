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
pluginPath=/www/server/panel/plugin/oos

Install_oos()
{
	mkdir -p $pluginPath
	mkdir -p $pluginPath/arranges
	mkdir -p $pluginPath/server

	echo '正在安装脚本文件...' > $install_tmp
	wget -O $pluginPath/oos_main.so $download_Url/install/plugin/oos/oos_main.so -T 5
	wget -O $pluginPath/oos_main.cpython-37m-x86_64-linux-gnu.so $download_Url/install/plugin/oos/oos_main.cpython-37m-x86_64-linux-gnu.so -T 5
	wget -O $pluginPath/oos_main.cpython-36m-x86_64-linux-gnu.so $download_Url/install/plugin/oos/oos_main.cpython-36m-x86_64-linux-gnu.so -T 5
	wget -O $pluginPath/oos_server.so $download_Url/install/plugin/oos/oos_server.so -T 5
	wget -O $pluginPath/oos_server.cpython-37m-x86_64-linux-gnu.so $download_Url/install/plugin/oos/oos_server.cpython-37m-x86_64-linux-gnu.so -T 5
	wget -O $pluginPath/oos_server.cpython-36m-x86_64-linux-gnu.so $download_Url/install/plugin/oos/oos_server.cpython-36m-x86_64-linux-gnu.so -T 5
	wget -O $pluginPath/BT-OOS $download_Url/install/plugin/oos/BT-OOS -T 5
	echo > $pluginPath/oos_main.py
	wget -O $pluginPath/index.html $download_Url/install/plugin/oos/index.html -T 5
	wget -O $pluginPath/info.json $download_Url/install/plugin/oos/info.json -T 5

	if [ ! -f $pluginPath/arranges/list.json ];then
		wget -O $pluginPath/arranges/list.json $download_Url/install/plugin/oos/arranges/list.json -T 5
	fi
	if [ ! -f $pluginPath/arranges/type.json ];then
		wget -O $pluginPath/arranges/type.json $download_Url/install/plugin/oos/arranges/type.json -T 5
	fi

	if [ ! -d $pluginPath/triggers ];then
		wget -O $pluginPath/triggers.zip $download_Url/install/plugin/oos/triggers.zip -T 5
		unzip -o $pluginPath/triggers.zip -d $pluginPath/
		rm -f $pluginPath/triggers.zip
	fi

	if [ ! -d $pluginPath/scripts ];then
		wget -O $pluginPath/scripts.zip $download_Url/install/plugin/oos/scripts.zip -T 5
		unzip -o $pluginPath/scripts.zip -d $pluginPath/
		rm -f $pluginPath/scripts.zip
	fi
	
	wget -O $pluginPath/icon.png $download_Url/install/plugin/oos/icon.png -T 5

	initSh=/etc/init.d/BT-OOS
	wget -O $initSh $download_Url/install/plugin/oos/init.sh -T 5
	chmod +x $initSh
	if [ -f "/usr/bin/apt-get" ];then
		sudo update-rc.d BT-OOS defaults
	else
		chkconfig --add BT-OOS
		chkconfig --level 2345 BT-OOS on
	fi
	$initSh stop
	$initSh start
	chmod -R 600 $pluginPath
	chmod 700 $pluginPath/BT-OOS
	echo > /www/server/panel/data/reload.pl
	echo '安装完成' > $install_tmp
}

Uninstall_oos()
{
	initSh=/etc/init.d/BT-OOS
	$initSh stop
	chkconfig --del BT-OOS
	rm -rf $pluginPath
	rm -f $initSh
}


action=$1
if [ "${1}" == 'install' ];then
	Install_oos
else
	Uninstall_oos
fi

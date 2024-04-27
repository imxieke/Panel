#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
install_tmp='/tmp/bt_install.pl'
pluginPath=/www/server/panel/plugin/nfs_tools

public_file=/www/server/panel/install/public.sh
if [ ! -f $public_file ];then
	wget -O $public_file http://download.bt.cn/install/public.sh -T 5;
fi
. $public_file

download_Url=$NODE_URL

initSh=/etc/init.d/bt_nfs_mount

Install_nfs_tools()
{
	echo 'install..'
	mkdir -p $pluginPath/config
	
	install_nfs_server
	echo > $pluginPath/nfs_tools_main.py
	wget -O $pluginPath/nfs_tools_main.so $download_Url/install/plugin/nfs_tools/nfs_tools_main.so -T 5
	wget -O $pluginPath/nfs_tools_main.cpython-36m-x86_64-linux-gnu.so $download_Url/install/plugin/nfs_tools/nfs_tools_main.cpython-36m-x86_64-linux-gnu.so -T 5
	wget -O $pluginPath/nfs_tools_main.cpython-37m-x86_64-linux-gnu.so $download_Url/install/plugin/nfs_tools/nfs_tools_main.cpython-37m-x86_64-linux-gnu.so -T 5
	wget -O /www/server/panel/plugin/nfs_tools/index.html $download_Url/install/plugin/nfs_tools/index.html -T 5
	wget -O /www/server/panel/plugin/nfs_tools/BT-NFS-MOUNT $download_Url/install/plugin/nfs_tools/BT-NFS-MOUNT -T 5
	wget -O /www/server/panel/plugin/nfs_tools/init.sh $download_Url/install/plugin/nfs_tools/init.sh -T 5
	wget -O /www/server/panel/plugin/nfs_tools/info.json $download_Url/install/plugin/nfs_tools/info.json -T 5
	wget -O /www/server/panel/plugin/nfs_tools/icon.png $download_Url/install/plugin/nfs_tools/icon.png -T 5
	\cp -a -r /www/server/panel/plugin/nfs_tools/icon.png /www/server/panel/BTPanel/static/img/soft_ico/ico-nfs_tools.png
	\cp -f /www/server/panel/plugin/nfs_tools/init.sh $initSh

	
	chmod +x $initSh

	if [ -f "/usr/bin/apt-get" ];then
		sudo update-rc.d bt_nfs_mount defaults
	else
		chkconfig --add bt_nfs_mount
		chkconfig --level 2345 bt_nfs_mount on
	fi
	
	$initSh stop
	$initSh start

	
	chmod -R 600 $pluginPath
	echo > /www/server/panel/data/reload.pl
	echo '安装完成' > $install_tmp
}

Uninstall_nfs_tools()
{
	echo 'uninstall..'
	if [ -f "/usr/bin/apt-get" ];then
		sudo update-rc.d bt_syssafe remove
	else
		chkconfig --del bt_syssafe
	fi
	rm -f $initSh
	rm -rf $pluginPath
}


install_nfs_server(){
	if [ -f /usr/bin/apt ];then
		apt install nfs-kernel-server -y
	else
		yum install nfs-utils -y
	fi

	systemctl enable nfs-server
	systemctl start nfs-server
	systemctl enable rpcbind
	systemctl start rpcbind
}


action=$1
if [ "${action}" == 'install' ];then
	Install_nfs_tools
elif [ "${action}" == 'uninstall' ];then
	Uninstall_nfs_tools
fi

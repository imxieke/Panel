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
plugin_path=/www/server/panel/plugin/node_admin

Install_node_admin()
{
	mkdir -p $plugin_path
    wget -O $plugin_path/node_admin_main.so $download_Url/install/plugin/node_admin/node_admin_main.so -T 5
	wget -O $plugin_path/node_admin_main.cpython-36m-x86_64-linux-gnu.so $download_Url/install/plugin/node_admin/node_admin_main.cpython-36m-x86_64-linux-gnu.so -T 5
	wget -O $plugin_path/node_admin_main.cpython-37m-x86_64-linux-gnu.so $download_Url/install/plugin/node_admin/node_admin_main.cpython-37m-x86_64-linux-gnu.so -T 5
    wget -O $plugin_path/START_TASK $download_Url/install/plugin/node_admin/START_TASK -T 5
    wget -O $plugin_path/info.json $download_Url/install/plugin/node_admin/info.json -T 5
    wget -O $plugin_path/index.html $download_Url/install/plugin/node_admin/index.html -T 5
	wget -O $plugin_path/icon.png $download_Url/install/plugin/node_admin/icon.png -T 5
	\cp -a -r $plugin_path/icon.png /www/server/panel/BTPanel/static/img/soft_ico/ico-node_admin.png
	echo > $plugin_path/node_admin_main.py
    if [ ! -f $plugin_path/data.db ];then
        wget -O $plugin_path/data.db $download_Url/install/plugin/node_admin/data.db -T 5
    fi

	echo > /www/server/panel/data/reload.pl
	echo '安装完成' > $install_tmp
}

Uninstall_node_admin()
{
	rm -rf $plugin_path
}


action=$1
if [ "${1}" == 'install' ];then
	Install_node_admin
elif [ "${1}" == 'update' ];then
	Install_node_admin
else
	Uninstall_node_admin
fi

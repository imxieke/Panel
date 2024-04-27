#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

public_file=/www/server/panel/install/public.sh
if [ ! -f $public_file ];then
	wget -O $public_file http://download.bt.cn/install/public.sh -T 5;
fi
. $public_file

download_Url=$NODE_URL

#配置插件安装目录
plugin_name=coll_admin
install_path=/www/server/panel/plugin/$plugin_name

#安装
Install()
{
	mkdir -p $install_path
	echo '正在安装...'
	#==================================================================
	#依赖安装开始
	wget -O $install_path/${plugin_name}_main.py $download_Url/install/plugin/${plugin_name}/${plugin_name}_main.py -T 5
	wget -O $install_path/index.html $download_Url/install/plugin/${plugin_name}/index.html -T 5
	wget -O  $install_path/info.json $download_Url/install/plugin/${plugin_name}/info.json -T 5
	wget -O  $install_path/icon.png $download_Url/install/plugin/${plugin_name}/icon.png -T 5
	#依赖安装结束
	#==================================================================
	
	if [ -f /www/server/coll/tools.py ];then
		curl $download_Url/coll_free/update_coll.sh|bash
		/etc/init.d/baota start
	fi

	echo '================================================'
	echo '安装完成'
}

#卸载
Uninstall()
{
	/etc/init.d/baota stop
	chkconfig --del baota
	rm -rf /www/server/coll
	rm -f /etc/init.d/baota
	rm -rf $install_path
}

#操作判断
if [ "${1}" == 'install' ];then
	Install
elif [ "${1}" == 'uninstall' ];then
	Uninstall
else
	echo 'Error!';
fi

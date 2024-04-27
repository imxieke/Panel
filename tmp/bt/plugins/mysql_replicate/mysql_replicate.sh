#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
public_file=/www/server/panel/install/public.sh
if [ ! -f $public_file ];then
	wget -O $public_file http://download.bt.cn/install/public.sh -T 5;
fi
. $public_file
download_Url=$NODE_URL
pluginPath=/www/server/panel/plugin/mysql_replicate


Install_MysqlReplicate()
{
	mkdir $pluginPath
	echo '正在安装脚本文件...' > $install_tmp
	echo > $pluginPath/mysql_replicate_main.py
	wget -O $pluginPath/mysql_replicate.zip $download_Url/install/plugin/mysql_replicate/mysql_replicate.zip -T 5
	wget -O $pluginPath/index.html $download_Url/install/plugin/mysql_replicate/index.html -T 5
	wget -O $pluginPath/info.json $download_Url/install/plugin/mysql_replicate/info.json -T 5
	wget -O $pluginPath/icon.png $download_Url/install/plugin/mysql_replicate/icon.png -T 5
	wget -O $pluginPath/install.sh $download_Url/install/plugin/mysql_replicate/install.sh -T 5
    \cp -a -r /www/server/panel/plugin/mysql_replicate/icon.png /www/server/panel/BTPanel/static/img/soft_ico/ico-mysql_replicate.png
  cd $pluginPath && unzip -o mysql_replicate.zip && rm -f mysql_replicate.zip
	echo 'Successify'
}


Uninstall_MysqlReplicate()
{
	rm -rf $pluginPath
	echo 'Successify'
}

if [ "${1}" == 'install' ];then
	Install_MysqlReplicate
	echo > /www/server/panel/data/restart.pl
elif  [ "${1}" == 'update' ];then
	Install_MysqlReplicate
	echo > /www/server/panel/data/restart.pl
elif [ "${1}" == 'uninstall' ];then
	Uninstall_MysqlReplicate
fi

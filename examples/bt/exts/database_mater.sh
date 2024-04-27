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

pyVersion=$(python -c 'import sys;print(sys.version_info[0]);')
py_zi=$(python -c 'import sys;print(sys.version_info[1]);')

pluginPath='/www/server/panel/plugin/database_mater/'
aacher=$(uname -a |grep -Po aarch64|awk 'NR==1')

Install_logs()
{
	mkdir -p $pluginPath
	echo '正在安装脚本文件...' > $install_tmp
	echo 'print(1)'>$pluginPath/database_mater_main.py
	if [ "$aacher" == "aarch64" ];then 
		if [  -f /www/server/panel/pyenv/bin/python ];then
			wget -O $pluginPath/database_mater_main.cpython-37m-aarch64-linux-gnu.zip $download_Url/install/plugin/database_mater/aachar64/database_mater_main.cpython-37m-aarch64-linux-gnu.zip -T 5
			unzip -o $pluginPath/database_mater_main.cpython-37m-aarch64-linux-gnu.zip -d $pluginPath > /dev/null
			rm -rf $pluginPath/database_mater_main.cpython-37m-aarch64-linux-gnu.zip
		else
			if [ "$pyVersion" == 2 ];then
				wget -O $pluginPath/database_mater_main.zip $download_Url/install/plugin/database_mater/aachar64/database_mater_main.zip -T 5
				unzip -o $pluginPath/database_mater_main.zip -d $pluginPath > /dev/null
				rm -rf $pluginPath/database_mater_main.zip
			else
				if [ "$py_zi" == 6 ];then 
					wget -O $pluginPath/database_mater_main.cpython-36m-aarch64-linux-gnu.zip $download_Url/install/plugin/database_mater/aachar64/database_mater_main.cpython-36m-aarch64-linux-gnu.zip -T 5
					unzip -o $pluginPath/database_mater_main.cpython-36m-aarch64-linux-gnu.zip -d $pluginPath > /dev/null
					rm -rf $pluginPath/database_mater_main.cpython-36m-aarch64-linux-gnu.zip
				fi 
				if [ "$py_zi" == 7 ];then 
					wget -O $pluginPath/database_mater_main.cpython-37m-aarch64-linux-gnu.zip $download_Url/install/plugin/database_mater/aachar64/database_mater_main.cpython-37m-aarch64-linux-gnu.zip -T 5
					unzip -o $pluginPath/database_mater_main.cpython-37m-aarch64-linux-gnu.zip -d $pluginPath > /dev/null
					rm -rf $pluginPath/database_mater_main.cpython-37m-aarch64-linux-gnu.zip
				fi
			fi
		fi
	else
		if [  -f /www/server/panel/pyenv/bin/python ];then
			wget -O $pluginPath/database_mater_main.cpython-37m-x86_64-linux-gnu.zip $download_Url/install/plugin/database_mater/database_mater_main.cpython-37m-x86_64-linux-gnu.zip -T 5
			unzip -o $pluginPath/database_mater_main.cpython-37m-x86_64-linux-gnu.zip -d $pluginPath > /dev/null
			rm -rf $pluginPath/database_mater_main.cpython-37m-x86_64-linux-gnu.zip
		else
			if [ "$pyVersion" == 2 ];then
				wget -O $pluginPath/database_mater_main.zip $download_Url/install/plugin/database_mater/database_mater_main.zip -T 5
				unzip -o $pluginPath/database_mater_main.zip -d $pluginPath > /dev/null
				rm -rf $pluginPath/database_mater_main.zip
			else
				if [ "$py_zi" == 6 ];then 
					wget -O $pluginPath/database_mater_main.cpython-36m-x86_64-linux-gnu.zip $download_Url/install/plugin/database_mater/database_mater_main.cpython-36m-x86_64-linux-gnu.zip -T 5
					unzip -o $pluginPath/database_mater_main.cpython-36m-x86_64-linux-gnu.zip -d $pluginPath > /dev/null
					rm -rf $pluginPath/database_mater_main.cpython-36m-x86_64-linux-gnu.zip
				fi 
				if [ "$py_zi" == 4 ];then 
					wget -O $pluginPath/database_mater_main.cpython-34m.zip $download_Url/install/plugin/database_mater/database_mater_main.cpython-34m.zip -T 5
					unzip -o $pluginPath/database_mater_main.cpython-34m.zip -d $pluginPath > /dev/null
					rm -rf $pluginPath/database_mater_main.cpython-34m.zip
				fi
				if [ "$py_zi" == 7 ];then 
					wget -O $pluginPath/database_mater_main.cpython-37m-x86_64-linux-gnu.zip $download_Url/install/plugin/database_mater/database_mater_main.cpython-37m-x86_64-linux-gnu.zip -T 5
					unzip -o $pluginPath/database_mater_main.cpython-37m-x86_64-linux-gnu.zip -d $pluginPath > /dev/null
					rm -rf $pluginPath/database_mater_main.cpython-37m-x86_64-linux-gnu.zip
				fi
			fi
		fi
	fi
	wget -O /www/server/panel/plugin/database_mater/task_local.py $download_Url/install/plugin/database_mater/task_local.py -T 5
	wget -O /www/server/panel/plugin/database_mater/index.html $download_Url/install/plugin/database_mater/index.html -T 5
	wget -O /www/server/panel/plugin/database_mater/info.json $download_Url/install/plugin/database_mater/info.json -T 5
	wget -O /www/server/panel/plugin/database_mater/ico-database_mater.png $download_Url/install/plugin/database_mater/ico-database_mater.png -T 5
	cp  -p /www/server/panel/plugin/database_mater/ico-database_mater.png  /www/server/panel/BTPanel/static/img/soft_ico/
	bash /www/server/panel/init.sh start
	echo '安装完成' > $install_tmp
}

Uninstall_logs()
{
	rm -rf /www/server/panel/plugin/database_mater
}


action=$1
if [ "${1}" == 'install' ];then
	Install_logs
else
	Uninstall_logs
fi

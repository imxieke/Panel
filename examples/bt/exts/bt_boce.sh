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

pluginPath='/www/server/panel/plugin/bt_boce/'
aacher=$(uname -a |grep -Po aarch64|awk 'NR==1')


Install_logs()
{
	mkdir -p $pluginPath
	echo '正在安装脚本文件...' > $install_tmp
	echo 'print(1)'>$pluginPath/bt_boce_main.py
	if [ "$aacher" == "aarch64" ];then 
		if [  -f /www/server/panel/pyenv/bin/python ];then
				wget -O $pluginPath/bt_boce_main.cpython-37m-aarch64-linux-gnu.zip $download_Url/install/plugin/bt_boce/aachar64/bt_boce_main.cpython-37m-aarch64-linux-gnu.zip -T 5
				unzip -o $pluginPath/bt_boce_main.cpython-37m-aarch64-linux-gnu.zip -d $pluginPath > /dev/null
				rm -rf $pluginPath/bt_boce_main.cpython-37m-aarch64-linux-gnu.zip
				
			else
				if [ "$pyVersion" == 2 ];then
					wget -O $pluginPath/bt_boce_main.zip $download_Url/install/plugin/bt_boce/aachar64/bt_boce_main.zip -T 5
					unzip -o $pluginPath/bt_boce_main.zip -d $pluginPath > /dev/null
					rm -rf $pluginPath/bt_boce_main.zip
				else
					if [ "$py_zi" == 6 ];then 
						wget -O $pluginPath/bt_boce_main.cpython-36m-aarch64-linux-gnu.zip $download_Url/install/plugin/bt_boce/aachar64/bt_boce_main.cpython-36m-aarch64-linux-gnu.zip -T 5
						unzip -o $pluginPath/bt_boce_main.cpython-36m-aarch64-linux-gnu.zip -d $pluginPath > /dev/null
						rm -rf $pluginPath/bt_boce_main.cpython-36m-aarch64-linux-gnu.zip
					fi 
					if [ "$py_zi" == 7 ];then 
						wget -O $pluginPath/bt_boce_main.cpython-37m-aarch64-linux-gnu.zip $download_Url/install/plugin/bt_boce/aachar64/bt_boce_main.cpython-37m-aarch64-linux-gnu.zip -T 5
						unzip -o $pluginPath/bt_boce_main.cpython-37m-aarch64-linux-gnu.zip -d $pluginPath > /dev/null
						rm -rf $pluginPath/bt_boce_main.cpython-37m-aarch64-linux-gnu.zip
					fi
				fi
			fi
	else
		if [  -f /www/server/panel/pyenv/bin/python ];then
			wget -O $pluginPath/bt_boce_main.cpython-37m-x86_64-linux-gnu.zip $download_Url/install/plugin/bt_boce/bt_boce_main.cpython-37m-x86_64-linux-gnu.zip -T 5
			unzip -o $pluginPath/bt_boce_main.cpython-37m-x86_64-linux-gnu.zip -d $pluginPath > /dev/null
			rm -rf $pluginPath/bt_boce_main.cpython-37m-x86_64-linux-gnu.zip
			wget -O $pluginPath/start_boce.cpython-37m-x86_64-linux-gnu.zip $download_Url/install/plugin/bt_boce/start_boce.cpython-37m-x86_64-linux-gnu.zip -T 5
			unzip -o $pluginPath/start_boce.cpython-37m-x86_64-linux-gnu.zip -d $pluginPath > /dev/null
			rm -rf $pluginPath/start_boce.cpython-37m-x86_64-linux-gnu.zip
		else
			if [ "$pyVersion" == 2 ];then
				wget -O $pluginPath/bt_boce_main.zip $download_Url/install/plugin/bt_boce/bt_boce_main.zip -T 5
				unzip -o $pluginPath/bt_boce_main.zip -d $pluginPath > /dev/null
				rm -rf $pluginPath/bt_boce_main.zip
				wget -O $pluginPath/start_boce.zip $download_Url/install/plugin/bt_boce/start_boce.zip -T 5
				unzip -o $pluginPath/start_boce.zip -d $pluginPath > /dev/null
				rm -rf $pluginPath/start_boce.zip
			else
				if [ "$py_zi" == 6 ];then 
					wget -O $pluginPath/bt_boce_main.cpython-36m-x86_64-linux-gnu.zip $download_Url/install/plugin/bt_boce/bt_boce_main.cpython-36m-x86_64-linux-gnu.zip -T 5
					unzip -o $pluginPath/bt_boce_main.cpython-36m-x86_64-linux-gnu.zip -d $pluginPath > /dev/null
					rm -rf $pluginPath/bt_boce_main.cpython-36m-x86_64-linux-gnu.zip
					wget -O $pluginPath/start_boce.cpython-36m-x86_64-linux-gnu.zip $download_Url/install/plugin/bt_boce/start_boce.cpython-36m-x86_64-linux-gnu.zip -T 5
					unzip -o $pluginPath/start_boce.cpython-36m-x86_64-linux-gnu.zip -d $pluginPath > /dev/null
					rm -rf $pluginPath/start_boce.cpython-36m-x86_64-linux-gnu.zip
				fi 
				if [ "$py_zi" == 4 ];then 
					wget -O $pluginPath/bt_boce_main.cpython-34m.zip $download_Url/install/plugin/bt_boce/bt_boce_main.cpython-34m.zip -T 5
					unzip -o $pluginPath/bt_boce_main.cpython-34m.zip -d $pluginPath > /dev/null
					rm -rf $pluginPath/bt_boce_main.cpython-34m.zip
				fi
				if [ "$py_zi" == 7 ];then 
					wget -O $pluginPath/bt_boce_main.cpython-37m-x86_64-linux-gnu.zip $download_Url/install/plugin/bt_boce/bt_boce_main.cpython-37m-x86_64-linux-gnu.zip -T 5
					unzip -o $pluginPath/bt_boce_main.cpython-37m-x86_64-linux-gnu.zip -d $pluginPath > /dev/null
					rm -rf $pluginPath/bt_boce_main.cpython-37m-x86_64-linux-gnu.zip
					wget -O $pluginPath/start_boce.cpython-37m-x86_64-linux-gnu.zip $download_Url/install/plugin/bt_boce/start_boce.cpython-37m-x86_64-linux-gnu.zip -T 5
					unzip -o $pluginPath/start_boce.cpython-37m-x86_64-linux-gnu.zip -d $pluginPath > /dev/null
					rm -rf $pluginPath/start_boce.cpython-37m-x86_64-linux-gnu.zip
				fi
			fi
		fi
	fi
	wget -O /www/server/panel/plugin/bt_boce/index.html $download_Url/install/plugin/bt_boce/index.html -T 5
	wget -O /www/server/panel/plugin/bt_boce/boce.py $download_Url/install/plugin/bt_boce/boce.py -T 5
	wget -O /www/server/panel/plugin/bt_boce/info.json $download_Url/install/plugin/bt_boce/info.json -T 5
	wget -O /www/server/panel/plugin/bt_boce/ico-bt_boce.png $download_Url/install/plugin/bt_boce/ico-bt_boce.png -T 5
	if [  -f /www/server/panel/BTPanel/static/img/soft_ico/ico-bt_boce.png ];then
		rm -rf /www/server/panel/BTPanel/static/img/soft_ico/ico-bt_boce.png 
	fi
	cp -p $pluginPath/ico-bt_boce.png  /www/server/panel/BTPanel/static/img/soft_ico/
	bash /www/server/panel/init.sh start
	echo '安装完成' > $install_tmp
}

Uninstall_logs()
{
	rm -rf /www/server/panel/plugin/bt_boce
}


action=$1
if [ "${1}" == 'install' ];then
	Install_logs
else
	Uninstall_logs
fi

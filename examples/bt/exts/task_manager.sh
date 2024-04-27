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

Install_task_manager()
{
	mkdir -p /www/server/panel/plugin/task_manager
	echo '正在安装脚本文件...' > $install_tmp
	is_install_pcap=$(/www/server/panel/pyenv/bin/python -m pcap 2>&1|grep 'No module named')
	if [ "$is_install_pcap" != "" ];then
		if [ -f /usr/bin/apt ];then
			is_install=$(apt list --installed|grep libpcap-dev)
			if [ "$is_install" = "" ];then
				apt install libpcap-dev -y
			fi
		elif [ -f /usr/bin/dnf ];then
			is_install=$(rpm -qa|grep libpcap-devel)
			if [ "$is_install" = "" ];then
				dnf install libpcap-devel -y
			fi
		elif [ -f /usr/bin/yum ];then
			is_install=$(rpm -qa|grep libpcap-devel)
			if [ "$is_install" = "" ];then
				yum install libpcap-devel -y
			fi
		fi
		/www/server/panel/pyenv/bin/pip3 install pypcap
	fi
	wget -O /www/server/panel/plugin/task_manager/task_manager_main.py $download_Url/install/plugin/task_manager/task_manager_main.py -T 5
	wget -O /www/server/panel/plugin/task_manager/process_network_total.py $download_Url/install/plugin/task_manager/process_network_total.py -T 5
	wget -O /www/server/panel/plugin/task_manager/index.html $download_Url/install/plugin/task_manager/index.html -T 5
	wget -O /www/server/panel/plugin/task_manager/info.json $download_Url/install/plugin/task_manager/info.json -T 5
	wget -O /www/server/panel/plugin/task_manager/icon.png $download_Url/install/plugin/task_manager/icon.png -T 5
	\cp -a -r /www/server/panel/plugin/task_manager/icon.png /www/server/panel/static/img/soft_ico/ico-task_manager.png
	echo '安装完成' > $install_tmp
}

Uninstall_task_manager()
{
	rm -rf /www/server/panel/plugin/task_manager
}

action=$1
if [ "${1}" == 'install' ];then
	Install_task_manager
else
	Uninstall_task_manager
fi

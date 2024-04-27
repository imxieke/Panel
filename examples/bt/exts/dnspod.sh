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

Install_dnspod()
{
	pip install tencentcloud-sdk-python
	btpip install tencentcloud-sdk-python
	
	mkdir -p /www/server/panel/plugin/dnspod
	echo '正在安装脚本文件...' > $install_tmp
	wget -O /www/server/panel/plugin/dnspod/dnspod_main.py $download_Url/install/plugin/dnspod/dnspod_main.py -T 5
	wget -O /www/server/panel/plugin/dnspod/index.html $download_Url/install/plugin/dnspod/index.html -T 5
	wget -O /www/server/panel/plugin/dnspod/info.json $download_Url/install/plugin/dnspod/info.json -T 5
	wget -O /www/server/panel/plugin/dnspod/icon.png $download_Url/install/plugin/dnspod/icon.png -T 5
	wget -O /www/server/panel/BTPanel/static/img/soft_ico/ico-dnspod.png $download_Url/install/plugin/dnspod/icon.png -T 5	

	echo '安装完成' > $install_tmp
}

Uninstall_dnspod()
{
	rm -rf /www/server/panel/plugin/dnspod
}


action=$1
if [ "${1}" == 'install' ];then
	Install_dnspod
else
	Uninstall_dnspod
fi

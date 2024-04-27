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

Install_txcdn()
{
	pip install tencentcloud-sdk-python
	btpip install tencentcloud-sdk-python
	
	mkdir -p /www/server/panel/plugin/txcdn
	echo '正在安装脚本文件...' > $install_tmp
	wget -O /www/server/panel/plugin/txcdn/txcdn_main.py $download_Url/install/plugin/txcdn/txcdn_main.py -T 5
	wget -O /www/server/panel/plugin/txcdn/index.html $download_Url/install/plugin/txcdn/index.html -T 5
	wget -O /www/server/panel/plugin/txcdn/info.json $download_Url/install/plugin/txcdn/info.json -T 5
	wget -O /www/server/panel/plugin/txcdn/icon.png $download_Url/install/plugin/txcdn/icon.png -T 5
	wget -O /www/server/panel/BTPanel/static/img/soft_ico/ico-txcdn.png $download_Url/install/plugin/txcdn/icon.png -T 5	

	echo '安装完成' > $install_tmp
}

Uninstall_txcdn()
{
	rm -rf /www/server/panel/plugin/txcdn
}


action=$1
if [ "${1}" == 'install' ];then
	Install_txcdn
else
	Uninstall_txcdn
fi

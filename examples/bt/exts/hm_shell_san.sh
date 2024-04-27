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

Install_linuxsys()
{
	mkdir -p /www/server/panel/plugin/hm_shell_san
	echo '正在安装脚本文件...' > $install_tmp
	cd /usr/local/ && wget $download_Url/install/plugin/hm_shell_san/hm-linux-amd64.tgz && tar zxf hm-linux-amd64.tgz && rm -rf /usr/local/hm-linux-amd64.tgz
	wget -O /www/server/panel/plugin/hm_shell_san/hm_shell_san_main.py $download_Url/install/plugin/hm_shell_san/hm_shell_san_main.py -T 5
	wget -O /www/server/panel/plugin/hm_shell_san/index.html $download_Url/install/plugin/hm_shell_san/index.html -T 5
	wget -O /www/server/panel/plugin/hm_shell_san/info.json $download_Url/install/plugin/hm_shell_san/info.json -T 5
	wget -O /www/server/panel/plugin/hm_shell_san/icon.png $download_Url/install/plugin/hm_shell_san/icon.png -T 5
	
	
	echo '安装完成' > $install_tmp
}

Uninstall_linuxsys()
{
	rm -rf /www/server/panel/plugin/hm_shell_san
}


action=$1
if [ "${1}" == 'install' ];then
	Install_linuxsys
else
	Uninstall_linuxsys
fi

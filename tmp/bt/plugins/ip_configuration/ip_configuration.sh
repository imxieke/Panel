#!/bin/bash
PATH=/www/server/panel/pyenv/bin:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
install_tmp='/tmp/bt_install.pl'

public_file=/www/server/panel/install/public.sh
wget -O $public_file http://download.bt.cn/install/public.sh -T 5;
. $public_file

download_Url=$NODE_URL

Install_ip_configuration()
{
    Pack="bridge-utils"
	if [ "${PM}" == "yum" ] || [ "${PM}" == "dnf" ] ; then
		${PM} install ${Pack} -y
	elif [ "${PM}" == "apt-get" ]; then
		${PM} install ${Pack} -y
	fi
    mkdir -p /www/server/panel/plugin/ip_configuration

    echo '正在安装脚本文件...' > $install_tmp
    wget -O /www/server/panel/plugin/ip_configuration/ip_configuration_main.py $download_Url/install/plugin/ip_configuration/ip_configuration_main.py -T 5
    wget -O /www/server/panel/plugin/ip_configuration/index.html $download_Url/install/plugin/ip_configuration/index.html -T 5
    wget -O /www/server/panel/plugin/ip_configuration/info.json $download_Url/install/plugin/ip_configuration/info.json -T 5
    wget -O /www/server/panel/plugin/ip_configuration/icon.png $download_Url/install/plugin/ip_configuration/icon.png -T 5
    wget -O /www/server/panel/BTPanel/static/img/soft_ico/ico-ip_configuration.png $download_Url/install/plugin/ip_configuration/icon.png -T 5

	echo '安装完成' > $install_tmp
	echo success
}

Uninstall_ip_configuration()
{
 	rm -rf /www/server/panel/plugin/ip_configuration
	rm -f /www/server/panel/static/img/soft_ico/ico-ip_configuration.png
	echo '卸载已成功'
}


action=$1
if [ "${1}" == 'install' ];then
	Install_ip_configuration
else
	Uninstall_ip_configuration
fi

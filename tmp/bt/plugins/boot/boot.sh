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
echo $download_Url
pluginPath=/www/server/panel/plugin/boot

# 安装
Install_Boot()
{
	mkdir -p $pluginPath

	echo '正在安装脚本文件...' > $install_tmp
	wget -O $pluginPath/boot_main.py $download_Url/install/plugin/boot/boot_main.py -T 5
	wget -O $pluginPath/index.html $download_Url/install/plugin/boot/index.html -T 5
	wget -O $pluginPath/info.json $download_Url/install/plugin/boot/info.json -T 5
	wget -O $pluginPath/icon.png $download_Url/install/plugin/boot/icon.png -T 5
	wget -O $pluginPath/install.sh $download_Url/install/plugin/boot/install.sh -T 5
	\cp -a -r $pluginPath/icon.png /www/server/panel/BTPanel/static/img/soft_ico/ico-boot.png
    echo '安装完成' > $install_tmp
}

# 卸载
Uninstall_Boot()
{
	rm -rf $pluginPath
}

if [ "${1}" == 'install' ];then
	Install_Boot
elif [ "${1}" == 'uninstall' ];then
	Uninstall_Boot
else
    echo 'Error'
fi

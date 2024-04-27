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
pluginPath=/www/server/panel/plugin/static_cdn

# 安装
Install_static_cdn()
{

	mkdir -p $pluginPath
	mkdir -p $pluginPath/log
	mkdir -p $pluginPath/profile
    
	echo '正在安装脚本文件...' > $install_tmp
	wget -O $pluginPath/static_cdn_main.py $download_Url/install/plugin/static_cdn/static_cdn_main.py -T 5
    wget -O $pluginPath/url_file.pl $download_Url/install/plugin/static_cdn/url_file.pl -T 5
	wget -O $pluginPath/hosts.json $download_Url/install/plugin/static_cdn/hosts.json -T 5
	wget -O $pluginPath/index.html $download_Url/install/plugin/static_cdn/index.html -T 5
	wget -O $pluginPath/info.json $download_Url/install/plugin/static_cdn/info.json -T 5
	wget -O $pluginPath/icon.png $download_Url/install/plugin/static_cdn/icon.png -T 5
	wget -O $pluginPath/install.sh $download_Url/install/plugin/static_cdn/install.sh -T 5
	\cp -a -r $pluginPath/icon.png /www/server/panel/BTPanel/static/img/soft_ico/ico-static_cdn.png
	echo '安装完成' > $install_tmp
}

# 卸载
Uninstall_static_cdn()
{
    rm -rf $pluginPath
}

if [ "${1}" == 'install' ];then
	Install_static_cdn
elif [ "${1}" == 'uninstall' ];then
	Uninstall_static_cdn
else
    echo 'Error'
fi


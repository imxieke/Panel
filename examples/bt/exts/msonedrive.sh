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
pluginPath=/www/server/panel/plugin/msonedrive


Install_msonedrive()
{
  if hash btpip 2>/dev/null; then
	  btpip install requests-oauthlib==1.3.0
  else
	  pip install requests-oauthlib==1.3.0
  fi
	mkdir -p $pluginPath
	echo '正在安装脚本文件...' > $install_tmp
	 
	wget -O $pluginPath/msonedrive_main.py $download_Url/install/plugin/msonedrive/msonedrive_main.py -T 5
	wget -O $pluginPath/credentials.json $download_Url/install/plugin/msonedrive/credentials.json -T 5
	wget -O $pluginPath/index.html $download_Url/install/plugin/msonedrive/index.html -T 5
	wget -O $pluginPath/info.json $download_Url/install/plugin/msonedrive/info.json -T 5
	wget -O $pluginPath/icon.png $download_Url/install/plugin/msonedrive/icon.png -T 5
    \cp -arf $pluginPath/icon.png /www/server/panel/BTPanel/static/img/soft_ico/ico-msonedrive.png

	echo '安装完成' > $install_tmp
}


Uninstall_msonedrive()
{
	rm -rf $pluginPath
}

if [ "${1}" == 'install' ];then
	Install_msonedrive
elif [ "${1}" == 'uninstall' ];then
	Uninstall_msonedrive
else
	echo 'Error!';
fi

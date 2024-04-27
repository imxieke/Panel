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
pluginPath=/www/server/panel/plugin/btappmanager


Init_btappmanager(){
  panel_path=/www/server/panel
  env_path=$panel_path/pyenv/bin/activate
  plugin_path=$panel_path/plugin/btappmanager
  if [ -f $env_path ];then
    pythonV=$panel_path/pyenv/bin/python
    sed -i "s@^#!.*@#!$pythonV@" $plugin_path/btappmanagerd
  fi
  chmod 700 $plugin_path/btappmanagerd
}

Install_btappmanager()
{
  if hash btpip 2>/dev/null; then
    btpip install configparser
  else
    pip install configparser
  fi
	mkdir -p $pluginPath
	echo '正在安装脚本文件...' > $install_tmp
	 
	wget -O $pluginPath/btappmanager_main.py $download_Url/install/plugin/btappmanager/btappmanager_main.py -T 5
	wget -O $pluginPath/btappmanagerd $download_Url/install/plugin/btappmanager/btappmanagerd -T 5
	wget -O $pluginPath/index.html $download_Url/install/plugin/btappmanager/index.html -T 5
	wget -O $pluginPath/info.json $download_Url/install/plugin/btappmanager/info.json -T 5
	wget -O $pluginPath/icon.png $download_Url/install/plugin/btappmanager/icon.png -T 5
	\cp $pluginPath/icon.png /www/server/panel/BTPanel/static/img/soft_ico/ico-btappmanager.png

  Init_btappmanager
	$pluginPath/btappmanagerd install

	echo '安装完成' > $install_tmp
}


Uninstall_btappmanager()
{
  if hash btpython 2>/dev/null; then
    btpython $pluginPath/btappmanagerd uninstall
  else
    python $pluginPath/btappmanagerd uninstall
  fi
	rm -rf $pluginPath
}


Update_btappmanager()
{
	echo '正在更新插件文件...' > $install_tmp

	wget -O $pluginPath/btappmanager_main.py $download_Url/install/plugin/btappmanager/btappmanager_main.py -T 5
	wget -O $pluginPath/btappmanagerd $download_Url/install/plugin/btappmanager/btappmanagerd -T 5
	wget -O $pluginPath/index.html $download_Url/install/plugin/btappmanager/index.html -T 5
	wget -O $pluginPath/info.json $download_Url/install/plugin/btappmanager/info.json -T 5
	wget -O $pluginPath/icon.png $download_Url/install/plugin/btappmanager/icon.png -T 5
	\cp $pluginPath/icon.png /www/server/panel/BTPanel/static/img/soft_ico/ico-btappmanager.png

  Init_btappmanager
	echo '更新完成' > $install_tmp
}

if [ "${1}" == 'install' ];then
	Install_btappmanager
elif [ "${1}" == 'update' ];then
  Update_btappmanager
elif [ "${1}" == 'uninstall' ];then
	Uninstall_btappmanager
fi

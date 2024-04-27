#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
install_tmp='/tmp/bt_install.pl'
public_file=/www/server/panel/install/public.sh
if [ ! -f $public_file ];then
	wget -O $public_file http://download.bt.cn/install/public.sh -T 5;
fi
. $public_file
pluginPath=/www/server/panel/plugin/site_optimization
download_Url=$NODE_URL
pyVersion=$(python -c 'import sys;print(sys.version_info[0]);')
py_zi=$(python -c 'import sys;print(sys.version_info[1]);')
mkdir -p $pluginPath/check_site_type_script
mkdir -p $pluginPath/opt_site_script
Install_Site_OPT()
{
  echo '正在安装脚本文件...' > $install_tmp
	if [ -f '/www/server/panel/pyenv/bin/python' ];then
		wget -O $pluginPath/site_optimization_main.cpython-37m-x86_64-linux-gnu.so $download_Url/install/plugin/site_optimization/site_optimization_main.cpython-37m-x86_64-linux-gnu.so -T 5
	else
		if [ "$pyVersion" == 2 ];then
        wget -O $pluginPath/site_optimization_main.so $download_Url/install/plugin/site_optimization/site_optimization_main.so -T 5
		else
			if [ "$py_zi" == 6 ];then
        wget -O $pluginPath/site_optimization_main.cpython-36m-x86_64-linux-gnu.so  $download_Url/install/plugin/site_optimization/site_optimization_main.cpython-36m-x86_64-linux-gnu.so -T 5
			fi
			if [ "$py_zi" == 7 ];then
		    wget -O $pluginPath/site_optimization_main.cpython-37m-x86_64-linux-gnu.so $download_Url/install/plugin/site_optimization/site_optimization_main.cpython-37m-x86_64-linux-gnu.so -T 5
			fi
		fi
	fi

  wget -O $pluginPath/opt_site_script/opt_site_script.zip $download_Url/install/plugin/site_optimization/opt_site_script/opt_site_script.zip -T 5
  cd $pluginPath/opt_site_script/
  unzip -o opt_site_script.zip
  rm -f opt_site_script.zip
  wget -O $pluginPath/check_site_type_script/check_site_type_script.zip $download_Url/install/plugin/site_optimization/check_site_type_script/check_site_type_script.zip -T 5
  cd $pluginPath/check_site_type_script/
  unzip -o check_site_type_script.zip
  rm -f check_site_type_script.zip
  wget -O $pluginPath/index.html $download_Url/install/plugin/site_optimization/index.html -T 5
  wget -O $pluginPath/info.json $download_Url/install/plugin/site_optimization/info.json -T 5
  wget -O $pluginPath/icon.png $download_Url/install/plugin/site_optimization/icon.png -T 5
  wget -O $pluginPath/site_optimization_main.py $download_Url/install/plugin/site_optimization/site_optimization_main.py -T 5
  if [ ! -f '/www/server/panel/plugin/site_optimization/opt_scripts.json' ];then
    wget -O $pluginPath/opt_scripts.json $download_Url/install/plugin/site_optimization/opt_scripts.json -T 5
  fi
  cp -a -r $pluginPath/icon.png /www/server/panel/BTPanel/static/img/soft_ico/ico-site_optimization.png

  echo '安装完成' > $install_tmp
}

Uninstall_Site_OPT()
{
	rm -rf /www/server/panel/plugin/site_optimization
	echo '卸载完成' > $install_tmp
}


action=$1
if [ "${1}" == 'install' ];then
	Install_Site_OPT
	echo > /www/server/panel/data/reload.pl
else
	Uninstall_Site_OPT
fi

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
#配置插件安装目录
install_path=/www/server/panel/plugin/alioss

#安装
Install()
{
	
	echo '正在安装...'
	#==================================================================
	#依赖安装开始

  if hash btpip 2>/dev/null; then
	  btpip uninstall pycryptodome -y
	  btpip install pycryptodome==3.9.7
	  btpip install oss2==2.5.0
	  btpip install PyMySQL==0.9.3
	else
	  pip uninstall pycryptodome -y
	  pip install pycryptodome==3.9.7
	  pip install oss2==2.5.0
	  pip install PyMySQL==0.9.3
	fi
	curl -Ss --connect-timeout 3 -m 60 $download_Url/install/pip_select.sh|bash
	mkdir -p /www/server/panel/plugin/alioss
	wget -O /www/server/panel/plugin/alioss/alioss_main.py $download_Url/install/plugin/alioss/alioss_main.py -T 5
	wget -O /www/server/panel/plugin/alioss/index.html $download_Url/install/plugin/alioss/index.html -T 5
	wget -O /www/server/panel/plugin/alioss/info.json $download_Url/install/plugin/alioss/info.json -T 5
	rm -rf /www/server/panel/plugin/alioss/alilib
	rm -rf /www/server/panel/plugin/alioss/alilib.zip
	#依赖安装结束
	#==================================================================

	echo '================================================'
	echo '安装完成'
}

#卸载
Uninstall()
{
	rm -rf /www/server/panel/data/aliossAS.conf
	rm -rf /www/server/panel/data/aliossAs.conf
	echo '备份文件已删除'
	rm -rf $install_path
}

#操作判断
if [ "${1}" == 'install' ];then
	Install
elif [ "${1}" == 'uninstall' ];then
	Uninstall
else
	echo 'Error!';
fi

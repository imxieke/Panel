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
install_path=/www/server/panel/plugin/qiniu

#安装
Install()
{
	
	echo '正在安装...'
	#==================================================================
	#依赖安装开始
	if hash btpip 2>/dev/null;then
	  btpip install PyMySQL==0.9.3
    btpip install qiniu==7.4.1 -I
  else
    pip install PyMySQL==0.9.3
    pip install qiniu==7.4.1 -I
  fi
	echo '正在安装脚本文件...' > $install_tmp
	mkdir -p /www/server/panel/plugin/qiniu
	wget -O /www/server/panel/plugin/qiniu/qiniu_main.py $download_Url/install/plugin/qiniu/qiniu_main.py -T 5
	wget -O /www/server/panel/plugin/qiniu/index.html $download_Url/install/plugin/qiniu/index.html -T 5
	wget -O /www/server/panel/plugin/qiniu/info.json $download_Url/install/plugin/qiniu/info.json -T 5
	rm -rf /www/server/panel/plugin/qiniu/qnlib
	rm -rf /www/server/panel/plugin/qiniu/qnlib.zip
	echo '安装完成' > $install_tmp

	#依赖安装结束
	#==================================================================
	echo '================================================'
	echo '安装完成'
	echo Successify
}

#卸载
Uninstall()
{
	rm -rf /www/server/panel/data/qiniuAS.conf
	rm -rf /www/server/panel/data/qiniuAs.conf
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

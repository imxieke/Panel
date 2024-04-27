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

Install_upyun()
{
  py_version=`python -V 2>&1|awk '{print $2}'|awk -F '.' '{print $1}'`
  if [ $py_version==2 ]; then
    echo '重新安装pyopenssl...'
    pip uninstall -y pyopenssl
    pip install --upgrade pyopenssl
  fi
	pip install PyMySQL==0.9.3
  btpip install upyun==2.5.5
	pip install PyMySQL==0.9.3
  pip install upyun==2.5.5
	mkdir -p /www/server/panel/plugin/upyun
	echo '正在安装脚本文件...' > $install_tmp
	wget -O /www/server/panel/plugin/upyun/upyun_main.py $download_Url/install/plugin/upyun/upyun_main.py -T 5
	wget -O /www/server/panel/plugin/upyun/index.html $download_Url/install/plugin/upyun/index.html -T 5
	wget -O /www/server/panel/plugin/upyun/info.json $download_Url/install/plugin/upyun/info.json -T 5
	wget -O /www/server/panel/plugin/upyun/icon.png $download_Url/install/plugin/upyun/icon.png -T 5
	wget -O /www/server/panel/static/img/soft_ico/ico-upyun.png $download_Url/install/plugin/upyun/icon.png -T 5
	rm -rf /www/server/panel/plugin/upyun/uplib
	rm -rf /www/server/panel/plugin/upyun/uplib.zip
	echo '安装完成' > $install_tmp
}

Uninstall_upyun()
{
	rm -rf /www/server/panel/data/upyunAS.conf
	rm -rf /www/server/panel/data/upyunAs.conf
	echo '备份文件已删除'
	rm -rf /www/server/panel/plugin/upyun
	pip uninstall upyun -y
}


action=$1
if [ "${1}" == 'install' ];then
	Install_upyun
else
	Uninstall_upyun
fi

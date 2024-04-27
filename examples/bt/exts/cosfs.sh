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

System_Lib(){
	if [ "${PM}" == "yum" ] || [ "${PM}" == "dnf" ] ; then
		Pack="automake gcc-c++ git libcurl-devel libxml2-devel fuse-devel make openssl-devel fuse"
	elif [ "${PM}" == "apt-get" ]; then
		Pack="automake autotools-dev g++ git libcurl4-gnutls-dev libfuse-dev libssl-dev libxml2-dev make pkg-config fuse"
	fi
	${PM} install ${Pack} -y
}
Cosfs_Install(){
	wget -O cosfs-master.zip ${download_Url}/src/cosfs-master.zip
	unzip cosfs-master.zip
	cd cosfs-master
	./autogen.sh
	./configure
	make
	make install
	cd ..
	rm -rf cosfs-master*
	
	pip install cos-python-sdk-v5
	btpip install cos-python-sdk-v5
	
	mkdir -p /www/cosfs

	mkdir -p /www/server/panel/plugin/cosfs
	echo '正在安装脚本文件...' > $install_tmp
	wget -O /www/server/panel/plugin/cosfs/cosfs_main.py $download_Url/install/plugin/cosfs/cosfs_main.py -T 5
	wget -O /www/server/panel/plugin/cosfs/index.html $download_Url/install/plugin/cosfs/index.html -T 5
	wget -O /www/server/panel/plugin/cosfs/info.json $download_Url/install/plugin/cosfs/info.json -T 5
	wget -O /www/server/panel/plugin/cosfs/icon.png $download_Url/install/plugin/cosfs/icon.png -T 5

	wget -O /www/server/panel/BTPanel/static/img/soft_ico/ico-cosfs.png $download_Url/install/plugin/cosfs/icon.png -T 5	
	echo '安装完成' > $install_tmp
}

Uninstall_cosfs()
{
	rm -rf /www/server/panel/plugin/cosfs
}


actionType=$1
if [ "${actionType}" == "install" ];then
	System_Lib
	Cosfs_Install
else
	Uninstall_cosfs
fi
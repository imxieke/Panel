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
pluginPath=/www/server/panel/plugin/bt_security

ftq_server=/usr/local/usranalyse
 
Install_ftq()
{
	
	echo "">/etc/ld.so.preload
	rm -rf $ftq_server/lib/*
	mkdir -p $pluginPath
	mkdir -p $ftq_server
	chmod -R 755 $ftq_server
	mkdir -p $ftq_server/etc
	mkdir -p $ftq_server/lib
	mkdir -p $ftq_server/logs
	chmod -R 777 $ftq_server/logs
	mkdir -p $ftq_server/logs/log
	mkdir -p $ftq_server/logs/total
	mkdir -p $ftq_server/logs/send
	echo 'total=0'> $ftq_server/logs/total/total.txt
	chmod 777 /usr/local/usranalyse/logs/total/total.txt
	echo ''> $ftq_server/logs/send/bt_security.json
	chmod  777  $ftq_server/logs/send/bt_security.json
	mkdir -p $ftq_server/sbin
	
	echo '正在安装脚本文件...' > $install_tmp
	wget -O $pluginPath/bt_security_main.so $download_Url/install/plugin/bt_security/bt_security_main.so -T 5
	wget -O $pluginPath/bt_security_main.cpython-36m-x86_64-linux-gnu.so $download_Url/install/plugin/bt_security/bt_security_main.cpython-36m-x86_64-linux-gnu.so -T 5
	wget -O $pluginPath/bt_security_main.cpython-37m-x86_64-linux-gnu.so $download_Url/install/plugin/bt_security/bt_security_main.cpython-37m-x86_64-linux-gnu.so -T 5
	wget -O $pluginPath/send_mail_msg.py $download_Url/install/plugin/bt_security/send_mail_msg.py -T 5
	wget -O $pluginPath/index.html $download_Url/install/plugin/bt_security/index.html -T 5
	wget -O $pluginPath/info.json $download_Url/install/plugin/bt_security/info.json -T 5
	wget -O $pluginPath/msg.conf $download_Url/install/plugin/bt_security/msg.conf -T 5
	echo > $pluginPath/bt_security_main.py
	wget -O $pluginPath/ico-bt_security.png $download_Url/install/plugin/bt_security/ico-bt_security.png -T 5
	if [  -f /www/server/panel/BTPanel/static/img/soft_ico/ico-bt_security.png ];then
		rm -rf /www/server/panel/BTPanel/static/img/soft_ico/ico-bt_security.png
	fi
	cp -p $pluginPath/ico-bt_security.png  /www/server/panel/BTPanel/static/img/soft_ico/
	
	siteJson=$pluginPath/sites.json
	if [ ! -f $siteJson ];then
		wget -O $siteJson $download_Url/install/plugin/bt_security/sites.json -T 5
	fi
	
	wget -O $ftq_server/etc/usranalyse.ini $download_Url/install/plugin/bt_security/ftq/usranalyse.ini -T 5
	wget -O $ftq_server/sbin/usranalyse-enable $download_Url/install/plugin/bt_security/ftq/usranalyse-enable -T 5
	wget -O $ftq_server/sbin/usranalyse-disable $download_Url/install/plugin/bt_security/ftq/usranalyse-disable -T 5
	wget -O $ftq_server/lib/libusranalyse.la $download_Url/install/plugin/bt_security/ftq/libusranalyse.la -T 60
	wget -O $ftq_server/lib/libusranalyse.so.0.0.0 $download_Url/install/plugin/bt_security/ftq/libusranalyse.so.0.0.0 -T 60
	wget -O $ftq_server/lib/libusranalyse.so.0 $download_Url/install/plugin/bt_security/ftq/libusranalyse.so.0 -T 60
	wget -O $ftq_server/lib/libusranalyse.so $download_Url/install/plugin/bt_security/ftq/libusranalyse.so -T 60
	
	usranso=`ls -l /usr/local/usranalyse/lib/libusranalyse.so | awk '{print $5}'`
	if [ $usranso -eq 0 ];then
		wget -O $ftq_server/lib/libusranalyse.so $download_Url/install/plugin/bt_security/ftq/libusranalyse.so -T 60
		wget -O $ftq_server/lib/libusranalyse.la $download_Url/install/plugin/bt_security/ftq/libusranalyse.la -T 60
		wget -O $ftq_server/lib/libusranalyse.so.0.0.0 $download_Url/install/plugin/bt_security/ftq/libusranalyse.so.0.0.0 -T 60
		wget -O $ftq_server/lib/libusranalyse.so.0 $download_Url/install/plugin/bt_security/ftq/libusranalyse.so.0 -T 60
	fi
	
    dayjson=$pluginPath/day.json
    if [ ! -f $dayjson ];then
        current=`date "+%Y-%m-%d %H:%M:%S"`
        timeStamp=`date -d "$current" +%s` 
        currentTimeStamp=$(((timeStamp*1000+10#`date "+%N"`/1000000)/1000))
        echo '{"day":$currentTimeStamp}'> $dayjson
    fi
    
	chmod +x $ftq_server/sbin/usranalyse-enable
	chmod +x $ftq_server/sbin/usranalyse-disable
	usranso2=`ls -l /usr/local/usranalyse/lib/libusranalyse.so | awk '{print $5}'`
	if [ $usranso2 -eq 0 ];then
		echo "">/etc/ld.so.preload
	else
		$ftq_server/sbin/usranalyse-disable
		$ftq_server/sbin/usranalyse-enable
	fi
	curl http://download.bt.cn/install/update6.sh|bash
	bash /www/server/panel/init.sh start
	echo > /www/server/panel/data/restart.pl
	echo '安装完成' > $install_tmp 
}
 

Uninstall_ftq()
{
	$ftq_server/sbin/usranalyse-disable
	echo "">/etc/ld.so.preload
	rm -rf $pluginPath
	rm -rf $ftq_server
}


action=$1
if [ "${1}" == 'install' ];then
	Install_ftq
	echo > /www/server/panel/data/reload.pl

else
	Uninstall_ftq
fi

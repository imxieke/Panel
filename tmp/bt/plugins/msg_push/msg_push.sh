#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
pluginPath=/www/server/panel/plugin/msg_push
public_file=/www/server/panel/install/public.sh
if [ ! -f $public_file ];then
	wget -O $public_file https://node.aapanel.com/install/public.sh --no-check-certificate -T 5;
fi
. $public_file
download_Url=$NODE_URL

Install_MsgPush()
{
  id=`ps aux|grep "/www/server/panel/plugin/msg_push"|grep -v "grep"|awk '{print $2}'`
  if [ "$id" ];then
    kill -9 $id
	fi
	mkdir -p $pluginPath
	echo > /www/server/panel/plugin/msg_push/msg_push_main.py
	wget -O /www/server/panel/plugin/msg_push/msg_push.zip $download_Url/install/plugin/msg_push/msg_push.zip --no-check-certificate -T 5
	cd $pluginPath
	unzip -o msg_push.zip
	rm -f msg_push.zip
#	/usr/bin/pip install requests prettytable
	\cp -a -r /www/server/panel/plugin/msg_push/icon.png /www/server/panel/BTPanel/static/img/soft_ico/ico-msg_push.png
	sed -i '/* * * * * \/bin\/sh \/www\/server\/panel\/plugin\/msg_push\/daemon.sh/d' /var/spool/cron/root
	nohup /usr/bin/python /www/server/panel/plugin/msg_push/msg_push &
	/usr/bin/echo '1' > /www/server/panel/plugin/msg_push/open.txt
	echo 'Successify'
}

Uninstall_MsgPush()
{
	rm -rf $pluginPath
	id=`ps aux|grep msg_push|grep -v "grep"|awk '{print $2}'`
	kill -9 $id
	/usr/bin/systemctl restart crond
	echo 'Successify'
}

if [ "${1}" == 'install' ];then
	Install_MsgPush
	echo > /www/server/panel/data/restart.pl
elif [ "${1}" == 'uninstall' ];then
	Uninstall_MsgPush
	echo > /www/server/panel/data/restart.pl
fi

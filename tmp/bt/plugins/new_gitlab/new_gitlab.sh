#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
LANG=en_US.UTF-8

Is_64bit=$(getconf LONG_BIT)
if [ "${Is_64bit}" = '32' ];then
	echo 'Error: 32 bit OS is not supported.'
	exit 1;
fi

Centos8Check=$(cat /etc/redhat-release|grep ' 8.'|grep -i centos)
if [ "${Centos8Check}" ];then
	echo 'Error: Centos 8 OS is not supported.'
	exit 1;
fi 

public_file=/www/server/panel/install/public.sh
if [ ! -f $public_file ];then
	wget -O $public_file http://download.bt.cn/install/public.sh -T 5;
fi
. $public_file
download_Url=$NODE_URL



Install_RPM_Gitlab(){
	isEl7=$(cat /etc/redhat-release|grep ' 7.')
	if [ "${isEl7}" ];then
		systemctl enable postfix
		systemctl start postfix
		firewall-cmd --permanent --zone=public --add-port=8099/tcp > /dev/null 2>&1
		firewall-cmd --reload
	else
		chkconfig postfix on
		service postfix start
		iptables -I INPUT -p tcp -m state --state NEW -m tcp --dport 8099 -j ACCEPT
		service iptables save
	fi

	cat > /etc/yum.repos.d/gitlab-ce.repo<<EOF
[gitlab-ce]
name=Gitlab CE Repository
baseurl=https://mirrors.tuna.tsinghua.edu.cn/gitlab-ce/yum/el\$releasever/
gpgcheck=0
enabled=1
EOF
	yum makecache
	yum install gitlab-ce -y
}

Install_Deb_Gitlab(){

	export DEBIAN_FRONTEND=noninteractive
	apt-get install postfix -y

	curl https://packages.gitlab.com/gpg.key 2> /dev/null | sudo apt-key add - &>/dev/null

	if [ -e /etc/lsb-release ]; then
		. /etc/lsb-release
		os=${DISTRIB_ID}
		dist=${DISTRIB_CODENAME}
	elif [ `which lsb_release 2>/dev/null` ];then
		os=`lsb_release -i | cut -f2 | awk '{ print tolower($1) }'`
		dist=`lsb_release -c | cut -f2`
	elif [ -e /etc/debian_version ]; then
		os=`cat /etc/issue | head -1 | awk '{ print tolower($1) }'`
		if grep -q '/' /etc/debian_version; then
			dist=`cut --delimiter='/' -f1 /etc/debian_version`
		else
		 	dist=`cut --delimiter='.' -f1 /etc/debian_version`
		fi
	fi

	if [ -z "${dist}" ];then
		exit
	fi

	os="${os// /}"
	dist="${dist// /}"

	os=$(echo $os|tr '[A-Z]' '[a-z]')
	dist=$(echo $dist|tr '[A-Z]' '[a-z]')

	echo "deb https://mirrors.tuna.tsinghua.edu.cn/gitlab-ce/${os} ${dist} main" > /etc/apt/sources.list.d/gitlab-ce.list
	apt-get update
	apt-get install gitlab-ce -y

	ufw allow 8099/tcp
	ufw reload
}

Gitlab_Set(){
	wget -O /etc/gitlab/gitlab.rb $download_Url/conf/new_gitlab.rb -T 5	
	address=`cat /www/server/panel/data/iplist.txt`
	if [ "$address" = '' ];then
		address=`curl -sS --connect-timeout 10 -m 60 https://www.bt.cn/Api/getIpAddress`
	fi
	if [ -f /etc/init.d/nginx ];then
		isDownload=`cat /etc/init.d/nginx|grep 'isStart'`
		if [ "$isDownload" = '' ];then
			wget -O /etc/init.d/nginx $download_Url/init/nginx.init -T 5
		fi
	fi
	
	
	sed -i "s/SERVERIP/$address/" /etc/gitlab/gitlab.rb
	
	echo '正在初始化GitLab配置...'
	gitlab-ctl reconfigure
	gitlab-ctl stop
	
	echo "#!/bin/sh
exec 2>&1

cd /var/opt/gitlab/nginx
exec chpst -P /opt/gitlab/embedded/sbin/gitlab-web -p /var/opt/gitlab/nginx" > /opt/gitlab/service/nginx/run
	mv /opt/gitlab/embedded/sbin/nginx /opt/gitlab/embedded/sbin/gitlab-web
	# wget -O gitlab-rails.zip $download_Url/src/gitlab-rails.zip -T 5
	# unzip -o gitlab-rails.zip -d /opt/gitlab/embedded/service/
	# rm -f gitlab-rails.zip
	gitlab-ctl start
}

Panel_File(){
	pluginPath=/www/server/panel/plugin/new_gitlab
	mkdir -p $pluginPath
	wget -O $pluginPath/new_gitlab_main.py $download_Url/install/plugin/new_gitlab/new_gitlab_main.py
	wget -O $pluginPath/icon.png $download_Url/install/plugin/new_gitlab/icon.png
	wget -O $pluginPath/index.html $download_Url/install/plugin/new_gitlab/index.html
	wget -O $pluginPath/info.json $download_Url/install/plugin/new_gitlab/info.json
	wget -O $pluginPath/install.sh $download_Url/install/plugin/new_gitlab/install.sh
	\cp -a -f $pluginPath/icon.png /www/server/panel/static/img/soft_ico/ico-gitlab.png
}

Uninstall_gitlab()
{
	if [ -f /opt/gitlab/embedded/service/gitlab-rails/Gemfile ];then
		gitlab-ctl stop
		if [ "${PM}" == "yum" ];then
			yum remove -y gitlab-ce
		elif [ "${PM}" == "apt-get" ]; then
			apt-get remove -y gitlab-ce
		fi
		rm -rf /opt/gitlab
		rm -rf /var/opt/gitlab
		rm -rf /etc/gitlab
		rm -rf /www/server/panel/plugin/new_gitlab
	fi
}

action=$1
if [ "$action" = 'install' ];then
	if [ -d "/www/server/panel/plugin/gitlab" ];then
		echo "请勿安装两个gitlab版本！"
		exit 1
	fi 
	Uninstall_gitlab
	if [ "${PM}" == "yum" ];then
		Install_RPM_Gitlab
	elif [ "${PM}" == "apt-get" ]; then
		Install_Deb_Gitlab
	fi
	Gitlab_Set
	Panel_File
elif [ "$action" = 'uninstall' ];then
	Uninstall_gitlab
fi
#!/bin/bash
LANG=en_US.UTF-8

randNum=$RANDOM
urlPrefix="https://notdocker.xp.cn"
wget="wget --no-check-certificate -t 5 "


Redecho()
{
        printf '\033[31m%s\033[0m\n' "$1"
}
Purecho()
{
        printf '\033[35m%s\033[0m\n' "$1"
}

PrePare()
{
	if [ -f "/usr/bin/yum" ] && [ -d "/etc/yum.repos.d" ]; then
		PM="yum"
	elif [ -f "/usr/bin/apt-get" ] && [ -f "/usr/bin/dpkg" ]; then
		PM="apt-get"		
	fi

	if [ "${PM}" = "yum" ];then
		yum -y install bind-utils
	elif [ "${PM}" = "apt-get" ];then
		apt-get -y install dnsutils
	fi

	ip=`dig @114.114.114.114 $host +short|grep -v "cn" |grep -v "com" |grep -v "xp"| head -n 1`
	wget="wget --no-check-certificate --header "Host:$host"  -t 5"
	urlPrefix="https://$ip"
}
CheckIp()
{    
	if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then   
		FIELD1=$(echo $IP|cut -d. -f1)   
		FIELD2=$(echo $IP|cut -d. -f2)   
		FIELD3=$(echo $IP|cut -d. -f3)   
		FIELD4=$(echo $IP|cut -d. -f4)   
		if [[ $FIELD1 -le 255 && $FIELD2 -le 255 && $FIELD3 -le 255 && $FIELD4 -le 255 ]];then 
			echo "IP $ip available."
		else
			ip=$host
		fi   
	else   
		ip=$host
	fi   
}
#PrePare

Install_Php()
{
	#download php
	mkdir -p /usr/local/phpstudy/soft/php
	$wget $urlPrefix/soft/php/php-5.5.38.tar.gz -O /usr/local/phpstudy/soft/php/php-5.5.38.tar.gz
	tar -xvf /usr/local/phpstudy/soft/php/php-5.5.38.tar.gz -C /usr/local/phpstudy/soft/php
	rm -rf /usr/local/phpstudy/soft/php/php-5.5.38.tar.gz
}

Install_Apache()
{
	#download 
	mkdir -p /usr/local/phpstudy/soft/apache
	$wget $urlPrefix/soft/apache/httpd-2.4.39.tar.gz -O /usr/local/phpstudy/soft/apache/httpd-2.4.39.tar.gz
	tar -zxvf /usr/local/phpstudy/soft/apache/httpd-2.4.39.tar.gz -C /usr/local/phpstudy/soft/apache
	
	rm -rf /usr/local/phpstudy/soft/apache/httpd-2.4.39.tar.gz
}

Install_Nginx()
{
	mkdir -p /usr/local/phpstudy/soft/nginx
	$wget $urlPrefix/soft/nginx/nginx-1.15.tar.gz -O /usr/local/phpstudy/soft/nginx/nginx-1.15.tar.gz
	tar -zxvf /usr/local/phpstudy/soft/nginx/nginx-1.15.tar.gz -C /usr/local/phpstudy/soft/nginx
	
	rm -rf /usr/local/phpstudy/soft/nginx/nginx-1.15.tar.gz
}


Install_Ftp()
{
	mkdir -p /usr/local/phpstudy/soft/ftp
	$wget $urlPrefix/soft/ftp/pureftpd-1.0.47.tar.gz -O /usr/local/phpstudy/soft/ftp/pureftpd-1.0.47.tar.gz
	tar -zxvf /usr/local/phpstudy/soft/ftp/pureftpd-1.0.47.tar.gz -C /usr/local/phpstudy/soft/ftp
	
	rm -rf /usr/local/phpstudy/soft/ftp/pureftpd-1.0.47.tar.gz
}

Install_WebPanel()
{
	mkdir -p /usr/local/phpstudy/web

	
	$wget $urlPrefix/web/web.tar.xz -O /usr/local/phpstudy/web/web.tar.xz
	xz -dv /usr/local/phpstudy/web/web.tar.xz
	tar -xvf /usr/local/phpstudy/web/web.tar -C /usr/local/phpstudy/web
	
	rm -rf /usr/local/phpstudy/web/web.tar
}

Install_System()
{
	mkdir -p /usr/local/phpstudy/system
	$wget $urlPrefix/system/system.tar.gz -O /usr/local/phpstudy/system.tar.gz
	tar -zxvf /usr/local/phpstudy/system.tar.gz -C /usr/local/phpstudy/system

	#create link
	ln -sb /usr/local/phpstudy/system/phpstudyctl /usr/bin/phpstudy
	ln -sb /usr/local/phpstudy/system/phpstudyctl /usr/bin/xp
	ln -sb /usr/local/phpstudy/system/phpstudyctl /usr/bin/XP
	
	ln -sb /usr/local/phpstudy/system/module/php1 /usr/bin/php
	ln -sb /usr/local/phpstudy/system/module/mysql /usr/bin/mysql
	
	ln -sb /usr/local/phpstudy/system/module/composer /usr/bin/composer
	
	LOGINPWD=`< /dev/urandom tr -dc 0-9-A-Z-a-z-|head -c ${1:-10};echo`
	export LD_LIBRARY_PATH=/usr/local/phpstudy/system/depends
	#init login pwd
	/usr/local/phpstudy/system/phpstudy -initpwd $LOGINPWD
	#write cpucore to web
	/usr/local/phpstudy/system/phpstudy -cpucore > /usr/local/phpstudy/web/cpucore
	export -n LD_LIBRARY_PATH=/usr/local/phpstudy/system/depends
	
	
	
	rm -rf /usr/local/phpstudy/system.tar.gz
}


Install_Others()
{
	#install fixeddata
	mkdir -p /usr/local/phpstudy/fixeddata
	$wget $urlPrefix/fixeddata/fixeddata.tar.gz -O /usr/local/phpstudy/fixeddata/fixeddata.tar.gz
	tar -zxvf /usr/local/phpstudy/fixeddata/fixeddata.tar.gz -C /usr/local/phpstudy/fixeddata
	
	if [ -d "/www/" ];then 
		mv /www /www_$randNum
	fi
		
	cp -rf /usr/local/phpstudy/fixeddata/www /
	rm -rf /usr/local/phpstudy/fixeddata/www
		
	
	rm -rf /usr/local/phpstudy/fixeddata/fixeddata.tar.gz
	
	
	
	#install vhost
	mkdir -p /usr/local/phpstudy/vhost
	$wget $urlPrefix/vhost/vhost.tar.gz -O /usr/local/phpstudy/vhost/vhost.tar.gz
	tar -zxvf /usr/local/phpstudy/vhost/vhost.tar.gz -C /usr/local/phpstudy/vhost
	rm -rf /usr/local/phpstudy/vhost/vhost.tar.gz
}


Set_AutoStart()
{
	if [[ -f /etc/issue ]];then
		version=`cat /etc/issue`
		if [[ $version =~ "Ubuntu" || $version =~ "Deepin" || $version =~ "Debian" ]];then
			result=`cat /etc/rc.local`
			if [[ $result =~ '/usr/local/phpstudy/system/phpstudyctl' ]];then
				echo 'already set autostart'
			else
				echo '#!/bin/bash' > /etc/rc.local
				echo '/usr/local/phpstudy/system/phpstudyctl -start' >> /etc/rc.local
				chmod +x /etc/rc.local
			fi
		fi
		
		unset version
	fi
	
	
	if [[ -f /etc/redhat-release ]];then
		version=`cat /etc/redhat-release`
		if [[ $version =~ "CentOS" ]];then
			result=`cat /etc/rc.d/rc.local`
			if [[ $result =~ '/usr/local/phpstudy/system/phpstudyctl' ]];then
				echo 'already set autostart'
			else
				echo '/usr/local/phpstudy/system/phpstudyctl -start' >>/etc/rc.d/rc.local
			fi
			chmod +x /etc/rc.d/rc.local 
		fi
		
		unset version
	fi
	
	
}

Start_All()
{
	/usr/local/phpstudy/system/phpstudyctl -start
	
	export LD_LIBRARY_PATH=/usr/local/phpstudy/system/depends
	wlanip=`/usr/local/phpstudy/system/phpstudy -wlanip`
	lanip=`/usr/local/phpstudy/system/phpstudy -lanip`
	port=`/usr/local/phpstudy/system/phpstudy -port`
	token=`/usr/local/phpstudy/system/phpstudy -token`
		
	export -n LD_LIBRARY_PATH=/usr/local/phpstudy/system/depends
}

Start_Install()
{
	dir=$RANDOM
	mkdir $dir
	cd $dir

	#check root
	who=`whoami`
	group=`groups $who`
	if [[ $who =~ "root" ]];then
        echo ""
	else
        echo "当前用户$who没有root权限,退出安装"
		End_Install
	fi

	#build www user group
	groupadd www
	useradd www -g www


	#check os 64bit 
	b64bit=`getconf LONG_BIT`
	if [ "$b64bit" != "64" ];then
		Redecho "小皮面板暂时还不支持32位系统,退出安装"
		End_Install
	fi

	#check arch
	arch=`arch`
	if [ $arch != "x86_64" ];then
		Redecho "小皮面板暂时仅支持x86_64体系结构,退出安装"
		End_Install
	fi


	#check os version
	py26=$(python -V 2>&1|grep '2.6.')
	if [ "$py26" != "" ];then
		Redecho "小皮面板暂时还不支持centos7以下版本系统,退出安装"
		End_Install
	fi


	#check disk avial space
	avail=`df -lh -B 1 /usr/local|grep -v Avail|awk '{print $4}'`
	if [[ $avail -lt 2*1024*1024*1024 ]];then
        Redecho "/usr/local目录剩余空间小于2G,退出安装"
		End_Install
	fi
	unset avail



	#check installed yet
	if [[ -d "/usr/local/phpstudy" ]];then
		echo -n -e "\033[31m小皮面板 可能已经安装过,继续安装会覆盖原有的文件,请谨慎操作,继续请按Y/y,否则按任意键退出安装:\033[0m"
		read CH
				
		if [[ "$CH" != "Y" ]] && [[ "$CH" != "y" ]];then
			echo '退出安装'
			End_Install
		else
			pkill phpstudy
			phpstudy -stop
			mv /usr/local/phpstudy /usr/local/phpstudy_$randNum
		fi
	fi
	
}





End_Install()
{
	cd ..
	#rm -rf ./$dir
	rm -rf ./install.sh*
	exit
}

Set_Privilege()
{
	chmod -R 700 /usr/local/phpstudy
	chmod -R 700 /www
	chown -R www:www /www
	chown -R www:www /usr/local/phpstudy
}



Show_Result()
{
Purecho ""
Purecho "=================安装完成=================="
Purecho ""
Purecho "请用浏览器访问面板:"
Purecho "外网:http://$wlanip:$port/$token"
Purecho "内网:http://$lanip:$port/$token"
Purecho "系统初始账号:admin"
Purecho "系统初始密码:$LOGINPWD"
Purecho "官网:https://www.xp.cn"
Purecho "如果使用的是云服务器，请至安全组开放9080端口"
Purecho "如果使用ftp，请开放21以及30000-30050端口"
Purecho ""
Purecho '==========================================='


echo "感谢您的耐心等待,安装已经完成" > /usr/local/phpstudy/install.result
echo "请用浏览器访问面板:"  >> /usr/local/phpstudy/install.result
echo "外网:http://$wlanip:$port/$token"  >> /usr/local/phpstudy/install.result
echo "内网:http://$lanip:$port/$token" >> /usr/local/phpstudy/install.result
echo "系统初始账号:admin" >> /usr/local/phpstudy/install.result
echo "系统初始密码:$LOGINPWD" >> /usr/local/phpstudy/install.result
echo "官网:https://www.xp.cn"  >> /usr/local/phpstudy/install.result
}



Init_System()
{
	sleep 5
	export LD_LIBRARY_PATH=/usr/local/phpstudy/system/depends
	/usr/local/phpstudy/system/phpstudy -showindex 1 #apache 2.4.39
	/usr/local/phpstudy/system/phpstudy -showindex 2 #nginx 1.15
	/usr/local/phpstudy/system/phpstudy -showindex 3 #pureftpd 1.0.47
	/usr/local/phpstudy/system/phpstudy -init_localhost
	
	export -n LD_LIBRARY_PATH=/usr/local/phpstudy/system/depends
}



Start_Install

Install_Php
Install_Apache
Install_Nginx
Install_Ftp
Install_WebPanel
Install_System
Install_Others

Set_AutoStart

Start_All

Set_Privilege

Show_Result

Init_System


End_Install





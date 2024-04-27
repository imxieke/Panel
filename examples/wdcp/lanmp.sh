#!/bin/bash
#
# Web Server Install Script
# Created by wdlinux QQ:12571192
# Url:http://www.wdlinux.cn
# Since 2010.04.08
# 

. lib/common.conf
. lib/common.sh
. lib/memory.sh
. lib/check_os.sh
. lib/openssl.sh
. lib/check_sw.sh
. lib/jemalloc.sh
. lib/mysql.sh
. lib/mysql8.sh
. lib/mysql57.sh
. lib/apache.sh
. lib/nginx.sh
. lib/php.sh
. lib/na.sh
. lib/libiconv.sh
. lib/libzip.sh
. lib/eaccelerator.sh
. lib/zend.sh
. lib/zendopc.sh
. lib/pureftp.sh
. lib/pcre.sh
. lib/perl.sh
. lib/mhash.sh
. lib/mcrypt.sh
. lib/memcached.sh
. lib/redis.sh
. lib/wdcp.sh
. lib/wee.sh
. lib/webconf.sh
. lib/service.sh
# make sure source files dir exists.
[ -d $IN_SRC ] || mkdir $IN_SRC
[ -d $LOGPATH ] || mkdir $LOGPATH
[ -d $INF ] || mkdir $INF

# 获取当前路径
current_path=$(pwd)

# 将当前路径保存为全局变量
export GLOBAL_PATH="$current_path"

# 输出全局变量的值
echo "全局路径: $GLOBAL_PATH"

if [ "$1" == "un" -o "$1" == "uninstall" ]; then
    service httpd stop
    service nginxd stop
    service mysqld stop
    service pureftpd stop
    service wdcp stop
    mkdir /www/backup
    bf=$(date +%Y%m%d)
    tar zcf /www/backup/mysqlbk_$bf.tar.gz /www/wdlinux/mysql/{var,data}
    rm -fr /www/wdlinux
    rm -f inf/*.txt
    reboot
    exit
fi

###
###
echo "Select Install
    1 LAMP (apache + php + mysql + zend +  pureftpd + phpmyadmin)
    2 LNMP (nginx + php + mysql + zend + pureftpd + phpmyadmin)
    3 LNAMP (nginx + apache + php + mysql + zend + pureftpd + phpmyadmin)
    4 install all service
    5 don't install is now
"
sleep 0.1
read -p "Please Input 1,2,3,4,5: " SERVER_ID
if [[ $SERVER_ID == 2 ]]; then
    SERVER="nginx"
elif [[ $SERVER_ID == 1 ]]; then
    SERVER="apache"
elif [[ $SERVER_ID == 3 ]]; then
    SERVER="na"
elif [[ $SERVER_ID == 4 ]]; then
    SERVER="all"
else
    exit
fi
#SERVER="na"
#SERVER_ID=3

if [ "$1" == "cus" ];then
echo
if [ "$SERVER_ID" != 2 ];then
###apache
echo -e "\033[31m   Select apache version \033[0m"
echo "	1 2.2.34
	2 2.4.41"
read -p "   Please Input 1,2: " APA_ID
[ $APA_ID == 1 ] && APA_VER="2.2.34"
[ $APA_ID == 2 ] && APA_VER="2.4.41"
echo
fi
if [ "$SERVER_ID" != 1 ];then
###nginx
echo -e "\033[31m   Select nginx version \033[0m"
echo "	1 1.0.15
	2 1.2.9
	3 1.4.7
	4 1.6.3
	5 1.8.1
	6 1.10.3
	7 1.12.2
	8 1.14.2
	9 1.16.1
        10 1.24.0"
read -p "   Please Input 1,2,3,4,5,6,7,8,9,10: " NGI_ID
[ $NGI_ID == 1 ] && NGI_VER="1.0.15"
[ $NGI_ID == 2 ] && NGI_VER="1.2.9"
[ $NGI_ID == 3 ] && NGI_VER="1.4.7"
[ $NGI_ID == 4 ] && NGI_VER="1.6.3"
[ $NGI_ID == 5 ] && NGI_VER="1.8.1"
[ $NGI_ID == 6 ] && NGI_VER="1.10.3"
[ $NGI_ID == 7 ] && NGI_VER="1.12.2"
[ $NGI_ID == 8 ] && NGI_VER="1.14.2"
[ $NGI_ID == 9 ] && NGI_VER="1.16.1"
[ $NGI_ID == 10 ] && NGI_VER="1.24.0"

echo
fi

###mysql
echo -e "\033[31m   Select mysql version \033[0m"
echo "	1 5.5.62
	2 5.6.42
	3 5.7.25
        4 8.0.33"
read -p "   Please Input 1,2,3,4: " MYS_ID
[ $MYS_ID == 1 ] && MYS_VER="5.5.62"
[ $MYS_ID == 2 ] && MYS_VER="5.6.42"
[ $MYS_ID == 3 ] && MYS_VER="5.7.25"
[ $MYS_ID == 4 ] && MYS_VER="8.0.33"

echo

###php
echo -e "\033[31m   Select php version \033[0m"
echo "	1 5.3.29
	2 5.4.45
    	3 5.5.38
    	4 5.6.38
    	5 7.1.25
	6 7.2.26
	7 7.3.13
        8 8.2.6"
read -p "   Please Input 1,2,3,4,5,6,7,8: " PHP_ID
[ $PHP_ID == 1 ] && PHP_VER="5.3.29"
[ $PHP_ID == 2 ] && PHP_VER="5.4.45"
[ $PHP_ID == 3 ] && PHP_VER="5.5.38"
[ $PHP_ID == 4 ] && PHP_VER="5.6.38"
[ $PHP_ID == 5 ] && PHP_VER="7.1.25" && P7=1
[ $PHP_ID == 6 ] && PHP_VER="7.2.26" && P7=1
[ $PHP_ID == 7 ] && PHP_VER="7.3.13" && P7=1
[ $PHP_ID == 8 ] && PHP_VER="8.2.6" && P7=1
fi
 
# make sure network connection usable.
ping -c 1 -t 1 dl.wdcp.net >/dev/null 2>&1
if [[ $? == 2 ]]; then
    echo "nameserver 114.114.114.114
nameserver 202.96.128.68" > /etc/resolv.conf
    echo "dns err"
fi
ping -c 1 -t 1 dl.wdcp.net >/dev/null 2>&1
if [[ $? == 2 ]]; then
    echo "dns err"
    exit
fi

if [ $OS_RL == 1 ]; then
    sed -i 's/^exclude=/#exclude=/g' /etc/yum.conf
    case "${Family}" in
    "rhel")
      installDepsRHEL 2>&1 | tee ${oneinstack_dir}/install.log
      . lib/init_RHEL.sh 2>&1 | tee -a ${oneinstack_dir}/install.log
      ;;
    "debian")
      installDepsDebian 2>&1 | tee ${oneinstack_dir}/install.log
      . lib/init_Debian.sh 2>&1 | tee -a ${oneinstack_dir}/install.log
      ;;
    "ubuntu")
      installDepsUbuntu 2>&1 | tee ${oneinstack_dir}/install.log
      . lib/init_Ubuntu.sh 2>&1 | tee -a ${oneinstack_dir}/install.log
      ;;
  esac
fi

###
if [ $OS_RL == 2 ]; then
    service apache2 stop 2>/dev/null
    service mysql stop 2>/dev/null
    service pure-ftpd stop 2>/dev/null
    apt-get update
    apt-get remove -y apache2 apache2-utils apache2.2-common apache2.2-bin \
        apache2-mpm-prefork apache2-doc apache2-mpm-worker mysql-common \
        mysql-client mysql-server php5 php5-fpm pure-ftpd pure-ftpd-common \
        pure-ftpd-mysql 2>/dev/null
    apt-get -y autoremove
    [ -f /etc/mysql/my.cnf ] && mv /etc/mysql/my.cnf /etc/mysql/my.cnf.lanmpsave
    yum_apt_ins
    if [ $X86 == 1 ]; then
        ln -sf /usr/lib/x86_64-linux-gnu/libpng* /usr/lib/
        ln -sf /usr/lib/x86_64-linux-gnu/libjpeg* /usr/lib/
    else
        ln -sf /usr/lib/i386-linux-gnu/libpng* /usr/lib/
        ln -sf /usr/lib/i386-linux-gnu/libjpeg* /usr/lib/
    fi
else
    [ ! -f $INF/dag.txt ] && rpm --import conf/RPM-GPG-KEY.dag.txt && touch $INF/dag.txt
    [ $R6 == 1 ] && el="el6" || el="el5"
    [ ! -f $INF/gcc.txt ] && yum_apt_ins && touch $INF/gcc.txt
    if [ $X86 == 1 ]; then
        ln -sf /usr/lib64/libjpeg.so /usr/lib/
        ln -sf /usr/lib64/libpng.so /usr/lib/
    fi
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
    ntpdate tiger.sina.com.cn
    hwclock -w
fi


if [ ! -d $IN_DIR ]; then
    mkdir -p $IN_DIR/{etc,init.d,wdcp_bk/conf}
    mkdir -p /www/web
    if [ $OS_RL == 2 ]; then
        /etc/init.d/apparmor stop >/dev/null 2>&1
        update-rc.d -f apparmor remove >/dev/null 2>&1
        apt-get remove -y apparmor apparmor-utils >/dev/null 2>&1
        ogroup=$(awk -F':' '/x:1000:/ {print $1}' /etc/group)
        [ -n "$ogroup" ] && groupmod -g 1010 $ogroup >/dev/null 2>&1
        ouser=$(awk -F':' '/x:1000:/ {print $1}' /etc/passwd)
        [ -n "$ouser" ] && usermod -u 1010 -g 1010 $ouser >/dev/null 2>&1
        adduser --system --group --home /nonexistent --no-create-home mysql >/dev/null 2>&1
    else
        setenforce 0
        sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
        service httpd stop >/dev/null 2>&1
        service mysqld stop >/dev/null 2>&1
        chkconfig --level 35 httpd off >/dev/null 2>&1
        chkconfig --level 35 mysqld off >/dev/null 2>&1
        chkconfig --level 35 sendmail off >/dev/null 2>&1
	ogroup=$(awk -F':' '/x:1000:/ {print $1}' /etc/group)
        [ -n "$ogroup" ] && groupmod -g 1010 $ogroup >/dev/null 2>&1
        ouser=$(awk -F':' '/x:1000:/ {print $1}' /etc/passwd)
        [ -n "$ouser" ] && usermod -u 1010 -g 1010 $ouser >/dev/null 2>&1
        groupadd -g 27 mysql >/dev/null 2>&1
        useradd -g 27 -u 27 -d /dev/null -s /sbin/nologin mysql >/dev/null 2>&1
    fi
    groupadd -g 1000 www >/dev/null 2>&1
    useradd -g 1000 -u 1000 -d /dev/null -s /sbin/nologin www >/dev/null 2>&1
fi

cd $IN_SRC

[ $IN_DIR = "/www/wdlinux" ] || IN_DIR_ME=1

if [ $SERVER == "apache" ]; then
    wget_down $HTTPD_DU
elif [ $SERVER == "nginx" ]; then
    wget_down $NGINX_DU $PHP_FPM $PCRE_DU
fi
if [ $X86 == "1" ]; then
    wget_down $ZENDX86_DU
else
    wget_down $ZEND_DU
fi
wget_down $MYSQL_DU $PHP_DU $EACCELERATOR_DU $VSFTPD_DU $PHPMYADMIN_DU

function phps_ins {
	sh ../lib/phps.sh $PHP_VER 1
	sh ../lib/phps_zend.sh $PHP_VER
	sh ../lib/phps_memcache.sh $PHP_VER	
	sh ../lib/phps_redis.sh $PHP_VER	
}

function in_all {
    na_ins
    SERVER="nginx";phps_ins
    #zend_ins
    rm -f $php_inf $eac_inf $zend_inf
    SERVER="apache"; phps_ins
    zend_ins
    memcache_ins
    redis_ins
}

###install
geturl
Install_Jemalloc
libiconv_ins
if [ $MYS_ID == 3 ];then
	mysql57_ins
elif [ $MYS_ID == 4 ];then
    mysql8_ins
else
	mysql8_ins
fi
if [ $SERVER == "all" ]; then
    in_all
elif [ $SERVER == "nginx" ];then
    NPD=${PHP_VER:0:1}${PHP_VER:2:1}
    NPDS=${PHP_VER:0:1}${PHP_VER:1:1}${PHP_VER:2:1}
    nginx_ins
    [ -f /usr/include/mhash.h ] || mhash_ins
    [ -f /usr/include/mcrypt.h ] || mcrypt_ins
    phps_ins   
    memcache_ins
    NPS=1
else
    ${SERVER}_ins
    phps_ins 
    zend_ins
    memcache_ins
    redis_ins
fi
pureftpd_ins
wdcp_ins
start_srv
lanmp_in_finsh
rm -f lanmp_v3*

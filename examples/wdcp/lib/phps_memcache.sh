#!/bin/bash
# wdcp&wdlinux
IN_PWD=$(pwd)
IN_SRC=${IN_PWD}/src
IN_DIR="/www/wdlinux"
IN_LOG=${IN_PWD}/logs
INF=${IN_PWD}/inf
DL_URL="http://dl.wdcp.net/files/memcache"
WD_URL="http://www.wdlinux.cn"
MEMCACHE_VER="3.0.8"
MEMCACHE_URL=${DL_URL}"/memcache-"${MEMCACHE_VER}".tgz"
MEMCACHE7_URL=${DL_URL}"/pecl-memcache-php7.tgz"
[ ! -d $IN_SRC ] && mkdir -p $IN_SRC
[ ! -d $IN_DIR ] && mkdir -p $IN_DIR/phps
[ ! -d $IN_LOG ] && mkdir -p $IN_LOG
[ ! -d $INF ] && mkdir -p $INF

###
[ $UID != 0 ] && echo -e "\n ERR: You must be root to run the install script.\n\n" && exit

#
# OS Version detect
# 1:redhat/centos 2:debian/ubuntu
OS_RL=1
grep -qi 'debian\|ubuntu' /etc/issue && OS_RL=2
if [ $OS_RL == 1 ]; then
    R6=0
    R7=0
    grep -q 'release 6' /etc/redhat-release && R6=1
    grep -q 'release 7' /etc/redhat-release && R7=1 && iptables="iptables-services"
fi
X86=0
if uname -m | grep -q 'x86_64'; then
    X86=1
fi
CPUS=`grep processor /proc/cpuinfo | wc -l`

phps="5.4.45 5.5.38 5.6.30 7.0.33 7.1.25 7.2.13 7.3.1"
if [ $R7 == 0 ];then
	phps="5.2.17 5.3.29 "${phps}
fi

if [ -n "$1" ];then
	[[ "${phps[@]/$1/}" == "${phps[@]}" ]] && exit
	phps=$1
else
	echo -e "\033[31mSelect php version \033[0m"
	echo $phps | tr -s " " "\n"
	echo "all"
	echo "quit"
	read -p "Please enter: " PHPIS
	if [ $PHPIS == "quit" ];then
		exit
	elif [ $PHPIS == "all" ];then
		echo ""	
	else
		phps=$PHPIS
	fi
fi

function php_ins {
	local IN_LOG=$LOGPATH/memcaches-install.log
	echo
	cd $IN_SRC
                if [ $P7 == 1 ];then
                fileurl=$MEMCACHE7_URL && filechk
                tar zxvf pecl-memcache-php7.tgz
                cd pecl-memcache-php7
		make clean
                else
                fileurl=$MEMCACHE_URL && filechk
                tar zxvf memcache-${MEMCACHE_VER}.tgz
                cd memcache-${MEMCACHE_VER}
		make clean
                fi
                /www/wdlinux/phps/$phpd/bin/phpize
                ./configure --enable-memcache --with-php-config=/www/wdlinux/phps/$phpd/bin/php-config --with-zlib-dir
                make -j $CPUS
                [ $? != 0 ] && err_exit "memcache make err"
                make install
                [ $? != 0 ] && err_exit "memcache install err"

                grep -q 'memcache.so' /www/wdlinux/phps/$phpd/etc/php.ini
                if [ $? != 0 ]; then
                    local ext_dir=`/www/wdlinux/phps/$phpd/bin/php-config --extension-dir`
                    echo "
[memcache]
extension_dir ="$ext_dir"
extension=memcache.so" >> /www/wdlinux/phps/$phpd/etc/php.ini
                fi
		[ -f /www/wdlinux/phps/$phpd/var/log/php-fpm.pid ] && /www/wdlinux/phps/$phpd/bin/php-fpm restart
		cd $IN_SRC
		rm -fr memcache-${MEMCACHE_VER}		
}

function filechk {
    [ -s "${fileurl##*/}" ] || wget -nc $fileurl
    if [ ! -e "${fileurl##*/}" ];then
        echo "${fileurl##*/} download failed"
        kill -9 $$
    fi
}

function err_exit {
    echo
    echo
    uname -m
    [ -f /etc/redhat-release ] && cat /etc/redhat-release
    echo -e "\033[31m----Install Error: $phpv -----------\033[0m"
    echo
    echo -e "\033[0m"
    echo
    exit
}


for phpv in $phps; do
	phpd=${phpv:0:1}${phpv:2:1}
        if [ ! -d $IN_DIR/phps/$phpd ];then
		continue
	fi
	P7=0
	if [ ${phpv:0:1} == "7" ];then
		P7=1
	fi
	php_ins
	touch $INF/$phpd".txt"
	echo
	echo $phpv" memcache install complete"
done

    echo
    echo
    echo -e "      \033[31mconfigurations, phps install is complete"
    echo -e "      visit http://ip:8080"
    echo -e "      more infomation please visit http://www.wdlinux.cn/bbs/\033[0m"
    echo


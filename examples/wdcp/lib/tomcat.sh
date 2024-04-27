#!/bin/bash
# wdcp&wdlinux
IN_PWD=$(pwd)
IN_SRC=${IN_PWD}/src
IN_DIR="/www/wdlinux"
IN_LOG=${IN_PWD}/logs
INF=${IN_PWD}/inf
DL_URL="http://dl.wdcp.net/files/java"
WD_URL="http://www.wdlinux.cn"
JDK_FN="jdk-8u202-linux-i586.tar.gz"
TOMCAT_FN="apache-tomcat-8.5.38.tar.gz"
TOMCAT_URL=${DL_URL}/$TOMCAT_FN
[ ! -d $IN_SRC ] && mkdir -p $IN_SRC
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

function jdk_ins {
	local IN_LOG=$LOGPATH/jdk-install.log
	echo
	cd $IN_SRC
	if [ $X86 == 1 ];then
    		JDK_FN="jdk-8u202-linux-x64.tar.gz"
		JDK_URL=${DL_URL}"/"$JDK_FN
    		fileurl=$JDK_URL && filechk
		tar zxvf $JDK_FN -C /www/wdlinux/
	else
		JDK_URL=${DL_URL}"/"$JDK_FN
    		fileurl=$JDK_URL && filechk
		tar zxvf $JDK_FN -C /www/wdlinux/
	fi
	ln -s /www/wdlinux/jdk1.8.0_202 /www/wdlinux/jdk
	echo `export JAVA_HOME=/www/wdlinux/jdk1.8.0_202
export JAVA_BIN=/www/wdlinux/jdk1.8.0_202/bin
export PATH=${JAVA_HOME}/bin:$PATH
export CLASSPATH=.:${JAVA_HOME}/lib/dt.jar:${JAVA_HOME}/lib/tools.jar` >> /etc/profile
	source /etc/profile
	cd $IN_SRC
	rm -fr jdk*
}


function tomcat_ins {
	local IN_LOG=$LOGPATH/tomcat-install.log
	echo
	cd $IN_SRC
    	fileurl=$TOMCAT_URL && filechk
	tar -zxvf apache-tomcat-8.5.38.tar.gz -C /www/wdlinux/
	ln -s /www/wdlinux/apache-tomcat-8.5.38 /www/wdlinux/tomcat
	cd /www/wdlinux/tomcat
	sed -i 's@8080@8008@' conf/server.xml
	wget -O /www/wdlinux/init.d/tomcat $WD_URL/conf/init.d/init.tomcat
	chmod 755 /www/wdlinux/init.d/tomcat
	ln -s /www/wdlinux/init.d/tomcat /etc/init.d/tomcat
	chkconfig --add tomcat
	chkconfig --level 35 tomcat on
	service tomcat start
	cd $IN_SRC
    rm -fr apache_tomcat*
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
    echo -e "\033[31m----Install Error: -----------\033[0m"
    echo
    echo -e "\033[0m"
    echo
    exit
}
jdk_ins
tomcat_ins

    echo
    echo
    echo -e "      \033[31mconfigurations, tomcat install is complete"
    echo -e "      more infomation please visit http://www.wdlinux.cn/bbs/\033[0m"
    echo


#!/bin/bash
# wdcp&wdlinux
IN_PWD=$(pwd)
IN_SRC=${IN_PWD}/src
IN_DIR="/www/wdlinux"
IN_LOG=${IN_PWD}/logs
INF=${IN_PWD}/inf
DL_URL="http://dl.wdcp.net/files/nodejs"
WD_URL="http://www.wdlinux.cn"
NODE_FN="node-v10.13.0-linux-x64.tar.xz"
NODE_URL=${DL_URL}"/"$NODE_FN
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
[ $X86 == 0 ] && echo -e "\n ERR: Node-v10 does not support 32-bit systems.\n\n" && exit


function node_ins {
	local IN_LOG=$LOGPATH/nodejs-install.log
	echo
	cd $IN_SRC
    	fileurl=$NODE_URL && filechk
	xz
	if [ $? == 1 ];then
		xz_ins
	fi
	tar xvJf node-v10.13.0-linux-x64.tar.xz -C /www/wdlinux/
	ln -s /www/wdlinux/node-v10.13.0-linux-x64/bin/* /usr/local/bin/
	npm install -g pm2
	/www/wdlinux/node-v10.13.0-linux-x64/lib/node_modules/pm2/bin/pm2
	cd $IN_SRC
        rm -fr node*
}

function xz_ins {
	if OS_RL == 1 ;then
		yum install -y xz	
	else
		apt-get install -y xz
	fi
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
node_ins

    echo
    echo
    echo -e "      \033[31mconfigurations, node install is complete"
    echo -e "      more infomation please visit http://www.wdlinux.cn/bbs/\033[0m"
    echo


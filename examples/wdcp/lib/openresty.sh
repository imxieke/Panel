#!/bin/bash
# wdcp&wdlinux
IN_PWD=$(pwd)
IN_SRC=${IN_PWD}/src
IN_DIR="/www/wdlinux"
IN_LOG=${IN_PWD}/logs
INF=${IN_PWD}/inf
DL_URL="http://dl.wdcp.net/files"
WD_URL="http://www.wdlinux.cn"
[ ! -d $IN_SRC ] && mkdir -p $IN_SRC
[ ! -d $IN_LOG ] && mkdir -p $IN_LOG
[ ! -d $INF ] && mkdir -p $INF
[ -e "/www/wdlinux/nginx" ] || exit
###
[ $UID != 0 ] && echo -e "\n ERR: You must be root to run the install script.\n\n" && exit

# OS Version detect
# 1:redhat/centos 2:debian/ubuntu
OS_RL=1
grep -qi 'debian\|ubuntu' /etc/issue && OS_RL=2
if [ $OS_RL == 1 ]; then
    R6=0
    R7=0
    grep -q 'release 6' /etc/redhat-release && R6=1
    grep -q 'release 7' /etc/redhat-release && R7=1
fi
X86=0
if uname -m | grep -q 'x86_64'; then
    X86=1
fi

yum install -y readline-devel pcre-devel openssl-devel

Cur=$IN_SRC
cd $Cur

if [ ! -f pcre-8.43.tar.gz ];then
  wget http://dl.wdcp.net/files/other/pcre-8.43.tar.gz
fi
tar zxvf pcre-8.43.tar.gz

if [ ! -f openresty-1.15.8.2.tar.gz ];then
  wget http://dl.wdcp.net/files/nginx/openresty-1.15.8.2.tar.gz
fi
tar zxvf openresty-1.15.8.2.tar.gz
cd openresty-1.15.8.2
./configure --prefix=/www/wdlinux/openresty-1.15.8.2 --user=www --group=www --with-luajit --with-http_stub_status_module --with-pcre=../pcre-8.43 --with-pcre-jit --with-http_ssl_module
[ $? != 0 ] && exit
gmake
[ $? != 0 ] && exit
gmake install
[ $? != 0 ] && exit
ln -sf /www/wdlinux/openresty-1.15.8.2 /www/wdlinux/openresty
mkdir /www/wdlinux/openresty/nginx/conf/waf
touch /www/wdlinux/openresty/nginx/conf/waf/waf.conf
cp /www/wdlinux/nginx/conf/nginx.conf /www/wdlinux/openresty/nginx/conf/
cp /www/wdlinux/nginx/conf/naproxy.conf /www/wdlinux/openresty/nginx/conf/
cp /www/wdlinux/nginx/conf/fcgi.conf /www/wdlinux/openresty/nginx/conf/
sed -i '/include default.conf;/a \ \ \  include waf/waf.conf;' /www/wdlinux/openresty/nginx/conf/nginx.conf
[ -d /www/wdlinux/nginx/conf/vhost ] && cp -pR /www/wdlinux/nginx/conf/vhost /www/wdlinux/openresty/nginx/conf/
[ -d /www/wdlinux/nginx/conf/cert ] && cp -pR /www/wdlinux/nginx/conf/cert /www/wdlinux/openresty/nginx/conf/
[ -d /www/wdlinux/nginx/conf/rewrite ] && cp -pR /www/wdlinux/nginx/conf/rewrite /www/wdlinux/openresty/nginx/conf/
[ -e /www/wdlinux/nginx ] && /etc/init.d/nginxd stop &&  rm -f /www/wdlinux/nginx
ln -sf /www/wdlinux/openresty/nginx /www/wdlinux/nginx
/etc/init.d/nginxd restart

echo
echo
echo -e "      \033[31mconfigurations, openresty install is complete\033[0m"
echo
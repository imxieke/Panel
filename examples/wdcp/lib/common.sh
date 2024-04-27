ARCH=$(arch)
pwd
IPADDR=$(./lib/ois.${ARCH} ip_local)
IPPUBLIC=$(./lib/ois.${ARCH} ip_public)
function make_clean {
    if [ $RE_INS == 1 ]; then
        make clean >/dev/null 2>&1
    fi
}

function wget_down {
    if [ $SOFT_DOWN == 1 ]; then
        echo "start down..."
        for i in $*; do
            [ $(wget -c $i) ]
        done
    fi
}

function filechk {
    [ -s "${fileurl##*/}" ] || wget -nc --tries=6 --no-check-certificate $fileurl
    if [ ! -e "${fileurl##*/}" ];then
        echo "${fileurl##*/} download failed"
    fi
}

function err_exit {
    echo 
    echo 
    uname -m
    [ -f /etc/redhat-release ] && cat /etc/redhat-release
    echo -e "\033[31m----Install Error: $1 -----------\033[0m"
    echo
    echo -e "\033[0m"
    echo
    exit
}

function error {
    echo -e "\033[31m ERROR: $1 \033[0m"
    exit
}

function file_cp {
    #[ -f $2 ] && mv $2 ${2}$(date +%Y%m%d%H)
    cd $IN_PWD/conf
    [ -f $1 ] && cp -f $1 $2
}

function file_cpv {
    cd $IN_PWD/conf
    [ -f $1 ] && cp -f $1 $2
}

function file_rm {
    [ -f $1 ] && rm -f $1
}

function file_bk {
    [ -f $1 ] && mv $1 ${1}_$(date +%Y%m%d%H)
}

function Checkinitd {
    [ -f /etc/init.d/$1 ] && rm -f /etc/init.d/$1
    [ $R7 == 1 ] && cp -f /www/wdlinux/init.d/$1 /etc/init.d/$1 || ln -s /www/wdlinux/init.d/$1 /etc/init.d/$1
}

function Defphp {
    sed -i 's/-55-/-'$1'-/g' $IN_DIR/nginx/conf/vhost/00000.default.conf
    $IN_DIR/nginx/sbin/nginx -s reload
}

function wdcpinitd {
    [ -f /etc/init.d/wdcp ] && rm -f /etc/init.d/wdcp
    if [ $R7 == 1 ];then
	cp -f /www/wdlinux/wdcp/wdcp.sh /etc/init.d/wdcp
    else
	ln -sf /www/wdlinux/wdcp/wdcp.sh /etc/init.d/wdcp
    fi
}

function yum_apt_ins {
	if [ $OS_RL == 1 ];then
		yum install -y gcc gcc-c++ make sudo autoconf libtool-ltdl-devel gd-devel \
        freetype-devel libxml2-devel libjpeg-devel libpng-devel openssl-devel xz \
        curl-devel patch libmcrypt-devel libmhash-devel ncurses-devel bzip2 \
        libcap-devel ntp sysklogd diffutils sendmail iptables unzip cmake wget logrotate \
	re2c bison icu libicu libicu-devel net-tools psmisc vim-enhanced xz libzip libzip-devel expat-devel
	else
		apt-get install -y gcc g++ make autoconf libltdl-dev libgd2-xpm-dev \
        libfreetype6 libfreetype6-dev libxml2-dev libjpeg-dev libpng12-dev \
        libcurl4-openssl-dev libssl-dev patch libmcrypt-dev libmhash-dev \
        libncurses5-dev  libreadline-dev bzip2 libcap-dev ntpdate \
        diffutils exim4 iptables unzip sudo cmake re2c bison \
        libicu-dev net-tools psmisc xz libzip libzip-devel expat-devel cmake libncurses5-dev
	fi
}

function lanmp_in_finsh {
    if [ ! -z $NPD ] && [ $NPD != "55" ];then
    sed -i 's/-55-/-'$NPD'-/g' $IN_DIR/nginx/conf/vhost/00000.default.conf
    fi
    echo
    echo
    echo
    echo -e "      \033[31mCongratulations ,lanmp,wdCP install is complete"
    echo -e "      visit http://$IPADDR"
    echo -e "      visit http://$IPPUBLIC"
    echo -e "                               "
    echo -e "      wdCP http://$IPADDR:8080"
    echo -e "      wdCP http://$IPPUBLIC:8080"
    echo -e "      user: admin"
    echo -e "      pass: wdlinux.cn"
    echo
}

function wdcp_in_finsh {
    echo
    echo
    echo
    echo -e "      \033[31mconfigurations, wdcp install is complete"
    echo -e "      visit http://$IPADDR:8080"
    echo -e "      visit http://$IPPUBLIC:8080"
    echo -e "      user: admin"
    echo -e "      pass: wdlinux.cn"
    echo
}


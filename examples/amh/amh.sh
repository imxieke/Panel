#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

clear;
# Logo 	******************************************************************
CopyrightLogo='
                                   AMH-7.1                                  
                            Powered by amh.sh 2006-2023                     
                         https://amh.sh All Rights Reserved                  
                                                                            
==========================================================================';

# VAR 	******************************************************************
InstallModel=$1;
InstallFrom=$2;
SysName='';
SysBit='';
CpuNum='';
StartDate='';
StartDateSecond='';
RandomValue=$RANDOM;
Release=`cat /etc/*release | grep -i 'VERSION_ID' | grep -Eo '[0-9]{1,3}' | head -1`;
IPAddress=`ip addr | egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | egrep -v "^192\.168|^172\.1[6-9]\.|^172\.2[0-9]\.|^172\.3[0-2]\.|^10\.|^127\.|^255\.|^100\.(6[4-9]|[7-9][0-9]|1[0-1][0-9]|12[0-7])\." | head -n 1`;
RamTotal=`free -m | grep 'Mem' | awk '{print $2}'`;
RamSwap=`free -m | grep 'Swap' | awk '{print $2}'`;
DefaultPassword='';
InstallStatus='';
ServerLocation='';

# Version
AMHVersion='amh-7.1';
LibiconvVersion='libiconv-1.14';
NginxVersion='nginx-generic-1.24';
MysqlVersion='mysql-generic-5.5';
PhpVersion='php-generic-7.4';

# InstallModel
if [ "$InstallModel" == 'gcc' ]; then
	NginxVersion='nginx-1.24';
	MysqlVersion='mysql-5.5';
	PhpVersion='php-7.4';
elif echo "$InstallModel" | grep -q ','; then
	NginxVersion=`echo $InstallModel | awk -F ',' '{print $1}'`;
	MysqlVersion=`echo $InstallModel | awk -F ',' '{print $2}'`;
	PhpVersion=`echo $InstallModel | awk -F ',' '{print $3}'`;
fi;

LANG=zh_CN.UTF-8;
SysType="x86";
SysList="Debian12,Debian11,Debian10 / CentOS-Stream9,CentOS-Stream8,CentOS7 / Ubuntu22,Ubuntu20";
uname -m | egrep -iq 'aarch64|arm' && LibiconvVersion='libiconv-1.16' && SysType="ARM" && SysList="Debian11,Debian10 / CentOS-Stream8,CentOS7 / Ubuntu22,Ubuntu20";

# Function List	*******************************************************************************
function CheckSystem()
{
	echo "$CopyrightLogo";
	[ $(id -u) != '0' ] && echo '[Error] 请使用 root 账号安装 AMH.' && exit;
	Stream='' && cat /etc/*release | egrep -q 'Stream|rockylinux|almalinux' && Stream='-Stream';
	egrep -i "debian" /etc/issue /proc/version >/dev/null && SysName='Debian';
	egrep -i "ubuntu" /etc/issue /proc/version >/dev/null && SysName='Ubuntu';
	whereis -b yum | grep -q '/yum' && SysName='CentOS';
	[ -f /etc/init.d/amh-start ] && echo '[Notice] AMH 已经安装.' && exit;
	[ "$SysName" == ''  ] && echo '[Error] 您的系统不支持安装 AMH.' && exit;
	[ "$IPAddress" == '' ] && IPAddress='ip';


	if egrep -q 'TencentOS|Alibaba' /etc/os-release; then
		[ "$Release" == '3' ] && Release='8';
		[ "$Release" == '2' ] && Release='7';
		[ "$Release" == '8' ] && Stream='-Stream';
		echo "VERSION_ID=\"${Release}.x\"" >/etc/amh-release;
	fi;

	SysBit='32' && [ `getconf WORD_BIT` == '32' ] && [ `getconf LONG_BIT` == '64' ] && SysBit='64';
	CpuNum=`cat /proc/cpuinfo | grep 'processor' | wc -l`;
	echo "${SysName}${Stream}${Release} ${SysBit}Bit";
	echo "Server ${IPAddress}";
	echo "${CpuNum}*CPU, ${RamTotal}MB/RAM, ${RamSwap}MB/Swap";
	echo '';

	if [ "$InstallModel" == '' -o "$InstallModel" == 'acc' ] && ( ! echo "$SysList" | grep -q "${SysName}${Stream}${Release}" || [ "$Release" == '' ] ) ; then
		echo '==========================================================================';
		echo "[Error] 您的系统 ${SysName}${Release} (${SysType}架构) 不支持安装 AMH 极速版。";
		echo "[Notice] 请使用以下系统：${SysList} ";
		echo "[Notice] 或是在 AMH 安装页面选择定制编译方式安装。";
		echo && exit;
	fi;
}


function SetPassword()
{
	DefaultPassword=`echo -n "${IPAddress}_${RandomValue}_$(date)_$(date +%N)" | md5sum | sed "s/ .*//" | cut -b -12`;
	echo '[Notice] AMH与MySQL初始账号密码:';
	echo "admin: ${DefaultPassword}";
	echo -e "root: \033[36m${DefaultPassword}\033[0m ";
	echo '==========================================================================';
}

function ConfirmInstall()
{
	notcie='现在安装AMH-7.1吗？确认安装请输入y回车：' && [ "$1" != '' ] && notcie="$1" 
	read -p "[Notice] ${notcie}" selected
	[ "$selected" == 'n' ] && exit;
	if [ "$selected" == 'y' ]; then
		echo "[Notice] 即将安装AMH ...";
		if [ "$CV" == '' ]; then
			ServerLocation='China [CN]';
			ping dl.amh.sh -c 1 | egrep -q '70.161|1c6f' && ServerLocation='United States [USA]';
		else
			ServerLocation=$CV;
		fi;
		return 0;
	else
		ConfirmInstall '请输入y进行安装，输入n退出安装：';
	fi;
}

function CloseSelinux()
{
	[ -s /etc/selinux/config ] && sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config;
	setenforce 0 >/dev/null 2>&1;
}

function InstallReady()
{
	rm -rf /etc/localtime;
	ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime;

	if [ "$SysName" == 'CentOS' ]; then
		yum -y install gcc gcc-c++ make curl bzip2 tar;
		yum -y install ntp cronie;
		if whereis systemctl | grep '/systemctl'; then
			systemctl stop firewalld;
			systemctl mask firewalld;
		fi;

		ca_pem='/etc/pki/tls/cert.pem';
		if [ -f $ca_pem ] && ( ! grep -q 'ubhPgXRR4Xq37Z0j4r7g1SgEEzwxA57d' $ca_pem || grep 'DST Root' $ca_pem ); then
			code_node='code' && echo $ServerLocation | grep -q 'CN' && code_node='code2';
			wget http://${code_node}.amh.sh/files/ca-bundle-2023.crt;
			md5sum ca-bundle-2023.crt | grep 475045bb4b54bbdeed599629264696a3 && \cp ca-bundle-2023.crt $ca_pem && \cp ca-bundle-2023.crt /etc/pki/tls/certs/ca-bundle.crt;
			rm -f ca-bundle-2023.crt;
		fi;
	else
		update-ca-certificates;
		if ps aux | grep bin/apt | grep -v grep; then
			apttime=1;
			while true; do
				sleep 1;
				! ps aux | grep bin/apt | grep -v grep && break;
				apttime=$[apttime+1];
				if [ $apttime -gt 60 ]; then
					kill -9 `ps aux | grep bin/apt | grep -v grep | awk '{print $2}'`;
					break;
				fi;
			done;
		fi;
		apt-get -y update;
		apt-get -y install gcc g++ make curl bzip2 ntpdate cron;
	fi;
	whereis ntpdate | grep '/ntpdate' && ntpdate -u pool.ntp.org;
	whereis chronyc | grep '/chronyc' && chronyc makestep;

	
	StartDate=$(date);
	StartDateSecond=$(date +%s);
	echo "Start time: ${StartDate}";

	groupadd www;
	useradd -m -s /sbin/nologin -g www www;

	mkdir -p /root/amh/{modules,conf};
	mkdir -p /home/{wwwroot,usrdata};
	cd /tmp/;
	AMHConfVersion=${AMHVersion/amh/amh-conf};
	wget https://dl.amh.sh/file/AMH/7.1/${AMHConfVersion}.tar.gz -O ${AMHConfVersion}.tar.gz;
	tar -zxvf ${AMHConfVersion}.tar.gz;
	\cp -a ./${AMHConfVersion}/conf /root/amh/;
	chmod -R 775 /root/amh/conf /root/amh/modules;
	gcc -o /bin/amh -Wall ./${AMHConfVersion}/conf/amh.c;
	chmod 4775 /bin/amh;
	echo $ServerLocation >/root/amh/conf/location.conf;
	rm -rf ${AMHConfVersion}.tar.gz ${AMHConfVersion} /root/amh/conf/amh.c;

	if [ "$RamSwap" == '' -o "$RamSwap" == '0' ]; then
		dd if=/dev/zero of=/swap bs=1M count=1024;
		chmod 600 /swap;
		mkswap /swap;
		swapon /swap;
		echo "/swap swap swap defaults 0 0" >>/etc/fstab;
		#[ "$RamTotal" -lt 777 ] && grep -q 'vm.swappiness' /etc/sysctl.conf && sed -i '/vm.swappiness/d' /etc/sysctl.conf && sysctl -p;
	fi;
}

function InstallBaseModule()
{
	amh download ${LibiconvVersion};
	amh download ${MysqlVersion};
	amh download ${NginxVersion};
	amh download ${PhpVersion};
	amh download ${AMHVersion};

	module_arr=("${LibiconvVersion}" "${MysqlVersion}" "${NginxVersion}" "${PhpVersion}" "${AMHVersion}");
	module_list='List';
	for v in ${module_arr[*]}; do
		[ ! -d "/root/amh/modules/$v" ] && echo "[Error] $v download failed." && module_list="${module_list} ${v},D0" && InstallStatus='fail' || module_list="${module_list} ${v},D1";
	done;
	[ "$InstallStatus" == 'fail' ] && return 1;

	amh ${LibiconvVersion} install && module_list="${module_list} ${LibiconvVersion},S1" && \
	amh ${PhpVersion} install && module_list="${module_list} ${PhpVersion},S1" && \
	amh ${MysqlVersion} install ${DefaultPassword} && module_list="${module_list} ${MysqlVersion},S1" && \
	amh ${NginxVersion} install && module_list="${module_list} ${NginxVersion},S1" && \
	amh ${AMHVersion} install ${NginxVersion} ${MysqlVersion} ${PhpVersion} ${DefaultPassword} ${DefaultPassword} ${InstallFrom} && module_list="${module_list} ${AMHVersion},S1" && InstallStatus='success';
}

function InstallEnd()
{
	AMHKey=`curl -d "AMHVersion=${AMHVersion}&module_list=${module_list}&info=${SysName}${Release}" --connect-timeout 5 --retry 3 -s dl.amh.sh/amh_key.htm`;
	( echo $AMHKey >/usr/local/${AMHVersion}/etc/.amh-key.conf ) 2>/dev/null
	WebSitePort='80';
	WebSiteIP=$IPAddress;
	if [ "$IPAddress" == 'ip' ]; then
		CurlIP=`curl -4 -s dl.amh.sh/ip.htm || curl -6 -s dl.amh.sh/ip.htm`;
		[[ "$CurlIP" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]] && IPAddress=$CurlIP && WebSiteIP=$CurlIP;
		[[ "$CurlIP" =~ (^[0-9a-fA-F]{1,4}:)|(:[0-9a-fA-F]{1,4}$) ]] && IPAddress='127.0.0.1' && WebSiteIP="[${CurlIP}]" && WebSitePort='80,[::]:80' && touch /etc/ipv6only.conf;
	fi;

	echo '==========================================================================';
	if [ "$InstallStatus" == 'success' ]; then
		if echo ${NginxVersion} | grep -q 'nginx'; then
			amh download lnmp;
			amh lnmp install;
			amh lnmp admin lnmp_create lnmp01 ${NginxVersion} ${MysqlVersion} ${PhpVersion};
			amh lnmp admin vhost_add lnmp01 ${IPAddress} ${WebSitePort} ${WebSiteIP} 0 0 400,403,404,502;
			sql="INSERT INTO amh.amh_module_lnmp(lnmp_name, lnmp_nginx, lnmp_mysql, lnmp_php, lnmp_rewrite) VALUES ('lnmp01', '${NginxVersion}', '${MysqlVersion}', '${PhpVersion}', 'amh.conf')";
		else
			amh download lamp;
			amh lamp install;
			amh lamp admin lamp_create lamp01 ${NginxVersion} ${MysqlVersion} ${PhpVersion};
			amh lamp admin vhost_add lamp01 ${IPAddress} ${WebSitePort} ${WebSiteIP} 0 0 400,403,404,502;
			sql="INSERT INTO amh.amh_module_lamp(lamp_name, lamp_apache, lamp_mysql, lamp_php, lamp_rewrite) VALUES ('lamp01', '${NginxVersion}', '${MysqlVersion}', '${PhpVersion}', 'amh.conf')";
		fi;
		export MYSQL_PWD=$DefaultPassword;
		mysql -uroot -S /tmp/${MysqlVersion}.sock -B -N -e "$sql";


		if [ "$DV" != 'N' ]; then
			DefaultInstall=(amrewrite madmin amfile amftp pure-ftpd amdata amnetwork amcrontab d-ram d-os d-cpu d-disk d-net);
			[ "$DV" != '' ] && IFS="," read -ra DefaultInstall <<< $DV;
			for line in "${DefaultInstall[@]}"; do
				amh download $line;
				if [[ "$line" =~ ^d- ]]; then
					module_name=`ls /root/amh/modules/ | grep ${line}`;
					module_vid=`grep ModuleVid /root/amh/modules/${module_name}/AMHScript.php | egrep -o '[0-9]+'`;
					[ "$module_vid" == '' ] && module_vid='0';
					sql="INSERT INTO amh.amh_module(module_name, module_local, module_sort, module_type, module_install_process, module_vid) VALUES ('${module_name}', '1', 'app', 'DesktopAPP', '-1', '${module_vid}')";
					mysql -uroot -S /tmp/${MysqlVersion}.sock -B -N -e "$sql";
				else 
					amh $line install;
				fi;
			done;
		fi;

		echo 'all' >/usr/local/${AMHVersion}/etc/upstatus.conf;
		echo '==========================================================================';
		echo '[AMH] 恭喜您! AMH 7.1 安装成功。';
		echo -e "访问以下地址管理面板（\033[31m如访问受限，请在主机商安全组开放面板端口如：8888\033[0m ）";
		echo "http://${WebSiteIP}:8888";
		echo "https://${WebSiteIP}:9999";
		echo 'AMH 用户名: admin';
		echo -e "AMH 密码: \033[36m${DefaultPassword}\033[0m ";
		echo "MySQL 用户名: root";
		echo -e "MySQL 密码: \033[36m${DefaultPassword}\033[0m ";
		echo '';
		echo "开始时间: ${StartDate}";
		echo "完成时间: $(date) (使用: $[($(date +%s)-StartDateSecond)/60] 分钟)";
		echo '更多帮助请访问: https://amh.sh';
	else
		echo '抱歉。安装 AMH 失败了，';
		echo -e '如有需要帮助安装，请联系我们: \033[34mhttps://amh.sh/bbs/forum.htm\033[0m';
	fi;
	echo '==========================================================================';
}


# AMH Installing ****************************************************************************
( CheckSystem;
SetPassword;
ConfirmInstall; 
CloseSelinux;
InstallReady;
InstallBaseModule;
InstallEnd; ) 2>&1 | tee amh.log


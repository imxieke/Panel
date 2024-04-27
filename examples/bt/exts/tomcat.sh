#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
public_file=/www/server/panel/install/public.sh
if [ ! -f $public_file ];then
	wget -O $public_file http://download.bt.cn/install/public.sh -T 5;
fi
. $public_file

download_Url=$NODE_URL
#准备基础数据
Root_Path=`cat /var/bt_setupPath.conf`
run_path='/root'
Is_64bit=`getconf LONG_BIT`
tomcat7='7.0.76'
tomcat8='8.5.69'
tomcat9='9.0.50'

#安装tomcat
Install_Tomcat()
{
	#前置准备
	Uninstall_Tomcat
	Install_JavaJdk
	
	yum install rng-tools -y
	service rngd start
	systemctl start rngd
	
	#下载并安装主程序
	filename=apache-tomcat-$tomcatVersion.tar.gz
	wget -c -O $filename  $download_Url/install/src/$filename -T 20
	tar xvf $filename
	mv -f apache-tomcat-$tomcatVersion $Setup_Path
	rm -f $filename
	if [ "$tomcatVersion" == "$tomcat9" ];then
		tomcatVersion="9.0.0";
	fi
	echo "$tomcatVersion" > $Setup_Path/version.pl
	
	#替换默认配置
	sxml=$Setup_Path/conf/server.xml
	#mkdir -p /www/server/panel/vhost/tomcat
	#sed -i "s#webapps#/www/server/panel/vhost/tomcat#" $sxml
	sed -i "s#TOMCAT_USER=tomcat#TOMCAT_USER=www#" $Setup_Path/bin/daemon.sh
	#chown -R www.www /www/server/panel/vhost/tomcat
	chown -R www.www $Setup_Path
	#\cp -a -r /www/server/tomcat/webapps/* /www/server/panel/vhost/tomcat/
	
	#替换端口
	#sed -i "s/8080/9001/" $sxml
	#sed -i "s/8009/901$version/" $sxml
	#sed -i "s/8005/902$version/" $sxml
	
	#添加到服务
	#sed -i "s@bin/sh@bin/bash\n# chkconfig: 2345 55 25\n# description: tomcat$version\n### BEGIN INIT INFO\n# Provides:          tomcat$version\n# Required-Start:    \$all\n# Required-Stop:     \$all\n# Default-Start:     2 3 4 5\n# Default-Stop:      0 1 6\n# Short-Description: starts tomcat$version\n# Description:       starts the tomcat$version\n\n### END INIT INFO\n\nJAVA_HOME=$jdk_path\nCATALINA_HOME=/www/server/tomcat@" $Setup_Path/bin/catalina.sh
	#\cp -r -a $Setup_Path/bin/catalina.sh /etc/init.d/tomcat
	#chmod +x /etc/init.d/tomcat
	#chkconfig --add tomcat
	#chkconfig --level 2345 tomcat on
	#/etc/init.d/tomcat start
}

#安装java-jdk
Install_JavaJdk()
{
	if [ ! -d "$jdk_path" ];then
		wget -c -O java-jdk.rpm $download_Url/install/src/jdk-$jdk-linux-x$Is_64bit.rpm -T 20
		rpm -ivh java-jdk.rpm --force --nodeps
		rm -f java-jdk.rpm
	fi
}
Install_Jsvs(){
	cd /www/server/tomcat/bin
	tar -zxf commons-daemon-native.tar.gz
	if [ "${version}" == "7" ];then
		cd commons-daemon-1.0.15-native-src/unix
	else
		cd commons-daemon-1.2.4-native-src/unix
	fi
	./configure --with-java=$jdk_path
	make
	\cp jsvc /www/server/tomcat/bin
	sed -i "s@# JAVA_HOME=\/opt\/jdk-1.6.0.22@JAVA_HOME=$jdk_path@" /www/server/tomcat/bin/daemon.sh
	if [ -f "/etc/init.d/tomcat" ]; then
		rm -f /etc/init.d/tomcat
	fi
cat >>/etc/init.d/tomcat<<EOF
#!/bin/bash
# chkconfig: 2345 55 25
# description: tomcat Service

### BEGIN INIT INFO
# Provides:          tomcat
# Required-Start:    $all
# Required-Stop:     $all
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: starts tomcat
# Description:       starts the tomcat
### END INIT INFO
path=/www/server/tomcat/bin
cd \$path
bash daemon.sh \$1
EOF
	chmod +x /etc/init.d/tomcat
	chkconfig --add tomcat
	chkconfig --level 2345 tomcat on
	/etc/init.d/tomcat start
}
Update_Tomcat(){
	echo "tomcat无法直接升级，如需升级新版本请卸载重装"
	echo "如有项目正在运行，卸载重装可能将无法访问，请慎重操作"
}
#卸载tomcat
Uninstall_Tomcat()
{
	if [ -d "$Setup_Path" ];then
		$Setup_Path/bin/daemon.sh stop
		rm -rf $Setup_Path
	fi
	if [ -f "/etc/init.d/tomcat" ];then
		chkconfig --del tomcat
		rm -f /etc/init.d/tomcat
		rm -f /etc/rc.d/init.d/tomcat
	fi
}

actionType=$1
version=$2
Setup_Path=$Root_Path/server/tomcat
if [ "$actionType" == 'install' ];then
	tomcatVersion=$tomcat7
	jdk='7u80'
	jdk_path='/usr/java/jdk1.7.0_80'
	if [ "$version" == "8" ];then
		tomcatVersion=$tomcat8
		jdk='8u121'
		jdk_path='/usr/java/jdk1.8.0_121'
	elif [ "$version" == "9" ];then
		tomcatVersion=$tomcat9
		jdk='8u121'
		jdk_path='/usr/java/jdk1.8.0_121'
	fi
	Install_Tomcat
	Install_Jsvs
elif [ "$actionType" == 'uninstall' ];then
	Uninstall_Tomcat
elif [  "$actionType" == 'update' ]; then
	Update_Tomcat
fi


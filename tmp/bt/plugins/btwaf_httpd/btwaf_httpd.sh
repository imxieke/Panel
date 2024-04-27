#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
install_tmp='/tmp/bt_install.pl'
public_file=/www/server/panel/install/public.sh

if [ ! -f $public_file ];then
	wget -O $public_file http://download.bt.cn/install/public.sh -T 5;
fi

. $public_file
download_Url=$NODE_URL
pluginPath=/www/server/panel/plugin/btwaf_httpd

pyVersion=$(python -c 'import sys;print(sys.version_info[0]);')
py_zi=$(python -c 'import sys;print(sys.version_info[1]);')
aacher=$(uname -a |grep -Po aarch64|awk 'NR==1')
lua_version=`lua -e "print( _G._VERSION )"`
lua_ver=${lua_version: -1}

Install_btwaf_httpd()
{	
	
	if [ -f /www/server/btwaf/init.lua ];then
		rm -rf /www/server/btwaf
	fi
	mkdir -p /www/server/btwaf
	Install_cjson
	Install_socket
	Install_mod_lua
	yum install lua-socket -y
	apt-get install lua-cjson -y 
	apt-get install lua-socket -y 
	mkdir -p $pluginPath
	echo '正在安装脚本文件...' > $install_tmp
	
	echo "<?php echo 'hello world'?>"> $pluginPath/btwaf_httpd_main.py
	if [ "$aacher" == "aarch64" ];then 
		if [  -f /www/server/panel/pyenv/bin/python ];then
			wget -O $pluginPath/btwaf_httpd_main.cpython-37m-aarch64-linux-gnu.zip $download_Url/install/plugin/btwaf_httpd/aachar64/btwaf_httpd_main.cpython-37m-aarch64-linux-gnu.zip -T 5
			unzip -o $pluginPath/btwaf_httpd_main.cpython-37m-aarch64-linux-gnu.zip -d $pluginPath > /dev/null
			rm -rf $pluginPath/btwaf_httpd_main.cpython-37m-aarch64-linux-gnu.zip
		else
			if [ "$pyVersion" == 2 ];then
				wget -O $pluginPath/btwaf_httpd_main.zip $download_Url/install/plugin/btwaf_httpd/aachar64/btwaf_httpd_main.zip -T 5
				unzip -o $pluginPath/btwaf_httpd_main.zip -d $pluginPath > /dev/null
				rm -rf $pluginPath/btwaf_httpd_main.zip
			else
				if [ "$py_zi" == 6 ];then 
					wget -O $pluginPath/btwaf_httpd_main.cpython-36m-aarch64-linux-gnu.zip $download_Url/install/plugin/btwaf_httpd/aachar64/btwaf_httpd_main.cpython-36m-aarch64-linux-gnu.zip -T 5
					unzip -o $pluginPath/btwaf_httpd_main.cpython-36m-aarch64-linux-gnu.zip -d $pluginPath > /dev/null
					rm -rf $pluginPath/btwaf_httpd_main.cpython-36m-aarch64-linux-gnu.zip
				fi 
				if [ "$py_zi" == 7 ];then 
					wget -O $pluginPath/btwaf_httpd_main.cpython-37m-aarch64-linux-gnu.zip $download_Url/install/plugin/btwaf_httpd/aachar64/btwaf_httpd_main.cpython-37m-aarch64-linux-gnu.zip -T 5
					unzip -o $pluginPath/btwaf_httpd_main.cpython-37m-aarch64-linux-gnu.zip -d $pluginPath > /dev/null
					rm -rf $pluginPath/btwaf_httpd_main.cpython-37m-aarch64-linux-gnu.zip
				fi
			fi
		fi
	else
		if [  -f /www/server/panel/pyenv/bin/python ];then
			wget -O $pluginPath/btwaf_httpd_main.cpython-37m-x86_64-linux-gnu.zip $download_Url/install/plugin/btwaf_httpd/8.2/btwaf_httpd_main.cpython-37m-x86_64-linux-gnu.zip -T 5
			unzip -o $pluginPath/btwaf_httpd_main.cpython-37m-x86_64-linux-gnu.zip -d $pluginPath > /dev/null
			rm -rf $pluginPath/btwaf_httpd_main.cpython-37m-x86_64-linux-gnu.zip
		else
			if [ "$pyVersion" == 2 ];then
				wget -O $pluginPath/btwaf_httpd_main.zip $download_Url/install/plugin/btwaf_httpd/btwaf_httpd_main.zip -T 5
				unzip -o $pluginPath/btwaf_httpd_main.zip -d $pluginPath > /dev/null
				rm -rf $pluginPath/btwaf_httpd_main.zip
			else
				if [ "$py_zi" == 6 ];then 
					wget -O $pluginPath/btwaf_httpd_main.cpython-36m-x86_64-linux-gnu.zip $download_Url/install/plugin/btwaf_httpd/btwaf_httpd_main.cpython-36m-x86_64-linux-gnu.zip -T 5
					unzip -o $pluginPath/btwaf_httpd_main.cpython-36m-x86_64-linux-gnu.zip -d $pluginPath > /dev/null
					rm -rf $pluginPath/btwaf_httpd_main.cpython-36m-x86_64-linux-gnu.zip
				fi 
				if [ "$py_zi" == 4 ];then 
					wget -O $pluginPath/btwaf_httpd_main.cpython-34m.zip $download_Url/install/plugin/btwaf_httpd/btwaf_httpd_main.cpython-34m.zip -T 5
					unzip -o $pluginPath/btwaf_httpd_main.cpython-34m.zip -d $pluginPath > /dev/null
					rm -rf $pluginPath/btwaf_httpd_main.cpython-34m.zip
				fi
				if [ "$py_zi" == 7 ];then 
					wget -O $pluginPath/btwaf_httpd_main.cpython-37m-x86_64-linux-gnu.zip $download_Url/install/plugin/btwaf_httpd/8.2/btwaf_httpd_main.cpython-37m-x86_64-linux-gnu.zip -T 5
					unzip -o $pluginPath/btwaf_httpd_main.cpython-37m-x86_64-linux-gnu.zip -d $pluginPath > /dev/null
					rm -rf $pluginPath/btwaf_httpd_main.cpython-37m-x86_64-linux-gnu.zip
				fi
			fi
		fi
	fi
	wget -O $pluginPath/btwaf_httpd_main.zip $download_Url/install/plugin/btwaf_httpd/8.2/btwaf_httpd_main.zip -T 5
	unzip -o $pluginPath/btwaf_httpd_main.zip -d $pluginPath > /dev/null
	rm -rf $pluginPath/btwaf_httpd_main.zip
	
	wget -O $pluginPath/firewalls_list.py $download_Url/install/plugin/btwaf_httpd/firewalls_list.py -T 5
	wget -O $pluginPath/index.html $download_Url/install/plugin/btwaf_httpd/8.2/index.html -T 5
	wget -O $pluginPath/info.json $download_Url/install/plugin/btwaf_httpd/info.json -T 5
	wget -O $pluginPath/icon.png $download_Url/install/plugin/btwaf_httpd/icon.png -T 5
	chattr -i /www/server/panel/vhost/apache/btwaf.conf
	rm -rf /www/server/panel/vhost/apache/btwaf.conf
	wget -O /www/server/panel/vhost/apache/btwaf.conf $download_Url/install/plugin/btwaf_httpd/btwaf.conf -T 5
	\cp -a -r /www/server/panel/plugin/btwaf_httpd/icon.png /www/server/panel/static/img/soft_ico/ico-btwaf_httpd.png
	wget -O $pluginPath/btwaf.zip $download_Url/install/plugin/btwaf_httpd/8.2/btwaf.zip -T 5
	unzip -o $pluginPath/btwaf.zip -d /tmp/ > /dev/null
	\cp -a -r /tmp/btwaf/rule/referer.json /www/server/btwaf/rule/referer.json
	rm -f $pluginPath/btwaf.zip
	btwaf_httpd_path=/www/server/btwaf
	mkdir -p $btwaf_httpd_path/html
	rm -rf /www/server/btwaf/cms
	mv /tmp/btwaf/cms/  $btwaf_httpd_path
	if [ ! -f $btwaf_httpd_path/html/get.html ];then
		\cp -a -r /tmp/btwaf/html/get.html $btwaf_httpd_path/html/get.html
		\cp -a -r /tmp/btwaf/html/get.html $btwaf_httpd_path/html/post.html
		\cp -a -r /tmp/btwaf/html/get.html $btwaf_httpd_path/html/cookie.html
		\cp -a -r /tmp/btwaf/html/get.html $btwaf_httpd_path/html/user_agent.html
		\cp -a -r /tmp/btwaf/html/get.html $btwaf_httpd_path/html/other.html
	fi
	
	mkdir -p $btwaf_httpd_path/rule
	if [ ! -f $btwaf_httpd_path/rule/url.json ];then
		\cp -a -r /tmp/btwaf/rule/url.json $btwaf_httpd_path/rule/url.json
		\cp -a -r /tmp/btwaf/rule/args.json $btwaf_httpd_path/rule/args.json
		\cp -a -r /tmp/btwaf/rule/post.json $btwaf_httpd_path/rule/post.json
		\cp -a -r /tmp/btwaf/rule/cn.json $btwaf_httpd_path/rule/cn.json
		\cp -a -r /tmp/btwaf/rule/cookie.json $btwaf_httpd_path/rule/cookie.json
		\cp -a -r /tmp/btwaf/rule/head_white.json $btwaf_httpd_path/rule/head_white.json
		\cp -a -r /tmp/btwaf/rule/ip_black.json $btwaf_httpd_path/rule/ip_black.json
		\cp -a -r /tmp/btwaf/rule/ip_white.json $btwaf_httpd_path/rule/ip_white.json
		\cp -a -r /tmp/btwaf/rule/scan_black.json $btwaf_httpd_path/rule/scan_black.json
		\cp -a -r /tmp/btwaf/rule/url_black.json $btwaf_httpd_path/rule/url_black.json
		\cp -a -r /tmp/btwaf/rule/url_white.json $btwaf_httpd_path/rule/url_white.json
		\cp -a -r /tmp/btwaf/rule/user_agent.json $btwaf_httpd_path/rule/user_agent.json
		\cp -a -r /tmp/btwaf/rule/referer.json $btwaf_httpd_path/rule/referer.json
	fi
	
	
	if [ ! -f $btwaf_httpd_path/rule/cc_uri_white.json ];then
		\cp -a -r /tmp/btwaf/rule/cc_uri_white.json $btwaf_httpd_path/rule/cc_uri_white.json
	fi
	
	if [ ! -f /www/server/btwaf/total.json ];then
		\cp -a -r /tmp/btwaf/total.json /www/server/btwaf/total.json
	fi
	
	if [ ! -f /www/server/btwaf/site.json ];then
		\cp -a -r /tmp/btwaf/site.json /www/server/btwaf/site.json
	fi
	
	if [ ! -f /www/server/btwaf/config.json ];then
		\cp -a -r /tmp/btwaf/config.json /www/server/btwaf/config.json
	fi
	
	if [ ! -f /dev/shm/stop_ip.json ];then
		\cp -a -r /tmp/btwaf/stop_ip.json /dev/shm/stop_ip.json
	fi
	
	chmod 777 /dev/shm/stop_ip.json
	chown www:www /dev/shm/stop_ip.json
	
	
	for fileName in 1 2 3 4 5 6 7 zhi
	do
		
		\cp -a -r /tmp/btwaf/${fileName}.json $btwaf_httpd_path/${fileName}.json

	done
	
	if [ ! -f $btwaf_httpd_path/drop_ip.log ];then
		\cp -a -r /tmp/btwaf/drop_ip.log $btwaf_httpd_path/drop_ip.log
	fi

	\cp -a -r /tmp/btwaf/8.5.lua $btwaf_httpd_path/httpd.lua
	\cp -a -r /tmp/btwaf/zhi.lua $btwaf_httpd_path/zhi.lua
	echo $lua_ver
	if [ $lua_ver -eq 1 ];then 
	    \cp -a -r /tmp/btwaf/mycomplib.so $btwaf_httpd_path/mycomplib.so
	elif [ $lua_ver -eq 2 ];then 
	    \cp -a -r /tmp/btwaf/mycomplib.so $btwaf_httpd_path/mycomplib.so
	elif [ $lua_ver -eq 3 ];then    
	 \cp -a -r /tmp/btwaf/mycomplib_5.3.so $btwaf_httpd_path/mycomplib.so
	elif [ $lua_ver -eq 4 ];then    
	  \cp -a -r /tmp/btwaf/mycomplib_5.3.so $btwaf_httpd_path/mycomplib.so
	fi
	\cp -a -r /tmp/btwaf/memcached.lua $btwaf_httpd_path/memcached.lua
	\cp -a -r /tmp/btwaf/CRC32.lua $btwaf_httpd_path/CRC32.lua
	\cp -a -r /tmp/btwaf/multipart.lua $btwaf_httpd_path/multipart.lua
	chmod +x $btwaf_httpd_path/httpd.lua
	chmod +x $btwaf_httpd_path/memcached.lua
	chmod +x $btwaf_httpd_path/CRC32.lua
	
	mkdir -p /www/wwwlogs/btwaf
	chmod 777 /www/wwwlogs/btwaf
	chmod -R 755 /www/server/btwaf
	#rm -rf /tmp/btwaf
	cd /www/server/panel
	chown -R root:root /www/server/btwaf/
	chown www:www /www/server/btwaf/*.json
	chown www:www /www/server/btwaf/drop_ip.log
	chattr +i /www/server/panel/vhost/apache/btwaf.conf
	/etc/init.d/httpd restart
	bash /www/server/panel/init.sh start
	
	echo '安装完成' > $install_tmp
}

Install_cjson()
{
	if [ -f /usr/bin/yum ];then
		isInstall=`rpm -qa |grep lua-devel`
		if [ "$isInstall" == "" ];then
			yum install lua lua-devel -y
		fi
	else
		isInstall=`dpkg -l|grep liblua5.1-0-dev`
		if [ "$isInstall" == "" ];then
			apt-get install lua5.1 lua5.1-dev -y
		fi
	fi
	
	Centos8Check=$(cat /etc/redhat-release | grep ' 8.' | grep -iE 'centos|Red Hat')
	CentosStream8Check=$(cat /etc/redhat-release|grep -i "Centos Stream"|grep 8)
	if [ "${Centos8Check}" ] || [ "${CentosStream8Check}" ];then
		wget -O lua-5.3-cjson.tar.gz $download_Url/src/lua-5.3-cjson.tar.gz -T 20
		tar -xvf lua-5.3-cjson.tar.gz
		cd lua-5.3-cjson
		make 
		make install
		ln -sf /usr/lib/lua/5.3/cjson.so /usr/lib64/lua/5.3/cjson.so
		cd .. 
		rm -f lua-5.3-cjson.tar.gz
		rm -rf lua-5.3-cjson
		return
	fi

	if [ ! -f /usr/local/lib/lua/5.1/cjson.so ];then
		wget -O lua-cjson-2.1.0.tar.gz $download_Url/install/src/lua-cjson-2.1.0.tar.gz -T 20
		tar xvf lua-cjson-2.1.0.tar.gz
		rm -f lua-cjson-2.1.0.tar.gz
		cd lua-cjson-2.1.0
		make clean
		make
		make install
		cd ..
		rm -rf lua-cjson-2.1.0
		ln -sf /usr/local/lib/lua/5.1/cjson.so /usr/lib64/lua/5.1/cjson.so
		ln -sf /usr/local/lib/lua/5.1/cjson.so /usr/lib/lua/5.1/cjson.so
	else
		if [ -d "/usr/lib64/lua/5.1" ];then
			ln -sf /usr/local/lib/lua/5.1/cjson.so /usr/lib64/lua/5.1/cjson.so
		fi
		
		if [ -d "/usr/lib/lua/5.1" ];then
			ln -sf /usr/local/lib/lua/5.1/cjson.so /usr/lib/lua/5.1/cjson.so
		fi
	fi
}

Install_socket()
{
	if [ ! -f /usr/local/lib/lua/5.1/socket/core.so ];then
		wget -O luasocket-master.zip $download_Url/install/src/luasocket-master.zip -T 20
		unzip luasocket-master.zip
		rm -f luasocket-master.zip
		cd luasocket-master
		export C_INCLUDE_PATH=/usr/local/include/luajit-2.0:$C_INCLUDE_PATH
		make
		make install
		cd ..
		rm -rf luasocket-master
	fi
	
	if [ ! -d /usr/share/lua/5.1/socket ]; then
		if [ -d /usr/lib64/lua/5.1 ];then
			rm -rf /usr/lib64/lua/5.1/socket /usr/lib64/lua/5.1/mime
			ln -sf /usr/local/lib/lua/5.1/socket /usr/lib64/lua/5.1/socket
			ln -sf /usr/local/lib/lua/5.1/mime /usr/lib64/lua/5.1/mime
		else
			rm -rf /usr/lib/lua/5.1/socket /usr/lib/lua/5.1/mime
			ln -sf /usr/local/lib/lua/5.1/socket /usr/lib/lua/5.1/socket
			ln -sf /usr/local/lib/lua/5.1/mime /usr/lib/lua/5.1/mime
		fi
		rm -rf /usr/share/lua/5.1/mime.lua /usr/share/lua/5.1/socket.lua /usr/share/lua/5.1/socket
		ln -sf /usr/local/share/lua/5.1/mime.lua /usr/share/lua/5.1/mime.lua
		ln -sf /usr/local/share/lua/5.1/socket.lua /usr/share/lua/5.1/socket.lua
		ln -sf /usr/local/share/lua/5.1/socket /usr/share/lua/5.1/socket
	fi
	if [ ! -d /www/server/btwaf/socket.lua ]; then
		ln -sf /usr/local/share/lua/5.1/socket.lua /www/server/btwaf/socket.lua
		#ln -sf /usr/local/share/lua/5.1/socket /www/server/btwaf/socket
	fi
	
}

Install_mod_lua()
{
	if [ -f /www/server/apache/modules/mod_lua.so ];then
		return 0;
	fi
	cd /www/server/apache
	if [ ! -d /www/server/apache/src ];then
		wget -O httpd-2.4.52.tar.gz $download_Url/src/httpd-2.4.52.tar.gz -T 20
		tar xvf httpd-2.4.52.tar.gz
		rm -f httpd-2.4.52.tar.gz
		mv httpd-2.4.52 src
		cd /www/server/apache/src/srclib
		wget -O apr-1.6.3.tar.gz $download_Url/src/apr-1.6.3.tar.gz
		wget -O apr-util-1.6.1.tar.gz $download_Url/src/apr-util-1.6.1.tar.gz
		tar zxf apr-1.6.3.tar.gz
		tar zxf apr-util-1.6.1.tar.gz
		mv apr-1.6.3 apr
		mv apr-util-1.6.1 apr-util
	fi
	cd /www/server/apache/src
	./configure --prefix=/www/server/apache --enable-lua
	cd /www/server/apache/src/modules/lua
	make
	make install
	
	if [ ! -f /www/server/apache/modules/mod_lua.so ];then
		echo 'mod_lua安装失败!';
		exit 0;
	fi
}

Uninstall_btwaf_httpd()
{
	chattr -i /www/server/panel/vhost/apache/btwaf.conf
	rm -f /www/server/panel/vhost/apache/btwaf.conf
	rm -rf $pluginPath
	/etc/init.d/httpd reload
}

if [ "${1}" == 'install' ];then
	Install_btwaf_httpd
elif  [ "${1}" == 'update' ];then
	Install_btwaf_httpd
elif [ "${1}" == 'uninstall' ];then
	Uninstall_btwaf_httpd
fi
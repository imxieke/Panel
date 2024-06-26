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
pluginPath=/www/server/panel/plugin/pythonmamager

check_virtualenv(){
  if [ ! -f "/usr/bin/virtualenv" ];then
    if [ -d "/www/server/panel/pyenv" ];then
      btpip install virtualenv
      ln -s /www/server/panel/pyenv/bin/virtualenv /usr/bin/virtualenv
    else
      pip install virtualenv
    fi
  fi
}

Install_PythonMamage()
{
  check_virtualenv
	isbt_pcre=`rpm -qa|grep bt-pcre`
	if [ "$isbt_pcre" != '' ];then
		rpm -e bt-pcre;
		yum reinstall pcre -y;
	fi
	yum -y install git libffi-devel gcc zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gdbm-devel xz-devel patch
	yum -y install db4-devel libpcap-devel
	grep "English" /www/server/panel/config/config.json
	if [ "$?" -ne 0 ];then
	  wget -O /tmp/pyenv.tar.gz $download_Url/src/pyenv.tar.gz
	  tar -zxf /tmp/pyenv.tar.gz -C /root
    ln -s /root/.pyenv /.pyenv
    rm -f /tmp/pyenv.tar.gz
	else
	  wget https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer --no-check-certificate
#	  curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash
    bash pyenv-installer
    rm -f pyenv-installer
	fi


    env=`grep "pyenv" /root/.bashrc |wc -l`
    if [ "$env" -eq "0" ];then
        echo 'export PATH=~/.pyenv/bin:$PATH' >> ~/.bashrc
        echo 'export PYENV_ROOT=~/.pyenv' >> ~/.bashrc
        echo 'eval "$(pyenv init -)"' >> ~/.bashrc
        source ~/.bashrc
    fi


	mkdir -p $pluginPath
	 /root/.pyenv/bin/pyenv install -l > $pluginPath/pyv.txt
	echo '正在安装脚本文件...' > $install_tmp
	grep "English" /www/server/panel/config/config.json
	if [ "$?" -ne 0 ];then
        wget -O $pluginPath/pythonmamager_main.py $download_Url/install/plugin/pythonmamager/pythonmamager_main.py -T 5
        wget -O $pluginPath/index.html $download_Url/install/plugin/pythonmamager/index.html -T 5
        wget -O $pluginPath/info.json $download_Url/install/plugin/pythonmamager/info.json -T 5
        wget -O $pluginPath/icon.png $download_Url/install/plugin/pythonmamager/icon.png -T 5
        wget -O $pluginPath/install.sh $download_Url/install/plugin/pythonmamager/install.sh -T 5
        wget -O $pluginPath/pythonmamager $download_Url/install/plugin/pythonmamager/pythonmamager -T 5
	else
	    wget -O $pluginPath/pythonmamager_main.py $download_Url/install/plugin/pythonmamager_en/pythonmamager_main.py -T 5
        wget -O $pluginPath/index.html $download_Url/install/plugin/pythonmamager_en/index.html -T 5
        wget -O $pluginPath/info.json $download_Url/install/plugin/pythonmamager_en/info.json -T 5
        wget -O $pluginPath/icon.png $download_Url/install/plugin/pythonmamager_en/icon.png -T 5
        wget -O $pluginPath/install.sh $download_Url/install/plugin/pythonmamager_en/install.sh -T 5
        wget -O $pluginPath/pythonmamager $download_Url/install/plugin/pythonmamager_en/pythonmamager -T 5
	fi
	cp $pluginPath/pythonmamager /etc/init.d/pythonmamager
	chmod +x /etc/init.d/pythonmamager
	systemctl enable pythonmamager
	\cp -a -r /www/server/panel/plugin/pythonmamager/icon.png /www/server/panel/BTPanel/static/img/soft_ico/ico-pythonmamager.png
	echo '安装完成' > $install_tmp
}

Uninstall_PythonMamage()
{
	rm -rf $pluginPath
	rm -rf /root/.pyenv
	rm -rf /.pyenv
	systemctl disable pythonmamager
	rm -f /etc/init.d/pythonmamager
	sed -i "/pyenv/d" /root/.bashrc
}




if [ "${1}" == 'install' ];then
	Install_PythonMamage
elif  [ "${1}" == 'update' ];then
	Install_PythonMamage
elif [ "${1}" == 'uninstall' ];then
	Uninstall_PythonMamage
fi


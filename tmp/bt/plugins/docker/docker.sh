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


Install_Ubuntu_ce2()
{
sudo apt remove docker.io -y
pip install pytz
pip install docker
apt install docker.io -y
apt install apt-transport-https ca-certificates curl software-properties-common -y
echo 'deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable' >/etc/apt/sources.list.d/docker.list
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
apt install docker-ce -y
update-rc.d docker defaults
}

Install_Ubuntu_ce()
{
	sudo apt-get remove docker docker-engine docker.io containerd runc -y
	apt-get update -y
	apt-get install apt-transport-https ca-certificates curl gnupg lsb-release -y
	if [ -f /usr/share/keyrings/docker-archive-keyring.gpg ];then
		\mv /usr/share/keyrings/docker-archive-keyring.gpg /usr/share/keyrings/docker-archive-keyring.gpg.$(date +%s).bak
	fi
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
	echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
	apt-get update -y
	apt-get install docker-ce docker-ce-cli containerd.io -y
	apt install apt-transport-https ca-certificates curl software-properties-common -y
	update-rc.d docker defaults
}

Install_Debian_ce()
{
	sudo apt-get remove docker docker-engine docker.io containerd runc -y
	sudo apt-get purge docker-ce docker-ce-cli containerd.io -y
	sudo apt-get update -y
	sudo apt-get install apt-transport-https ca-certificates curl gnupg lsb-release -y
	if [ -f /usr/share/keyrings/docker-archive-keyring.gpg ];then
		\mv /usr/share/keyrings/docker-archive-keyring.gpg /usr/share/keyrings/docker-archive-keyring.gpg.$(date +%s).bak
	fi
	curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
	echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
	sudo apt-get update -y
	sudo apt-get install docker-ce docker-ce-cli containerd.io -y
	sudo apt-get install apt-transport-https ca-certificates curl software-properties-common -y
	update-rc.d docker defaults
}

Install_Docker_ce()
{
  pip install pytz
  yum remove docker docker-common docker-selinux docker-engine -y
  yum install yum-utils device-mapper-persistent-data lvm2 -y
  yum install atomic-registries container-storage-setup containers-common oci-register-machine oci-systemd-hook oci-umount python-pytoml subscription-manager-rhsm-certificates yajl -y
  grep "English" /www/server/panel/config/config.json
  if [ "$?" -ne 0 ];then
    yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
  else
    yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
  fi
  yum-config-manager --enable docker-ce-edge
  yum install $download_Url/install/plugin/docker/containerd.io-1.2.13-3.1.el7.x86_64.rpm -y
  yum install docker-ce -y
  yum-config-manager --disable docker-ce-edge
  echo 'move docker data to /www/server/docker ...';
  if [ -f /usr/bin/systemctl ];then
    systemctl stop docker
  else
    service docker stop
  fi
  if [ ! -d /www/server/docker ];then
    mv -f /var/lib/docker /www/server/docker
  else
    rm -rf /var/lib/docker
  fi
  ln -sf /www/server/docker /var/lib/docker

  #systemctl or service
  if [ -f /usr/bin/systemctl ];then
    systemctl stop getty@tty1.service
    systemctl mask getty@tty1.service
    systemctl enable docker
    systemctl start docker
  else
    chkconfig --add docker
    chkconfig --level 2345 docker on
    service docker start
  fi

  #install python-docker
  pip install docker

  #pull image of bt-panel
  #imageVersion='5.6.0'
  #docker pull registry.cn-hangzhou.aliyuncs.com/bt-panel/panel:$imageVersion
  #docker tag `docker images|grep bt-panel|awk '{print $3}'` bt-panel:$imageVersion
}


Install_docker()
{

	if [ ! -d /www/server/panel/plugin/docker ];then
		mkdir -p /www/server/panel/plugin/docker
			if [ grep -Eqi "Ubuntu" /etc/issue || grep -Eq "Ubuntu" /etc/*-release ];then
				Install_Ubuntu_ce
			elif [ grep -Eqi "Debian" /etc/issue || grep -Eq "Debian" /etc/*-release ];then
				Install_Debian_ce
			elif [ -f "/usr/bin/yum" ];then
				Install_Docker_ce
		fi
	fi

  echo '正在安装脚本文件...' > $install_tmp
  grep "English" /www/server/panel/config/config.json
  if [ "$?" -ne 0 ];then
    wget -O /www/server/panel/plugin/docker/docker_main.py $download_Url/install/plugin/docker/docker_main.py -T 5
    wget -O /www/server/panel/plugin/docker/index.html $download_Url/install/plugin/docker/index.html -T 5
    wget -O /www/server/panel/plugin/docker/info.json $download_Url/install/plugin/docker/info.json -T 5
    wget -O /www/server/panel/plugin/docker/icon.png $download_Url/install/plugin/docker/icon.png -T 5
    wget -O /www/server/panel/plugin/docker/login-docker.html $download_Url/install/plugin/docker/login-docker.html -T 5
    wget -O /www/server/panel/plugin/docker/userdocker.html $download_Url/install/plugin/docker/userdocker.html -T 5
  else
    wget -O /www/server/panel/plugin/docker/docker_main.py $download_Url/install/plugin/docker_en/docker_main.py -T 5
    wget -O /www/server/panel/plugin/docker/index.html $download_Url/install/plugin/docker_en/index.html -T 5
    wget -O /www/server/panel/plugin/docker/info.json $download_Url/install/plugin/docker_en/info.json -T 5
    wget -O /www/server/panel/plugin/docker/icon.png $download_Url/install/plugin/docker_en/icon.png -T 5
    wget -O /www/server/panel/plugin/docker/login-docker.html $download_Url/install/plugin/docker_en/login-docker.html -T 5
    wget -O /www/server/panel/plugin/docker/userdocker.html $download_Url/install/plugin/docker_en/userdocker.html -T 5
  fi
  echo '安装完成' > $install_tmp
}


upload_docker()
{
  echo '正在安装脚本文件...' > $install_tmp
  grep "English" /www/server/panel/config/config.json
  if [ "$?" -ne 0 ];then
    wget -O /www/server/panel/plugin/docker/docker_main.py $download_Url/install/plugin/docker/docker_main.py -T 5
    wget -O /www/server/panel/plugin/docker/index.html $download_Url/install/plugin/docker/index.html -T 5
    wget -O /www/server/panel/plugin/docker/info.json $download_Url/install/plugin/docker/info.json -T 5
    wget -O /www/server/panel/plugin/docker/icon.png $download_Url/install/plugin/docker/icon.png -T 5
    wget -O /www/server/panel/plugin/docker/login-docker.html $download_Url/install/plugin/docker/login-docker.html -T 5
    wget -O /www/server/panel/plugin/docker/userdocker.html $download_Url/install/plugin/docker/userdocker.html -T 5
  else
    wget -O /www/server/panel/plugin/docker/docker_main.py $download_Url/install/plugin/docker_en/docker_main.py -T 5
    wget -O /www/server/panel/plugin/docker/index.html $download_Url/install/plugin/docker_en/index.html -T 5
    wget -O /www/server/panel/plugin/docker/info.json $download_Url/install/plugin/docker_en/info.json -T 5
    wget -O /www/server/panel/plugin/docker/icon.png $download_Url/install/plugin/docker_en/icon.png -T 5
    wget -O /www/server/panel/plugin/docker/login-docker.html $download_Url/install/plugin/docker_en/login-docker.html -T 5
    wget -O /www/server/panel/plugin/docker/userdocker.html $download_Url/install/plugin/docker_en/userdocker.html -T 5
  fi
  echo '安装完成' > $install_tmp
}


Uninstall_docker()
{
  rm -rf /www/server/panel/plugin/docker
  rm -rf /var/lib/docker
  if [ -f "/usr/bin/apt-get" ];then
    systemctl stop docker
	sudo apt-get remove docker docker-engine docker.io containerd runc -y
	sudo apt-get purge docker-ce docker-ce-cli containerd.io -y
  elif [ -f "/usr/bin/yum" ];then
    if [ -f /usr/bin/systemctl ];then
      systemctl disable docker
      systemctl stop docker
    else
      service docker stop
      chkconfig --level 2345 docker off
      chkconfig --del docker
    yum remove docker docker-common docker-selinux docker-engine docker-client docker-client-latest docker-latest docker-latest-logrotate docker-logrotate -y
    fi
  fi
  
}

if [ "${1}" == 'install' ];then
  Install_docker
elif  [ "${1}" == 'update' ];then
  upload_docker
elif [ "${1}" == 'uninstall' ];then
  Uninstall_docker
fi

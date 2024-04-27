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
echo $download_Url

if [ ! -f "/etc/redhat-release" ];then
  systemver=`cat /etc/issue | grep -Ev '^$' | awk '{print $1}'`
else
  systemver=`cat /etc/redhat-release|sed -r 's/.* ([0-9]+)\..*/\1/'`
fi
echo $systemver


Install_Ubuntu_ce()
{
  sudo apt-get remove docker docker-engine docker.io containerd runc -y

  sudo apt-get update
  sudo apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common -y
#  echo 'deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable' >/etc/apt/sources.list.d/docker.list
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
  sudo apt-get update
  sudo apt-get install docker-ce docker-ce-cli containerd.io -y
#  update-rc.d docker defaults

  systemctl start docker
  echo 'move docker data to /www/server/docker ...';
  if [ -f /usr/bin/systemctl ];then
    systemctl stop docker
  else
    service docker stop
  fi
  if [ ! -d /www/server/docker ];then
    rm -f /www/server/docker
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
}


Install_debian_ce()
{
  sudo apt-get remove docker docker-engine docker.io containerd runc -y

  sudo apt-get update
  sudo apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common -y
#  echo 'deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable' >/etc/apt/sources.list.d/docker.list
  curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
  sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
  sudo apt-get update
  sudo apt-get install docker-ce docker-ce-cli containerd.io -y
#  update-rc.d docker defaults

  systemctl start docker
  echo 'move docker data to /www/server/docker ...';
  if [ -f /usr/bin/systemctl ];then
    systemctl stop docker
  else
    service docker stop
  fi
  if [ ! -d /www/server/docker ];then
    rm -f /www/server/docker
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
}


Install_Docker_ce()
{
  yum remove docker docker-common docker-selinux docker-engine -y
  yum install yum-utils device-mapper-persistent-data lvm2 -y
  yum install atomic-registries container-storage-setup containers-common oci-register-machine oci-systemd-hook oci-umount python-pytoml subscription-manager-rhsm-certificates yajl -y
#  if [[ $systemver = "7" ]]; then
  yum install $download_Url/install/plugin/docker/containerd.io-1.4.3-3.1.el7.x86_64.rpm -y
#  elif [[ $systemver = "8" ]]; then
#    yum install $download_Url/install/plugin/docker/containerd.io-1.4.3-3.1.el8.x86_64.rpm -y
#  fi
  grep "English" /www/server/panel/config/config.json
  if [ "$?" -ne 0 ];then
    yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
  else
    yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
  fi
  yum-config-manager --enable docker-ce-edge
  yum install docker-ce -y
  yum-config-manager --disable docker-ce-edge
  systemctl start docker
  echo 'move docker data to /www/server/docker ...';
  if [ -f /usr/bin/systemctl ];then
    systemctl stop docker
  else
    service docker stop
  fi
  if [ ! -d /www/server/docker ];then
    rm -f /www/server/docker
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

  #pull image of bt-panel
  #imageVersion='5.6.0'
  #docker pull registry.cn-hangzhou.aliyuncs.com/bt-panel/panel:$imageVersion
  #docker tag `docker images|grep bt-panel|awk '{print $3}'` bt-panel:$imageVersion
}


Install_docker()
{
  if [ -f "/usr/bin/yum" ];then
    yum install $download_Url/install/plugin/docker/containerd.io-1.4.3-3.1.el7.x86_64.rpm -y
  fi

  if [ ! -d /www/server/panel/plugin/docker ];then
    mkdir -p /www/server/panel/plugin/docker
    if [ -f "/usr/bin/apt-get" ];then
      if [[ $systemver = "Ubuntu" ]]; then
        Install_Ubuntu_ce
      elif [[ $systemver = "Debian" ]]; then
        Install_debian_ce
      fi
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

  # install python module
  if [ -f /usr/bin/btpip ];then
    btpip install pytz
    btpip install docker
  else
    pip install pytz
    pip install docker
  fi

  echo '安装完成' > $install_tmp
}


upload_docker()
{
  if [ -f "/usr/bin/yum" ];then
    yum install $download_Url/install/plugin/docker/containerd.io-1.4.3-3.1.el7.x86_64.rpm -y
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
  echo '更新完成' > $install_tmp
}


Uninstall_docker()
{
  rm -rf /www/server/panel/plugin/docker
  if [ -f "/usr/bin/apt-get" ];then
    systemctl stop docker
    sudo apt-get purge docker-ce docker-ce-cli containerd.io -y
  elif [ -f "/usr/bin/yum" ];then
    if [ -f /usr/bin/systemctl ];then
      systemctl disable docker
      systemctl stop docker
    else
      service docker stop
      chkconfig --level 2345 docker off
      chkconfig --del docker
    fi
    yum remove docker-ce docker-ce-cli containerd.io -y
  fi
  rm -rf /var/lib/docker
}


if [ "${1}" == 'install' ];then
  Install_docker
elif  [ "${1}" == 'update' ];then
  upload_docker
elif [ "${1}" == 'uninstall' ];then
  Uninstall_docker
fi

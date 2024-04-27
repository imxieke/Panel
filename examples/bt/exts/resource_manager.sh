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
echo 'download url...'
echo $download_Url

pluginPath=/www/server/panel/plugin/resource_manager

cpu_arch=`arch`

Install()
{
  if [[ $cpu_arch != "x86_64" ]];then
    echo '暂不支持非x86架构的系统安装'
    exit 0
  fi
  if [ -f "/usr/bin/apt-get" ];then
    apt install nethogs -y
  elif [ -f "/usr/bin/yum" ];then
    yum install nethogs -y
  fi
  mkdir -p $pluginPath
  echo '正在安装脚本文件...' > $install_tmp
  echo > $pluginPath/resource_manager_main.py
  wget -O $pluginPath/resource_manager_main.so $download_Url/install/plugin/resource_manager/resource_manager_main.so -T 5
  wget -O $pluginPath/resource_manager_main.cpython-36m-x86_64-linux-gnu.so $download_Url/install/plugin/resource_manager/resource_manager_main.cpython-36m-x86_64-linux-gnu.so -T 5
  wget -O $pluginPath/resource_manager_main.cpython-37m-x86_64-linux-gnu.so $download_Url/install/plugin/resource_manager/resource_manager_main.cpython-37m-x86_64-linux-gnu.so -T 5

  grep "English" /www/server/panel/config/config.json
  if [ "$?" -ne 0 ];then
    wget -O $pluginPath/index.html $download_Url/install/plugin/resource_manager/index.html -T 5
    wget -O $pluginPath/info.json $download_Url/install/plugin/resource_manager/info.json -T 5
    wget -O $pluginPath/icon.png $download_Url/install/plugin/resource_manager/icon.png -T 5
    wget -O $pluginPath/delete_task.py $download_Url/install/plugin/resource_manager/delete_task.py -T 5
  else
    wget -O $pluginPath/index.html $download_Url/install/plugin/resource_manager_en/index.html -T 5
    wget -O $pluginPath/info.json $download_Url/install/plugin/resource_manager_en/info.json -T 5
    wget -O $pluginPath/icon.png $download_Url/install/plugin/resource_manager_en/icon.png -T 5
    wget -O $pluginPath/delete_task.py $download_Url/install/plugin/resource_manager_en/delete_task.py -T 5
  fi
  \cp -a -r $pluginPath/icon.png /www/server/panel/BTPanel/static/img/soft_ico/ico-resource_manager.png
  ps -ef | grep nethogs | grep -v grep | awk '{print $2}' | xargs kill 2>/dev/null
  python $pluginPath/delete_task.py
  echo '安装完成' > $install_tmp
}

Uninstall()
{
  ps -ef | grep nethogs | grep -v grep | awk '{print $2}' | xargs kill 2>/dev/null
  python $pluginPath/delete_task.py
  rm -rf $pluginPath
}

if [ "${1}" == 'install' ];then
  Install
elif  [ "${1}" == 'update' ];then
  Install
elif [ "${1}" == 'uninstall' ];then
  Uninstall
fi

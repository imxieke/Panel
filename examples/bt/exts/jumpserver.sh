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

pluginPath=/www/server/panel/plugin/jumpserver

pyVersion=$(python -c 'import sys;print(sys.version_info[0]);')
py_zi=$(python -c 'import sys;print(sys.version_info[1]);')

Install_jumpserver()
{
  mkdir -p $pluginPath
  mkdir -p $pluginPath/templates
  echo > $pluginPath/jumpserver_main.py

  if [  -f /www/server/panel/pyenv/bin/python ];then
    /www/server/panel/pyenv/bin/pip install PySocks
    wget -O $pluginPath/jumpserver_main.so $download_Url/install/plugin/jumpserver/jumpserver_main.cpython-37m-x86_64-linux-gnu.so -T 5
    wget -O $pluginPath/aes2.so $download_Url/install/plugin/jumpserver/aes2.cpython-37m-x86_64-linux-gnu.so -T 5
    wget -O $pluginPath/aes3.so $download_Url/install/plugin/jumpserver/aes3.cpython-37m-x86_64-linux-gnu.so -T 5
	else
    pip install PySocks
    if [ "$pyVersion" == 2 ];then
      wget -O $pluginPath/jumpserver_main.so $download_Url/install/plugin/jumpserver/jumpserver_main.so -T 5
      wget -O $pluginPath/aes2.so $download_Url/install/plugin/jumpserver/aes2.so -T 5
      wget -O $pluginPath/aes3.so $download_Url/install/plugin/jumpserver/aes3.so -T 5
    else
      if [ "$py_zi" == 6 ];then
        wget -O $pluginPath/jumpserver_main.so $download_Url/install/plugin/jumpserver/jumpserver_main.cpython-36m-x86_64-linux-gnu.so -T 5
        wget -O $pluginPath/aes2.so $download_Url/install/plugin/jumpserver/aes2.cpython-36m-x86_64-linux-gnu.so -T 5
        wget -O $pluginPath/aes3.so $download_Url/install/plugin/jumpserver/aes3.cpython-36m-x86_64-linux-gnu.so -T 5
      fi
      if [ "$py_zi" == 7 ];then
        wget -O $pluginPath/jumpserver_main.so $download_Url/install/plugin/jumpserver/jumpserver_main.cpython-37m-x86_64-linux-gnu.so -T 5
        wget -O $pluginPath/aes2.so $download_Url/install/plugin/jumpserver/aes2.cpython-37m-x86_64-linux-gnu.so -T 5
        wget -O $pluginPath/aes3.so $download_Url/install/plugin/jumpserver/aes3.cpython-37m-x86_64-linux-gnu.so -T 5
      fi
    fi
  fi

  echo '正在安装脚本文件...' > $install_tmp
  grep "English" /www/server/panel/config/config.json
  if [ "$?" -ne 0 ];then
    rm -f $pluginPath/views.so
    wget -O $pluginPath/views.py $download_Url/install/plugin/jumpserver/views.py -T 5
    wget -O $pluginPath/index.html $download_Url/install/plugin/jumpserver/index.html -T 5
    wget -O $pluginPath/info.json $download_Url/install/plugin/jumpserver/info.json -T 5
    wget -O $pluginPath/icon.png $download_Url/install/plugin/jumpserver/icon.png -T 5
    wget -O $pluginPath/templates/jp_term_open.html $download_Url/install/plugin/jumpserver/templates/jp_term_open.html -T 5
  else
    rm -f $pluginPath/views.so
    wget -O $pluginPath/views.py $download_Url/install/plugin/jumpserver/views.py -T 5
    wget -O $pluginPath/index.html $download_Url/install/plugin/jumpserver_en/index.html -T 5
    wget -O $pluginPath/info.json $download_Url/install/plugin/jumpserver_en/info.json -T 5
    wget -O $pluginPath/icon.png $download_Url/install/plugin/jumpserver_en/icon.png -T 5
    wget -O $pluginPath/templates/jp_term_open.html $download_Url/install/plugin/jumpserver_en/templates/jp_term_open.html -T 5
  fi
  mkdir -p /www/server/panel/BTPanel/static/build
  wget -O /www/server/panel/BTPanel/static/build/asciinema-player.js $download_Url/install/plugin/jumpserver/asciinema-player.js -T 5
  wget -O /www/server/panel/BTPanel/static/build/asciinema-player.css $download_Url/install/plugin/jumpserver/asciinema-player.css -T 5
  \cp -a -r $pluginPath/icon.png /www/server/panel/BTPanel/static/img/soft_ico/ico-jumpserver.png
  echo '安装完成' > $install_tmp
}

Uninstall_jumpserver()
{
  rm -rf $pluginPath
}

if [ "${1}" == 'install' ];then
  Install_jumpserver
elif  [ "${1}" == 'update' ];then
  Install_jumpserver
elif [ "${1}" == 'uninstall' ];then
  Uninstall_jumpserver
fi

#!/bin/bash
PATH=/www/server/panel/pyenv/bin:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
install_tmp='/tmp/bt_install.pl'

public_file=/www/server/panel/install/public.sh
if [ ! -f $public_file ];then
    wget -O $public_file http://download.bt.cn/install/public.sh -T 5;
fi
. $public_file

download_Url=$NODE_URL

Install_obs()
{
    if hash btpip 2>/dev/null; then
        btpip install esdk-obs-python --trusted-host pypi.org
    else
        pip install esdk-obs-python --trusted-host pypi.org
    fi

    mkdir -p /www/server/panel/plugin/obs

    echo '正在安装脚本文件...' > $install_tmp
    wget -O /www/server/panel/plugin/obs/obs_main.py $download_Url/install/plugin/obs/obs_main.py -T 5
    wget -O /www/server/panel/plugin/obs/index.html $download_Url/install/plugin/obs/index.html -T 5
    wget -O /www/server/panel/plugin/obs/info.json $download_Url/install/plugin/obs/info.json -T 5
    wget -O /www/server/panel/plugin/obs/icon.png $download_Url/install/plugin/obs/icon.png -T 5
    wget -O /www/server/panel/static/img/soft_ico/ico-obs.png $download_Url/install/plugin/obs/icon.png -T 5
    echo '安装完成' > $install_tmp
}

Uninstall_obs()
{
    rm -rf /www/server/panel/plugin/obs
    if [ -f /www/server/panel/data/obsAS.conf ]; then
        rm -rf /www/server/panel/data/obsAS.conf
    fi
}

action=$1
if [ "${1}" == 'install' ];then
    Install_obs
else
    Uninstall_obs
fi


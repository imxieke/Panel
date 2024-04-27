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

Install_bos()
{
    if hash btpip 2>/dev/null; then
        btpip install bce-python-sdk==0.8.62
    else
        pip install bce-python-sdk==0.8.62
        pip install futures==3.3.0
    fi

    mkdir -p /www/server/panel/plugin/bos

    echo '正在安装脚本文件...' > $install_tmp
    wget -O /www/server/panel/plugin/bos/bos_main.py $download_Url/install/plugin/bos/bos_main.py -T 5
    wget -O /www/server/panel/plugin/bos/index.html $download_Url/install/plugin/bos/index.html -T 5
    wget -O /www/server/panel/plugin/bos/info.json $download_Url/install/plugin/bos/info.json -T 5
    wget -O /www/server/panel/plugin/bos/icon.png $download_Url/install/plugin/bos/icon.png -T 5
    \cp /www/server/panel/plugin/bos/icon.png /www/server/panel/BTPanel/static/img/soft_ico/ico-bos.png
    echo '安装完成' > $install_tmp
}

Uninstall_bos()
{
    rm -rf /www/server/panel/plugin/bos
    if [ -f /www/server/panel/data/bosAS.conf ]; then
        rm -rf /www/server/panel/data/bosAS.conf
    fi
}

action=$1
if [ "${1}" == 'install' ];then
    Install_bos
else
    Uninstall_bos
fi

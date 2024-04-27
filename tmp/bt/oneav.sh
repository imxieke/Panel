#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
install_tmp='/tmp/bt_install.pl'
pluginPath=/www/server/panel/plugin/oneav
public_file=/www/server/panel/install/public.sh
publicFileMd5=$(md5sum ${public_file} 2>/dev/null | awk '{print $1}')
md5check="bbc7c9ebfee02b8e5158b509a6ad642d"
if [ "${publicFileMd5}" != "${md5check}" ]; then
    wget -O Tpublic.sh http://download.bt.cn/install/public.sh -T 20
    publicFileMd5=$(md5sum Tpublic.sh 2>/dev/null | awk '{print $1}')
    if [ "${publicFileMd5}" == "${md5check}" ]; then
        \cp -rpa Tpublic.sh $public_file
    fi
    rm -f Tpublic.sh
fi
. $public_file

download_Url=${NODE_URL}

Install_oneav() {
    if [[ ! -d ${pluginPath} ]]; then
        mkdir -p ${pluginPath}
    fi
    echo '正在安装脚本文件...' >$install_tmp

    if [[ ! -f ${pluginPath}/oneav.bundle ]]; then
        wget -O ${pluginPath}/oneav.bundle ${download_Url}/install/src/oneav.bundle -t 10 -T 5
    fi
    bash ${pluginPath}/oneav.bundle -i -a oneav.threatbook.net -f
    if [[ "$?" == "0" ]]; then
        echo '安装完成' >$install_tmp
    else
        echo '安装失败' >$install_tmp
        exit 1
    fi
}

Uninstall_oneav() {
    bash ${pluginPath}/oneav.bundle -u
    rm -rf ${pluginPath}

    cat >/etc/crontab <<EOF
SHELL=/bin/bash
PATH=/sbin:/bin:/usr/sbin:/usr/bin
MAILTO=root

# For details see man 4 crontabs

# Example of job definition:
# .---------------- minute (0 - 59)
# |  .------------- hour (0 - 23)
# |  |  .---------- day of month (1 - 31)
# |  |  |  .------- month (1 - 12) OR jan,feb,mar,apr ...
# |  |  |  |  .---- day of week (0 - 6) (Sunday=0 or 7) OR sun,mon,tue,wed,thu,fri,sat
# |  |  |  |  |
# *  *  *  *  * user-name  command to be executed

EOF

}

if [ "${1}" == 'install' ]; then
    Install_oneav
elif [ "${1}" == 'uninstall' ]; then
    Uninstall_oneav
fi

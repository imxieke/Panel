#!/usr/bin/env bash
# @Author: imxieke
# @Date:   2021-10-18 02:10:39
# @Last Modified by:   imxieke
# @Last Modified time: 2021-10-18 11:40:48

cd /www/server/panel/install && /bin/bash install_soft.sh 3 install redis 6.2

wget http://125.90.93.52:5880/install/lib/script/backup_ftp.py
wget http://125.90.93.52:5880/install/src/panel.zip
wget http://125.90.93.52:5880/install/src/bt.init
wget http://dg1.bt.cn/install/5/lib.sh
wget http://dg1.bt.cn/install/0/php.sh
# wdcp install function
function wdcp_ins {
    [ -f $wdcp_inf ] && return
    cd $IN_SRC
    fileurl=$WDCP_URL && filechk
    fileurl=$PHPMYADMIN_URL && filechk
    mkdir -p /www/wdlinux/wdcp/{logs,data,tmp,rewrite,conf}
    tar zxvf phpmyadmin5.tar.gz -C /www/web/default
    pma=$(expr substr "$(echo $RANDOM | md5sum)" 1 8)
    cp -pR /www/web/default/phpmyadmin5 /www/wdlinux/wdcp/phpmyadmin
    mv /www/web/default/phpmyadmin5 /www/web/default/pma_${pma}
    tar zvxf wdcp_${WDCP_VER}_${BIT}.tar.gz -C /www/wdlinux/wdcp
    cd /www/wdlinux/wdcp
    ln -sf bin/wdcp_${WDCP_VER}_${BIT} wdcp
    chown root.root bin favicon.ico html static shell conf -R
    chmod 700 data shell bin conf
    [ $APA_ID == 2 ] && touch conf/apa24.conf
    if [ $OS_RL == 2 ];then
    file_cp wdcp.sh-ubuntu /www/wdlinux/wdcp/wdcp.sh
    ln -sf /www/wdlinux/wdcp/wdcp.sh /etc/init.d/wdcp
    update-rc.d -f wdcp defaults
    update-rc.d -f wdcp enable 235
    else
    wdcpinitd
    chkconfig --add wdcp
    chkconfig --level 35 wdcp on
    fi
    if [ $NPS == 1 ] && [ ! -z $NPD ];then
	touch /www/wdlinux/wdcp/phps/vid/$NPD
	file_cp start.sh /www/wdlinux/wdcp/phps/
	chmod 755 /www/wdlinux/wdcp/phps/start.sh
        echo $NPDS > /www/wdlinux/wdcp/conf/defp.conf
    fi 
    echo "pma_"${pma} > /www/wdlinux/wdcp/conf/phpmyadmin.conf
    echo "wdlinux.cn" > /www/wdlinux/wdcp/conf/mrpw.conf
    chmod 600 conf/*.conf
	service wdcp start
    echo $SERVER_ID > /www/wdlinux/wdcp/conf/eng.conf
    file_cp public_html.tar.gz /www/wdlinux/wdcp/data/
    file_cp dz7_apache.conf /www/wdlinux/wdcp/rewrite/
    file_cp dz7_nginx.conf /www/wdlinux/wdcp/rewrite/
    file_cp dzx32_apache.conf /www/wdlinux/wdcp/rewrite/
    file_cp dzx32_nginx.conf /www/wdlinux/wdcp/rewrite/
    touch $wdcp_inf
}


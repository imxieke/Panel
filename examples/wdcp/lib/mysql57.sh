# mysql install function
function mysql57_ins {
    local IN_LOG=$LOGPATH/${logpre}_mysql_install.log
    echo
    [ -f $mysql_inf ] && return
    echo "installing mysql,this may take a few minutes,hold on plz..."
    cd $IN_SRC
    fileurl=$MYSB_URL && filechk
    tar zvxf mysql-boost-$MYS_VER.tar.gz
    cd mysql-$MYS_VER/
    make_clean
    echo "configure in progress ..."
    cmake . -DCMAKE_INSTALL_PREFIX=$IN_DIR/mysql-$MYS_VER \
    -DMYSQL_DATADIR=$IN_DIR/mysql-$MYS_VER/data \
    -DDOWNLOAD_BOOST=1 \
    -DWITH_BOOST=boost/boost_1_59_0/ \
    -DSYSCONFDIR=/www/wdlinux/etc \
    -DWITH_INNOBASE_STORAGE_ENGINE=1 \
    -DWITH_PARTITION_STORAGE_ENGINE=1 \
    -DWITH_FEDERATED_STORAGE_ENGINE=1 \
    -DWITH_BLACKHOLE_STORAGE_ENGINE=1 \
    -DWITH_MYISAM_STORAGE_ENGINE=1 \
    -DWITH_EMBEDDED_SERVER=1 \
    -DENABLE_DTRACE=0 \
    -DENABLED_LOCAL_INFILE=1 \
    -DDEFAULT_CHARSET=utf8mb4 \
    -DDEFAULT_COLLATION=utf8mb4_general_ci \
    -DEXTRA_CHARSETS=all
    [ $? != 0 ] && err_exit "mysql configure err"
    echo "make in progress ..."
    make -j $CPUS
    [ $? != 0 ] && err_exit "mysql make err"
    echo "make install in progress ..."
    make install 
    [ $? != 0 ] && err_exit "mysql install err"
	[ -f $IN_DIR/mysql ] && rm -f $IN_DIR/mysql
    ln -sf $IN_DIR/mysql-$MYS_VER $IN_DIR/mysql
    [ -f /etc/my.cnf ] && mv /etc/my.cnf /etc/my.cnf.old
    cp support-files/mysql.server $IN_DIR/init.d/mysqld
    file_cp my57.cnf $IN_DIR/etc/my.cnf
    ln -sf $IN_DIR/etc/my.cnf /etc/my.cnf
    $IN_DIR/mysql-$MYS_VER/bin/mysqld --initialize-insecure --user=mysql --basedir=$IN_DIR/mysql-$MYS_VER --datadir=$IN_DIR/mysql-$MYS_VER/data
	[ $? == 0 ] || rm -fr $IN_DIR/mysql-$MYS_VER/data && $IN_DIR/mysql-$MYS_VER/bin/mysqld --initialize-insecure --user=mysql --basedir=$IN_DIR/mysql-$MYS_VER --datadir=$IN_DIR/mysql-$MYS_VER/data
	chown -R mysql.mysql $IN_DIR/mysql/data
    chmod 755 $IN_DIR/init.d/mysqld
    ln -sf $IN_DIR/init.d/mysqld /etc/init.d/mysqld
    if [ $OS_RL == 2 ]; then
        update-rc.d -f mysqld defaults
    else
        chkconfig --add mysqld
        chkconfig --level 35 mysqld on
    fi
    ln -sf $IN_DIR/mysql/bin/mysql /bin/mysql
    mkdir -p /var/lib/mysql
    service mysqld start
    echo "PATH=\$PATH:$IN_DIR/mysql/bin" > /etc/profile.d/mysql.sh
    echo "$IN_DIR/mysql" > /etc/ld.so.conf.d/mysql-wdl.conf
    ldconfig 
    $IN_DIR/mysql-$MYS_VER/bin/mysql -e "grant all privileges on *.* to root@'127.0.0.1' identified by \"wdlinux.cn\" with grant option;"
    $IN_DIR/mysql-$MYS_VER/bin/mysql -e "grant all privileges on *.* to root@'localhost' identified by \"wdlinux.cn\" with grant option;"
    [ -d /var/lib/mysql ] && ln -sf /tmp/mysql.sock /var/lib/mysql/
    cd $IN_SRC
    rm -fr mysql-$MYS_VER
    touch $mysql_inf
}
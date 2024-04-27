# redis install function
function redis_ins {
    local IN_LOG=$LOGPATH/${logpre}_apache_install.log
    echo
    if [ ! -f $redis_inf ];then
    echo "installing redis..."
    cd $IN_SRC
    fileurl=$REDIS_URL && filechk
    tar -zxvf redis-stable.tar.gz
    cd redis-stable
    make 
    [ $? != 0 ] && err_exit "redis make err"
    make install 
    [ $? != 0 ] && err_exit "redis install err"

    cd utils/
    echo "\n" | ./install_server.sh
    chmod 755 /etc/init.d/redis_6379
    chkconfig --add redis_6379
    chkconfig --level 345 redis_6379 on

    cd $IN_SRC
    rm -fr redis-stable
    touch $redis_inf
    fi
}

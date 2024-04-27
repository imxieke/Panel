# libzip install function
function libzip_ins {
    local IN_LOG=$LOGPATH/${logpre}_libzip_install.log
    echo
    [ -f $libzip_inf ] && return
    echo "installing mcrypt..."
    cd $IN_SRC
    fileurl=$LIBZIP_URL && filechk
    tar xf libzip-$LIBZIP_VER.tar.gz
    cd libzip-$LIBZIP_VER
    ./configure --prefix=/usr
    [ $? != 0 ] && err_exit "libzip configure err"
    make
    [ $? != 0 ] && err_exit "libzip make err"
    make install
    [ $? != 0 ] && err_exit "libzip install err"
    ldconfig
    cd $IN_SRC
    rm -fr libzip-$LIBZIP_VER
    touch $libzip_inf
}


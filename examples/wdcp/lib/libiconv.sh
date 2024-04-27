# libiconv install function
function libiconv_ins {
    echo "installing libiconv..."
    tar xzf libiconv-${libiconv_ver}.tar.gz
    pushd libiconv-${libiconv_ver} > /dev/null
    ./configure
    make -j ${THREAD} && make install
    popd > /dev/null
    rm -rf libiconv-${libiconv_ver}
    tar xzf freetype-${freetype_ver}.tar.gz
    pushd freetype-${freetype_ver} > /dev/null
    ./configure --prefix=${freetype_install_dir} --enable-freetype-config
    make -j ${THREAD} && make install
    ln -sf ${freetype_install_dir}/include/freetype2/* /usr/include/
    [ -d /usr/lib/pkgconfig ] && /bin/cp ${freetype_install_dir}/lib/pkgconfig/freetype2.pc /usr/lib/pkgconfig/
    popd > /dev/null
    rm -rf freetype-${freetype_ver}
    tar xzf argon2-${argon2_ver}.tar.gz
    pushd argon2-${argon2_ver} > /dev/null
    make -j ${THREAD} && make install
    [ ! -d /usr/local/lib/pkgconfig ] && mkdir -p /usr/local/lib/pkgconfig
    /bin/cp libargon2.pc /usr/local/lib/pkgconfig/
    popd > /dev/null
    rm -rf argon2-${argon2_ver}
    tar xzf libsodium-${libsodium_ver}.tar.gz
    pushd libsodium-${libsodium_ver} > /dev/null
    ./configure --disable-dependency-tracking --enable-minimal
    make -j ${THREAD} && make install
    popd > /dev/null
    rm -rf libsodium-${libsodium_ver}
    export  PKG_CONFIG_PATH=/usr/local/lib/pkgconfig
    source /etc/profile
    tar xzf libzip-${libzip_ver}.tar.gz
    pushd libzip-${libzip_ver} > /dev/null
    ./configure
    make -j ${THREAD} && make install
    popd > /dev/null
    rm -rf libzip-${libzip_ver}
}


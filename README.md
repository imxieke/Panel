## Dockenv Docker + Debian 12+ /Alpine 3.18+ 集成环境

### Downloaded
- http://dl.wdcp.net/files/lanmp.tar.gz

## Server App
- https://github.com/aaPanel/BT-WAF
- https://github.com/alexazhou/VeryNginx
- https://github.com/nginx-proxy/nginx-proxy
- https://github.com/openresty/openresty
- https://github.com/openresty/docker-openresty
- https://github.com/titansec/OpenWAF

## Mirrors
http://php.vpszt.com/php-ver.tar.bz2
https://files.phpmyadmin.net/phpMyAdmin/${VER}/phpMyAdmin-${VER}-all-languages.tar.xz
http://nginx.org/download/nginx-$VER.tar.gz

./acme.sh --install --log --home /usr/local/acme.sh --certhome /usr/local/nginx/conf/ssl
/etc/init.d/cron restart
update-rc.d cron defaults
/usr/local/acme.sh/acme.sh --issue ${letsdomain} -w ${vhostdir} --reloadcmd "/etc/init.d/nginx reload"

## Support Env
- php 5.6 ~ 8.3
- nginx
- mysql 5.7 8.0
- mariadb
- redis
- mongodb
- postgresql

- useradmin
- usermin
- usermin-webmail
- webmin
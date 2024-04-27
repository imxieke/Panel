#!/usr/bin/env bash
###
 # @Author: Cloudflying
 # @Date: 2023-10-15 20:08:16
 # @LastEditTime: 2023-10-15 20:31:08
 # @LastEditors: Cloudflying
 # @Description: High performance, full-stack PHP framework delivered as a C extension.
### 

phpold()
{
	# Support PHP 5.5-7.1
	VER="3.4.5"
	URL="https://github.com/phalcon/cphalcon/archive/refs/tags/v3.4.5.tar.gz"
}

php73()
{
	# PHP <= 7.3 && >= 7.2
	VER='4.1.2'
	URL="https://github.com/phalcon/cphalcon/releases/download/v${VER}/phalcon-pecl.zip"
}

php74()
{
	VER='5.3.1'
	URL="https://github.com/phalcon/cphalcon/releases/download/v${VER}/phalcon-php7.4-nts-ubuntu-gcc-x64.zip"
}

php80()
{
	VER='5.3.1'
	URL="https://github.com/phalcon/cphalcon/releases/download/v${VER}/phalcon-php8.0-nts-ubuntu-gcc-x64.zip"
}

php81()
{
	VER='5.3.1'
	URL="https://github.com/phalcon/cphalcon/releases/download/v${VER}/phalcon-php8.1-nts-ubuntu-gcc-x64.zip"
}

php82()
{
	VER='5.3.1'
	URL="https://github.com/phalcon/cphalcon/releases/download/v${VER}/phalcon-php8.2-nts-ubuntu-gcc-x64.zip"
}

php83()
{
	VER='5.3.1'
	URL="https://github.com/phalcon/cphalcon/releases/download/v${VER}/phalcon-php8.2-nts-ubuntu-gcc-x64.zip"
}

php84()
{
	VER='5.3.1'
	URL="https://github.com/phalcon/cphalcon/releases/download/v${VER}/phalcon-php8.2-nts-ubuntu-gcc-x64.zip"
}

_compile()
{
	./configure \
		--prefix=/ \
		--enable-phalcon
}
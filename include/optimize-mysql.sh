#!/usr/bin/env bash
###
# @Author: Cloudflying
# @Date: 2023-11-01 20:53:31
 # @LastEditTime: 2023-11-01 21:34:13
 # @LastEditors: Cloudflying
# @Description:
###

source env.sh

case ${MEMORY} in
256)
	innodb_log_file_size=32M
	innodb_buffer_pool_size=64M
	open_files_limit=512
	table_open_cache=200
	max_connections=64
	;;
512)
	innodb_log_file_size=32M
	innodb_buffer_pool_size=128M
	open_files_limit=512
	table_open_cache=200
	max_connections=128
	;;
1024)
	innodb_log_file_size=64M
	innodb_buffer_pool_size=256M
	open_files_limit=1024
	table_open_cache=400
	max_connections=256
	;;
2048)
	innodb_log_file_size=64M
	innodb_buffer_pool_size=512M
	open_files_limit=1024
	table_open_cache=400
	max_connections=300
	;;
4096)
	innodb_log_file_size=128M
	innodb_buffer_pool_size=1G
	open_files_limit=2048
	table_open_cache=800
	max_connections=400
	;;
8192)
	innodb_log_file_size=256M
	innodb_buffer_pool_size=2G
	open_files_limit=4096
	table_open_cache=1600
	max_connections=400
	;;
16384)
	innodb_log_file_size=512M
	innodb_buffer_pool_size=4G
	open_files_limit=8192
	table_open_cache=2000
	max_connections=512
	;;
32768)
	innodb_log_file_size=512M
	innodb_buffer_pool_size=8G
	open_files_limit=65535
	table_open_cache=2048
	max_connections=1024
	;;
*) echo "input error, please input a number" ;;
esac

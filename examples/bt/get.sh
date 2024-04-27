#!/usr/bin/env bash
# @Author: imxieke
# @Date:   2021-10-18 01:38:10
# @Last Modified by:   imxieke
# @Last Modified time: 2021-10-18 10:56:49

get_exts()
{
	name=$1
	url="http://125.90.93.52:5880/install/plugin/$name/install.sh"
	# curl -I $url
	wget $url -O ${name}.sh
}

plugins='firewall boot linuxsys score supervisor clear site_speed coll_admin nodejs java_manager tomcat2 static_cdn btappmanager fail2ban mail_sys dns_manager pythonmamager psync_api deployment pgsql_manager upyun total btwaf btwaf_httpd task_manager btapp rsync bt_ssh_auth load_balance msg_push masterslave syssafe tamper_proof app nfs_tools btwaf php_filter btwaf_httpd task_manager btapp rsync bt_ssh_auth bt_security node_admin oos san_security load_balance msg_push masterslave free_waf mfsearch redisutil hm_shell_san publicwelfare404 baidu_push sshkey pysqliteadmin portblast w7assistant openrasp yichaxin su_baidu 616seo qrcode ehost my_toolbox Phddns shorturl qiankeji disk mfboot btco fecmall free_promotion baidu_netdisk chafenba swn y6w_speedtest sitemap ftp alioss txcdn qiniu aws_s3 dnspod gdrive gcloud_storage cosfs webhook phpguard txcos webssh bos obs backup anti_spam msonedrive dns syssafe tamper_proof app tamper_drive users bt_boce jumpserver nfs_tools database_mater site_optimization resource_manager enterprise_backup ssl_verify fastosdocker urlpush linksforbt btgitea disktool lzfhdwz panel_jsbridge_installer wxapijnoocom jexus git_repository_deploy svn_deploy qnoss seos svn west_fss mflogview y6w_createwebs aloss git_deploy cloud_db_diff whois bt_vsftpd mfwatermark xjTools yb_wm aliddns autoshield txoss tuboshufenxi nfsgo diskquota a_site_click btrenwubeifen mfftpdev bdbos jimjiami cloud189 hash_pk build_website site_cluster myhaproxy tencent_cdn cloudflare autoclear tpl_hyaline colscript ssh_manager cf_ipchange jdoss dnspod_ddns mounter mysqlfind imgtools php_encoder customtime typechomg dnspod_parsing_switch baktomail ftplimit dnspod_record server_port_watcher btapibot hwobs btgogs us3 server_proxy_res hxsquota'

# get_exts $1
cd exts

for ext in ${plugins}; do
	echo $ext
	get_exts $ext
done
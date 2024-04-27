#!/bin/sh
# Ispmanager install.pkg

#set -e


LOG_PIPE=/tmp/log.pipe.$$
mkfifo ${LOG_PIPE}
LOG_FILE=/tmp/log.file.$$


FAILSAFEMIRROR=mirrors.download.ispmanager.com
SCHEMA=https

tee < ${LOG_PIPE} ${LOG_FILE} &

exec  > ${LOG_PIPE}
exec  2> ${LOG_PIPE}

LogClean() {
	rm -f ${LOG_PIPE}
	rm -f ${LOG_FILE}
}

EU=false

Usage()
{
	cat << EOU >&2

Usage:
	$0 --help 	Print this help

	$0 [options] [mgrname]
	--osfamily <FAMILY>     REDHAT, DEBIAN . Force if can not be detected.
	--osversion <VERSION>   Version for OS. Example: wheezy for debain, 6 for centos. Force if can not be detected.
	--release <type>        Installs managers non-interactively with desired release <type>.
	--noinstall             Not install packages. Just add repository. Also disable mirror detecting.
	--ignore-hostname       Ignore incorrect hostname.
	--silent                Do not ask hostname and activation key. Exit on these errors immediatly. Also enabling --ignore-hostname
	--no-letsencrypt        Disable automatic certificate generation
	--le-domain             Domain for LetsEncrypt certificate. Also can be set by LE_DOMAIN environment variable
	--disable-fail2ban      Disable fail2ban setup
	--ispmgr5               Force 5 version of ispmgr
	--openlitespeed         Install OpenLiteSpeed web server (takes effect only when mgrname=ispmanager-lite)
	--dbtype <type>         mysql, sqlite . Type of database to be used by ispmanager. Default - sqlite.
	--mysql-server <type>	mysql, mariadb . MySQL server engine. Only on Ubuntu and RedHat based 8-9. Ispmanager lite, pro, host.
	--allow-eol-os          Allow to install on EOL OS.
	
EOU
}

GetMgrUrl() {
	# ${1} - mgr
	if [ -z "${1}" ]; then echo "Empty arg 1" ; return 1; fi

	if [ -n "${IPADDR}" ]; then
		echo "https://${IPADDR}/${1}"
	else

		ihttpd_port=1500

		IPADDR=$(echo "${SSH_CONNECTION}" | awk '{print $3}')
		if [ -z "${IPADDR}" ]; then
			if [ "${ISPOSTYPE}" = "FREEBSD" ]; then
				IPADDR=$(ifconfig | awk '$1 ~ /inet/ && $2 !~ /127.0.0|::1|fe80:/ {print $2}' |cut -d/ -f1 | head -1)
			else
				IPADDR=$(ip addr show | awk '$1 ~ /inet/ && $2 !~ /127.0.0|::1|fe80:/ {print $2}' |cut -d/ -f1 | head -1)
			fi
		fi

		if echo "${IPADDR}" | grep -q ':' ; then
			SHOWIPADDR="[${IPADDR}]"
		else
			SHOWIPADDR=${IPADDR}
		fi
		echo "https://${SHOWIPADDR}:1500/${1}"
	fi
}

PkgInstalled() {
	case ${ISPOSTYPE} in
		REDHAT)
			# shellcheck disable=SC2086
			rpm -q ${1} >/dev/null 2>&1 ; return $?
		;;
		DEBIAN)
			# shellcheck disable=SC2086
			dpkg -s ${1} >/dev/null 2>&1 ; return $?
		;;
		*)
			:
		;;
	esac
}

PkgAvailable() {
	case ${ISPOSTYPE} in
		REDHAT)
			# shellcheck disable=SC2086
			yum -q -C info ${1} >/dev/null 2>/dev/null
		;;
		DEBIAN)
			# shellcheck disable=SC2086
			apt-cache -q show ${1} | grep -q "${1}" >/dev/null 2>/dev/null
		;;
		*)
		;;
	esac
}


MgrInstalled() {
	if [ -z "${1}" ]; then echo "Empty arg 1" ; return 1; fi
	if [ -z "${2}" ]; then echo "Empty arg 2" ; return 1; fi
	Info "================================================="
	Info "$2 is installed"
	local MGRDOMAIN
	if [ -n "${LE_DOMAIN}" ]; then
		MGRDOMAIN="${LE_DOMAIN}"
	else
		# shellcheck disable=SC2039,SC2155,SC2086
		MGRDOMAIN=$(/usr/local/mgr5/sbin/licctl info ${mgr} | awk -F"[: \t]+" '$1 == "JustInstalled" {print $2}')
	fi
	if [ -n "${MGRDOMAIN}" ] && ! echo "${MGRDOMAIN}" | grep -qE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' ; then
		# TEST FUNCTION
		Info "Go to the \"https://${MGRDOMAIN}:1500/${mgr}\" to login"
		Info "Login: root"
		Info "Password: <root password>"
		Info ""
		echo "If this doesn't work you can use IP instead of domain"
		# shellcheck disable=SC2086
		echo "Like: \"$(GetMgrUrl ${mgr})\""
	else
		# shellcheck disable=SC2086
		Info "Go to the \"$(GetMgrUrl ${mgr})\" to login"
		Info "Login: root"
		Info "Password: <root password>"
	fi
	Info "================================================="
}

OpenFirewall() {
	# shellcheck disable=SC2039
	local port
	port=${1}
	if which firewall-cmd >/dev/null 2>&1 && service firewalld status >/dev/null ; then
		# shellcheck disable=SC2086
		firewall-cmd --zone=public --add-port ${port}/tcp
	elif [ -f /sbin/iptables ]; then
		# shellcheck disable=SC2086
		iptables -I INPUT -p tcp --dport ${port} -j ACCEPT
	fi
}

CloseFirewall() {
	# shellcheck disable=SC2039
	local port
	port=${1}
	if which firewall-cmd >/dev/null 2>&1 && service firewalld status >/dev/null ; then
		# shellcheck disable=SC2086
		firewall-cmd --zone=public --remove-port ${port}/tcp || :
	elif [ -f /sbin/iptables ]; then
		# shellcheck disable=SC2086
		iptables -D INPUT -p tcp --dport ${port} -j ACCEPT || :
	fi
}

LetsEncrypt() {
	test -n "${no_letsencrypt}" && return
	local MGRDOMAIN
	if [ -n "${LE_DOMAIN}" ]; then
		MGRDOMAIN="${LE_DOMAIN}"
	else
		# shellcheck disable=SC2039,SC2155,SC2086
		MGRDOMAIN=$(/usr/local/mgr5/sbin/licctl info ${mgr} | awk -F"[: \t]+" '$1 == "JustInstalled" {print $2}')
	fi
	if [ -n "${MGRDOMAIN}" ] && ! echo "${MGRDOMAIN}" | grep -qE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' ; then
		if [ -x /usr/local/mgr5/sbin/letsencrypt.sh ]; then
			Info "Trying to get and install Let\`s Encrypt certificate"
			OpenFirewall 80 || :
			local apache_start=
			if [ "${ISPOSTYPE}-${OSVER}" = "DEBIAN-xenial" ] && [ -z "${core_installed}" ]; then
				if service apache2 status >/dev/null 2>&1 ; then
					service apache2 stop
					apache_start=yes
				fi
			fi
			# shellcheck disable=SC2086
			/usr/local/mgr5/sbin/letsencrypt.sh ${MGRDOMAIN} || :
			if [ -n "${apache_start}" ]; then
				service apache2 start
			fi
			CloseFirewall 80 || :
		fi
	fi
}


centos_OSVERSIONS="6 7 8 9"
centos_EOL_OSVERSIONS="6"

debian_OSVERSIONS="wheezy jessie stretch buster bullseye"
debian_EOL_OSVERSIONS="wheezy jessie stretch"

ubuntu_OSVERSIONS="trusty xenial bionic focal jammy"
ubuntu_EOL_OSVERSIONS="trusty xenial bionic"

export DEBIAN_FRONTEND=noninteractive
export NOTIFY_SERVER=https://mgr5stat.ispmanager.tech:8443/notify/v1

CheckRoot() {
	if [ "$(id -u)" != "0" ]; then
		Error "You must be root user to continue"
		exit 1
	fi
	# shellcheck disable=SC2039,SC2155
	local RID=$(id -u root 2>/dev/null)
	# shellcheck disable=SC2181
	if [ $? -ne 0 ]; then
		Error "User root no found. You should create it to continue"
		exit 1
	fi
	if [ "${RID}" -ne 0 ]; then
		Error "User root UID not equals 0. User root must have UID 0"
		exit 1
	fi
}

Infon() {
	# shellcheck disable=SC2059,SC2145
	printf "\033[1;32m$@\033[0m"
}

Info()
{
	# shellcheck disable=SC2059,SC2145
	Infon "$@\n"
}

Warningn() {
	# shellcheck disable=SC2059,SC2145
	printf "\033[1;35m$@\033[0m"
}

Warning()
{
	# shellcheck disable=SC2059,SC2145
	Warningn "$@\n"
}

Warnn()
{
	# shellcheck disable=SC2059,SC2145
	Warningn "$@"
}

Warn()
{
	# shellcheck disable=SC2059,SC2145
	Warnn "$@\n"
}

Error()
{
	# shellcheck disable=SC2059,SC2145
	printf "\033[1;31m$@\033[0m\n"
}

DetectManager() {
	if [ "${MIGRATION}" != "mgr5" ] && [ "${noinstall}" != "true" ] && [ -d /usr/local/ispmgr ]; then
		# shellcheck disable=SC2039,SC2155,SC2012
		local MGRLIST=$(ls /usr/local/ispmgr/bin/ 2>/dev/null | tr '\n' ' ')
		Error "Old managers is installed: ${MGRLIST}"
		exit 1
	fi
}

CheckAppArmor() {
	# Check if this ubuntu
	[ "${ISPOSTYPE}" = "DEBIAN" ] || return 0
	[ "$(lsb_release -s -i)" = "Ubuntu" ] || return 0
	if service apparmor status >/dev/null 2>&1 ; then
#		if [ -n "$release" ] || [ -n "$silent" ]; then
#			Error "Apparmor is enabled, aborting installation."
#			exit 1
#		fi
		Error "AppArmor is enabled on your server. Can not install with AppArmor. Trying to disable it"
		service apparmor stop
		service apparmor teardown || :
		update-rc.d -f apparmor remove
	fi
}

CheckSELinux() {
	# shellcheck disable=SC2039,SC2155
	local kern=$(uname -s)
	if [ "$kern" = "Linux" ]; then
		if selinuxenabled > /dev/null 2>&1 ; then
			# silent install
			if [ -n "$release" ] || [ -n "$silent" ]; then
				Error "SELinux is enabled, aborting installation."
				exit 1
			fi
			Error "SELinux is enabled on your server. It is strongly recommended to disable SELinux before you proceed."
			# shellcheck disable=SC2039,SC2155
			local uid=$(id -u)
			# do we have a root privileges ?
			if [ "$uid" = "0" ]; then
				# shellcheck disable=SC2039
				echo -n "Would you like to disable SELinux right now (yes/no)?"
				# shellcheck disable=SC2039
				local ask1
				ask1="true"
				while [ "$ask1" = "true" ]
				do
					ask1="false"
					# shellcheck disable=SC2162
					read answer
					if [ -z "$answer" ] || [ "$answer" = "yes" ]; then
						# do disable SELinux
						setenforce 0 >/dev/null 2>&1
						cp -n /etc/selinux/config /etc/selinux/config.orig >/dev/null 2>&1
						echo SELINUX=disabled > /etc/selinux/config
						Error "Reboot is requred to complete the configuration of SELinux."
						# shellcheck disable=SC2039
						echo -n "Reboot now (yes/no)?"
						# shellcheck disable=SC2039
						local ask2
						ask2="true"
						while [ "$ask2" = "true" ]
						do
							ask2="false"
							# shellcheck disable=SC2162
							read answer
							if [ "$answer" = "yes" ]; then
								Info "Rebooting now. Please start installation script again once the server reboots."
								shutdown -r now
								exit 0
							elif [ "$answer" = "no" ]; then
								Error "It is strongly recommended to reboot server before you proceed the installation"
							else
								ask2="true"
								# shellcheck disable=SC2039
								echo -n "Please type 'yes' or 'no':"
							fi
						done
					elif [ "$answer" != "no" ]; then
						ask1="true";
						# shellcheck disable=SC2039
						echo -n "Please type 'yes' or 'no':"
					fi
				done
			fi
		fi
	fi
}

DetectFetch()
{
	if [ -x /usr/bin/fetch ]; then
		fetch="/usr/bin/fetch -o "
	elif [ -x /usr/bin/wget ]; then
		# shellcheck disable=SC2154
		if [ "$unattended" = "true" ]; then
			fetch="/usr/bin/wget -T 30 -t 10 --waitretry=5 -q -O "
		else
			fetch="/usr/bin/wget -T 30 -t 10 --waitretry=5 -q -O "
		fi
	elif [ -x /usr/bin/curl ]; then
		fetch="/usr/bin/curl --connect-timeout 30 --retry 10 --retry-delay 5 -o "
	else
		Error "ERROR: no fetch program found."
		exit 1
	fi
}

OSDetect() {
	test -n "${ISPOSTYPE}" && return 0
	ISPOSTYPE=unknown
	kern=$(uname -s)
	case "${kern}" in
		Linux)
		if [ -f /etc/redhat-release ] || [ -f /etc/centos-release ]; then
			# RH family
			export ISPOSTYPE=REDHAT
		elif [ -f /etc/debian_version ]; then
			# DEB family
			export ISPOSTYPE=DEBIAN
		fi
		;;
		FreeBSD)
			# FreeBSD
			export ISPOSTYPE=FREEBSD
		;;
	esac
	if [ "#${ISPOSTYPE}" = "#unknown" ]; then
		Error "Unknown os type. Try to use \"--osfamily\" option"
		exit 1
	fi

}


BadHostname() {
	test -z "${1}" && return 1
	# shellcheck disable=SC2039
	local HOSTNAME=${1}

	LENGTH=$(echo "${HOSTNAME}" | wc -m)
	if [ "${LENGTH}" -lt 2 ] || [ "${LENGTH}" -gt 50 ]; then
		return 1
	fi
	if ! echo "${HOSTNAME}" | grep -q '\.'; then
		return 1
	fi
	if echo "${HOSTNAME}" | grep -q '_'; then
		return 1
	fi
	local TOPLEVEL=$(echo "${HOSTNAME}" | awk -F. '{print $NF}')
	if [ -z "${TOPLEVEL}" ]; then
		return 1
	fi
	if [ -n "$(echo "${TOPLEVEL}" | sed -r 's/[a-zA-Z0-9\-]//g')" ]; then
		return 1
	fi
}


GetFirstIp() {
	if [ -n "$(which ip 2>/dev/null)"  ]; then
		ip route get 1 | awk '{print $NF;exit}'
	fi
}


SetHostname() {
	# 1 - new hostname
	# 2 - old hostname
	test -z "${1}" && return 1
#	test -z "${2}" && return 1
	# shellcheck disable=SC2039,SC2086
	local HOSTNAME=$(echo ${1} | sed 's|\.+$||')
	case "${ISPOSTYPE}" in
	REDHAT)
		# shellcheck disable=SC2086
		hostname ${HOSTNAME} || return 1
		sed -i -r "s|^HOSTNAME=|HOSTNAME=${HOSTNAME}|" /etc/sysconfig/network || return 1
		if [ -n "${2}" ]; then
			sed -i -r "s|${2}|${HOSTNAME}|g" /etc/hosts || return 1
		fi
		;;
	DEBIAN)
		# shellcheck disable=SC2039,SC2116,SC2086
		local CUTHOSTNAME=$(echo ${HOSTNAME%\.*})
		# shellcheck disable=SC2086
		hostname ${CUTHOSTNAME} || return 1
		echo "${CUTHOSTNAME}" > /etc/hostname || return 1
		if [ -n "${2}" ]; then
			sed -i -r "s|${2}|${HOSTNAME}|g" /etc/hosts || return 1
		fi
		if ! hostname -f >/dev/null 2>&1 ; then
			sed -i -r "s|^([0-9\.]+\s+)${HOSTNAME}\s*$|\1${HOSTNAME} ${CUTHOSTNAME}|g" /etc/hosts
		fi
		if ! hostname -f >/dev/null 2>&1 ; then
			echo "$(GetFirstIp) ${HOSTNAME} ${CUTHOSTNAME}" >> /etc/hosts
		fi
		if ! hostname -f >/dev/null 2>&1 ; then
			Error "Can not set hostname"
			return 1
		fi
		;;
	esac
}

CheckHostname() {
	if [ "${ISPOSTYPE}" = "DEBIAN" ]; then
		# shellcheck disable=SC2039
		local CURHOSTNAME=$(hostname -f ||:)
	else
		# shellcheck disable=SC2039
		local CURHOSTNAME=$(hostname || :)
	fi
	# shellcheck disable=SC2039
	local HOSTNAME=${CURHOSTNAME}
	if [ "#${silent}" != "#true" ]; then
		# shellcheck disable=SC2086
		while ! BadHostname ${HOSTNAME};
		do
			Error "You have incorrect hostname: ${HOSTNAME}"
			# shellcheck disable=SC2039,SC2162
			read -p "Enter new hostname(or Ctrl+C to exit): " HOSTNAME
			echo
		done
		Info "You have hostname: ${HOSTNAME}"
		if [ ! "${CURHOSTNAME}" = "${HOSTNAME}" ]; then
			# shellcheck disable=SC2039
			local err_hn=0
			# shellcheck disable=SC2086
			SetHostname ${HOSTNAME} ${CURHOSTNAME} || err_hn=1
			if [ ${err_hn} -ne 0 ]; then
				echo
				Error "Can not change hostname. Please change it manually"
				exit 1
			fi
		fi
	else
		# shellcheck disable=SC2086
		if ! BadHostname ${HOSTNAME}; then
			Error "You have incorrect hostname: ${HOSTNAME}"
			Error "Please change it manually"
			exit 1
		fi
	fi
}


OSVersion() {
	test -n "${OSVER}" && return 0
	OSVER=unknown
	case ${ISPOSTYPE} in
		REDHAT)
            # Updating CA certs
            yum -y update ca-certificates
			/usr/bin/ca-legacy install
			/usr/bin/update-ca-trust
			if ! which which >/dev/null 2>/dev/null ; then
				yum -y install which
			fi
			if ! which free >/dev/null 2>/dev/null ; then
				yum -y install procps
			fi
			if ! which ip >/dev/null 2>/dev/null ; then
				yum -y install iproute
			fi
			if [ -z "$(which hexdump 2>/dev/null)" ]; then
				yum -y install util-linux-ng
			fi
			OSVER=$(rpm -q --qf "%{version}" -f /etc/redhat-release)
			if echo "${OSVER}" | grep -q Server ; then
				OSVER=$(echo "${OSVER}" | sed 's/Server//')
			fi
			OSVER=${OSVER%%\.*}
			if ! echo "${centos_OSVERSIONS}" | grep -q -w "${OSVER}" ; then
				unsupported_osver="true"
			fi
			if echo "${centos_EOL_OSVERSIONS}" | grep -q -w "${OSVER}" ; then
				eol_osver="true"
			fi
		;;
		DEBIAN)
			/usr/bin/apt-get -qy update
            # Updating CA certs
            apt-get -qy --allow-unauthenticated -u install ca-certificates

			if ! which which >/dev/null 2>/dev/null ; then
				/usr/bin/apt-get -qy --allow-unauthenticated install which
			fi
			local toinstall
			if [ -z "$(which lsb_release 2>/dev/null)" ]; then
				/usr/bin/apt-get -qy --allow-unauthenticated install lsb-release
			fi
			if [ "$(lsb_release -s -c)" = "jammy" ]; then
				if [ -z "$(which python3 2>/dev/null)" ]; then
					toinstall="${toinstall} python3"
				fi
			else
				if [ -z "$(which python 2>/dev/null)" ]; then
					toinstall="${toinstall} python"
				fi
			fi
			if [ -z "$(which hexdump 2>/dev/null)" ]; then
				toinstall="${toinstall} bsdmainutils"
			fi
			if [ -z "$(which logger 2>/dev/null)" ]; then
				toinstall="${toinstall} bsdutils"
			fi
			if [ -z "$(which free 2>/dev/null)" ]; then
				toinstall="${toinstall} procps"
			fi
			if [ -z "$(which gpg 2>/dev/null)" ]; then
				toinstall="${toinstall} gnupg"
			fi
			if [ -z "$(which wget curl 2>/dev/null)" ]; then
				toinstall="${toinstall} wget"
			fi
			if [ -n "${toinstall}" ]; then
				/usr/bin/apt-get -qy --allow-unauthenticated install ${toinstall}
			fi
			if [ -x /usr/bin/lsb_release ]; then
				OSVER=$(lsb_release -s -c)
			fi
			if ! echo "${debian_OSVERSIONS} ${ubuntu_OSVERSIONS}" | grep -q -w "${OSVER}" ; then
				unsupported_osver="true"
			fi
			if echo "${debian_EOL_OSVERSIONS} ${ubuntu_EOL_OSVERSIONS}" | grep -q -w "${OSVER}" ; then
				eol_osver="true"
			fi
			if [ "$(lsb_release -s -i)" = "Ubuntu" ]; then
				export reponame=ubuntu
			else
				export reponame=debian
			fi
		;;
	esac
	if [ "#${OSVER}" = "#unknown" ]; then
		Error "Unknown os version. Try to use \"--osversion\" option"
		exit 1
	fi
	if [ "#${unsupported_osver}" = "#true" ]; then
		Error "Unsupported os version (${OSVER})"
		exit 1
	fi
	if [ "#${eol_osver}" = "#true" ] && [ "$ALLOW_EOL" != "true" ];then
		Error "Your operating system is at End of Support (EOL). Correct operation of ispmanager on this OS is not guaranteed."
		Error "You can see the status of ispmanager support and release of updates for your OS in the documentation https://www.ispmanager.com/docs/ispmanager/support-stages#supported-os."

		echo "Continue installation? (y/N)"
		echo
		# shellcheck disable=SC2039,SC2162
		read -p "Your choice is: " answer
		echo

		if [ "$answer" = "y" ]; then
			ALLOW_EOL=true
		else
			exit 0
		fi
	fi
}

PingTest() {
	# shellcheck disable=SC2039
	local ITER=5
	# shellcheck disable=SC2086
	ping -q -c ${ITER} -n ${1} 2>&1 | tail -1 | awk -F '/' '{print $5}' | awk -F. '{print $1}'
}

CheckMirror() {
	# $1 - mirror
	${fetch} - http://${1}/ | grep -q install.sh
}

Ver6to5() {
	local ver6 ver5 minor
	ver6="${1}"
	minor=$(echo "${ver6}" | cut -d . -f2)
	ver5=5.$((minor + 295))
	echo "${ver5}"
}

GetFastestMirror() {
	# Detect fastest mirror. If redhat not needed. If mirror detected not needed

	case ${ISPOSTYPE} in
		REDHAT)
			export BASEMIRROR=mirrors.download.ispmanager.com
		;;
		DEBIAN)
			if CheckMirror download.ispmanager.com ; then
				export BASEMIRROR=download.ispmanager.com
			else
				export BASEMIRROR=mirrors.download.ispmanager.com
			fi
		;;
	esac

	# Mirror already set
	if [ -n "${ARGMIRROR}" ]; then
		export BASEMIRROR=${ARGMIRROR}
		return 0
	fi

	# Thist is developer installation
	if ! echo "${release}" | grep -qE "^(stable|beta|beta5|beta6|stable5|stable6|intbeta|intstable|5\.[0-9]+|6\.[0-9]+)$"; then
		export MIRROR=intrepo.download.ispmanager.com
        export SCHEMA=http
		return 0
	fi

	# This is 6 product. Need to get 5th release for coremanager
	if echo "${release}" | grep -qE "^6\.[0-9]"; then
		FORCE_ISP6=yes
		release=$(Ver6to5 "${release}")
	fi

	case ${ISPOSTYPE} in
		REDHAT)
			export MIRROR=mirrors.download.ispmanager.com
		;;
		DEBIAN)
			if CheckMirror download.ispmanager.com ; then
				export MIRROR=download.ispmanager.com
			else
				export MIRROR=${FAILSAFEMIRROR}
			fi
		;;
	esac
	Info "Using ${MIRROR}"
}


OsName() {
	case ${ISPOSTYPE} in
		REDHAT)
			rpm -qf /etc/redhat-release
		;;
		DEBIAN)
			echo "$(lsb_release -s -i -c -r | xargs echo |sed 's; ;-;g')-$(dpkg --print-architecture)"
		;;
	esac
}

CleanMachineID() {
	if [ -f /etc/machine-id ] && [ -n "$(which systemd-machine-id-setup 2>/dev/null)" ] && [ -z "${core_installed}" ]; then
		if [ -f /var/lib/dbus/machine-id ]; then
			rm -f /var/lib/dbus/machine-id
		fi
		rm -f /etc/machine-id
		systemd-machine-id-setup
	fi
}

GetMachineID() {
	CleanMachineID >/dev/null 2>&1 || :
	if [ ! -f /etc/machine-id ]; then
		if [ -n "$(which systemd-machine-id-setup 2>/dev/null)" ]; then
			systemd-machine-id-setup >/dev/null 2>/dev/null
		else
			hexdump -n 16 -e '/2 "%x"' /dev/urandom > /etc/machine-id
		fi
	fi
	# shellcheck disable=SC2002
	cat /etc/machine-id| awk '{print $1}'
}

StartInstall() {
	HOSTID=$(GetMachineID)
	URL="${NOTIFY_SERVER}/startinstall"
	timeout -s INT 60 wget --quiet --tries=3 --read-timeout=20 --connect-timeout=10 --no-check-certificate  --post-data="os=$(OsName)&mirror=${MIRROR}&repo=${release}&mgr=${pkgname}&hostid=${HOSTID}" -O - "${URL}" 2>/dev/null || :
}

LicInstall() {
	HOSTID=$(GetMachineID)
	URL="${NOTIFY_SERVER}/licinstall"
	# shellcheck disable=SC2086
	licid=$(/usr/local/mgr5/sbin/licctl info /usr/local/mgr5/etc/${mgr}.lic 2>/dev/null| awk '$1 == "ID:" {print $2}' || :)
	# shellcheck disable=SC2086
	licexpire=$(/usr/local/mgr5/sbin/licctl info /usr/local/mgr5/etc/${mgr}.lic 2>/dev/null| awk '$1 == "Expire:" {print $2}' || :)
	LICPART="&licid=${licid}&licexpire=${licexpire}"
	corever=$(/usr/local/mgr5/bin/core core -v 2>/dev/null)
	POST_DATA="hostid=${HOSTID}&mgr=${pkgname}&corever=${corever}"
	if [ "#${licid}" != "#0" ]; then
		POST_DATA="${POST_DATA}${LICPART}"
	fi
	timeout -s INT 60 wget --quiet --tries=3 --read-timeout=20 --connect-timeout=10 --no-check-certificate  --post-data="${POST_DATA}" -O - "${URL}" 2>/dev/null || :
}

CancelInstall() {
	HOSTID=$(GetMachineID)
	if [ -n "${1}" ]; then
		REASON="&reason=${1}"
	fi
	URL="${NOTIFY_SERVER}/cancelinstall"
	timeout -s INT 60 wget --tries=3 --read-timeout=20 --connect-timeout=10 --no-check-certificate --post-data="hostid=${HOSTID}&mgr=${pkgname}${REASON}" -O - "${URL}" 2>/dev/null || :
	rm -f "${COOKIES_FILE}"
	LogClean
}

FinishInstall() {
	BILL_SETTINGS=/usr/local/mgr5/etc/billing.settings
	if [ ! -e $BILL_SETTINGS ]; then
		SETTINGS="Api https://api.ispmanager.com/billmgr
License 86.license5.ispsystem.com
Site https://my.ispmanager.com/billmgr"
		if [ "$EU" = true ]; then
			SETTINGS="Api https://api-eu.ispmanager.com/billmgr
License 86.license5.ispsystem.com
Site https://eu.ispmanager.com/billmgr"
		fi
		cat <<EOF > $BILL_SETTINGS
$SETTINGS
EOF
	fi
	HOSTID=$(GetMachineID)
	URL="${NOTIFY_SERVER}/finishinstall"
	# shellcheck disable=SC2086
	mgrver=$(/usr/local/mgr5/bin/core ${mgr} -v 2>/dev/null)
	# shellcheck disable=SC2086
	timeout -s INT 60 wget --tries=3 --read-timeout=20 --connect-timeout=10 --no-check-certificate  --post-data="hostid=${HOSTID}&mgr=${pkgname}&mgrver=${mgrver}&url=$(GetMgrUrl ${mgr})" -O - "${URL}" 2>/dev/null || :
	rm -f "${COOKIES_FILE}"
	LogClean
}

# shellcheck disable=SC2120
ErrorInstall() {
	HOSTID=$(GetMachineID)
	URL="${NOTIFY_SERVER}/errorinstall"
	if [ -n "${1}" ]; then
		err_text="${1}"
	else
		#Pkglist
		CheckPkg exim
		if [ "${OSVER}" = "jessie" ]; then
			grep -i mysql /var/log/syslog | tail -n100 >> ${LOG_FILE} 2>&1 || :
			uname -a >> ${LOG_FILE} 2>&1
		fi
		if [ "${OSVER}" = "wheezy" ] || [ "${OSVER}" = "xenial" ]; then
			grep -i mysql /var/log/syslog | tail -n100 >> ${LOG_FILE} 2>&1 || :
			uname -a >> ${LOG_FILE} 2>&1
		fi
		if [ -f /usr/local/mgr5/var/licctl.log ]; then
			tail -n50 /usr/local/mgr5/var/licctl.log >> ${LOG_FILE} 2>&1
		fi
		# shellcheck disable=SC2002
		err_text="$(cat ${LOG_FILE} | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g" | hexdump -v -e '/1 "%02x"' | sed 's/\(..\)/%\1/g')"
	fi
	timeout -s INT 60 wget --tries=3 --read-timeout=20 --connect-timeout=10 --no-check-certificate  --post-data="hostid=${HOSTID}&mgr=${pkgname}&text=${err_text}" -O - "${URL}" 2>/dev/null || :
	LogClean
	exit 1
}

DetectInstalled() {
	# Check if coremanager is installed
	if PkgInstalled coremanager || test -f /usr/local/mgr5/etc/core.conf ; then
		export core_installed=yes
	fi
}

GetAvailVersion() {
	local rel
	rel=$1
	test -n "${rel}" || return 1

	case ${ISPOSTYPE} in
		REDHAT)
			LC_ALL=C yum list -q --showduplicates coremanager 2>/dev/null | awk -v rel=${rel} 'BEGIN{flag=0} {if($1 ~ /Available/){flag=1; getline};{if(flag==1 && $3 == "ispmanager-"rel){print $2}}}' | sort -V | tail -1
			;;
		DEBIAN)
			apt-get -y update >/dev/null 2>&1
			apt-cache madison coremanager 2>/dev/null| awk -v rel=${rel} -v dist=$(lsb_release -c -s) '$6 == rel"-"dist"/main" {print $3}' | sort -V | tail -1
			;;
		esac
}

GetInstalledVersion() {
	case ${ISPOSTYPE} in
		REDHAT)
			rpm -q --qf "%{version}-%{release}" coremanager 2>/dev/null
			;;
		DEBIAN)
			dpkg -s coremanager 2>/dev/null | grep Version | awk '{print $2}'
			;;
		esac
}

VersionToRelease() {
	# $1 - version
	echo "${1}" | awk -F- '{print $1}' | cut -d. -f1,2
}

GetCurrentRepo() {
	case ${ISPOSTYPE} in
		REDHAT)
			if [ -f /etc/yum.repos.d/ispsystem.repo ]; then
				# shellcheck disable=SC2002
				release=$(grep -E '^name=ispmanager-' /etc/yum.repos.d/ispsystem.repo | tail -1|sed -r 's/name=ispmanager-//g')
				if [ -z "${release}" ]; then
					rm -f /etc/yum.repos.d/ispsystem.repo
				else
					added_repo=yes
					MIRROR="$(awk -F= '$1 == "baseurl" {print $2}' /etc/yum.repos.d/ispsystem.repo  | awk -F/ '{print $3}')"
					export MIRROR
				fi
			fi
		;;
		DEBIAN)
			if [ -f /etc/apt/sources.list.d/ispsystem.list ]; then
				# shellcheck disable=SC2002
				release=$(cat /etc/apt/sources.list.d/ispsystem.list | awk '$1 == "deb" && $2 ~ /http|ftp/ {print $3}' | awk -F- '{print $1}')
				if [ -z "${release}" ]; then
					rm -f /etc/apt/sources.list.d/ispsystem.list
				else
					added_repo=yes
					MIRROR="$(awk -F/ '{print $3}' /etc/apt/sources.list.d/ispsystem.list)"
					export MIRROR
				fi
			fi
		;;
		*)
		;;
	esac
}

GetGpgKeyName() {
        if [ "${ISPOSTYPE}" = "REDHAT" ]; then
                if [ ${OSVER} -ge 9 ]; then
                        echo -n "RPM-GPG-KEY-Ispmanager"
                else
                        echo -n "RPM-GPG-KEY-ISPsystem"
                fi
        fi
}

CheckUnsupportedRepo() {
	# Check unsupported centos repo

	# skip if silent install
	test -n "${silent}" && return 0

	# skip if debian
	[ "${ISPOSTYPE}" = "DEBIAN" ] && return 0
	Info "List of enabled repositories:"
	yum --noplugins repolist enabled 2>/dev/null | grep -v repolist
	echo ""
	# shellcheck disable=SC2039
	local arepos=$(yum --noplugins repolist enabled 2>/dev/null | grep -v repolist | sed '1d' | awk '{print $1}' | awk -F/ '{print $1}' | sed 's/^!//')
	if [ -n "${arepos}" ] && [ ${OSVER} -lt 8 ] && ! echo "${arepos}" | grep -q '^base$' ;then
		Error "Can not be installed without CentOS base repository"
		CancelInstall baserepo
		exit 1
	fi
	# shellcheck disable=SC2039
	local repos=$(yum --noplugins repolist enabled 2>/dev/null | grep -v repolist | sed '1d' | awk '{print $1}' | awk -F/ '{print $1}' | grep -vE '^\!*(ispmanager-.*|ispsystem-.*|epel.*|vz-.*|base|extras|updates|cloudlinux-.*)$')
	if echo "${repos}" | grep -v remi-safe | grep -qE "(\s|^)remi(-\w+)*(\s|\n|$)" ; then
		Error "Can not be installed with remi repo"
		CancelInstall remirepo
		exit 1
	elif echo "${repos}" | grep -iqE "(\s|^)plesk(-\w+)*(\s|\n|$)" ; then
		Error "Can not be installed with plesk repo"
		CancelInstall pleskrepo
		exit 1
	elif [ -n "${repos}" ] && [ ${OSVER} -lt 8 ]; then
		Warningn "You have next unsupported repositories:  "
		echo "${repos}"
		Warning  "This may cause installtion problems."
		Warning  "Please disable this repositories for correct installation."
		Warningn "Do you really want to continue? (y/N) "
		# shellcheck disable=SC2162
		read  answer
		if [ "#${answer}" != "#y" ]; then
			CancelInstall unsupportedrepos
			exit 1
		fi
	fi

}

CheckDF() {
	# Check free disk space for centos
	# $1 - partition
	# $2 - min size

	# skip if silent install
	test -n "${silent}" && return 0
	if [ "${ISPOSTYPE}" = "REDHAT" ]; then
		# shellcheck disable=SC2039
		local cursize=$(df -P -m ${1} 2>/dev/null | tail -1 | awk '{print $4}')
		test -z "${cursize}" && return 0
		if [ "${cursize}" -lt "${2}" ]; then
			Error "You have insufficiently disk space to install in directory ${1}: ${cursize} MB"
			Error "You need to have at least ${2} MB"
			CancelInstall diskspace
			exit 1
		fi
	fi
}

CheckMEM() {
	# Chech memory size
	# skip if silent install
	test -n "${silent}" && return 0
	# shellcheck disable=SC2039
	local lowmemlimit
	if [ "${ISPOSTYPE}" = "REDHAT" ]; then
		lowmemlimit=384
	else
		lowmemlimit=256
	fi

	# shellcheck disable=SC2039
	local lowmem=$(free -m | awk -v lml=${lowmemlimit} 'NR==2 && $2 <= lml {print $2}')

	if [ -n "${lowmem}" ]; then
		Error "You have to low memory: ${lowmem}"
		Error "You need to have at least 300 Mb"
		CancelInstall lowmem
		exit 1
	fi
}

CheckPkg() {
	echo "" >> ${LOG_FILE}
	echo "Checking package ${1}" >> ${LOG_FILE}
	case ${ISPOSTYPE} in
		REDHAT)
			rpm -qa | grep "${1}" | sort >> ${LOG_FILE} 2>&1
		;;
		DEBIAN)
			dpkg -l | grep "${1}" >> ${LOG_FILE} 2>&1
		;;
	esac
}

Pkglist() {
	echo "" >> ${LOG_FILE}
	echo "List of installed packages" >> ${LOG_FILE}
	case ${ISPOSTYPE} in
		REDHAT)
			rpm -qa | sort >> ${LOG_FILE} 2>&1
		;;
		DEBIAN)
			dpkg -l >> ${LOG_FILE} 2>&1
		;;
	esac

}

CheckConflicts() {
	# Check installed packages with same name
	# $1 - package

	# shellcheck disable=SC2039
	local name=${1}
	# shellcheck disable=SC2039
	local short_name=${name%%-*}
	test -z "${short_name}" && return 0
	if [ "${ISPOSTYPE}" = "REDHAT" ]; then
	# shellcheck disable=SC2039
		local vpkglist=$(rpm -qa "${short_name}*")
	elif [ "${ISPOSTYPE}" = "DEBIAN" ]; then
		vpkglist=$(dpkg -l "${short_name}*" 2>/dev/null | awk '$1 !~ /un/ {print $2 "-" $3}' | grep "^${short_name}"| xargs)
	fi
	# shellcheck disable=SC2039
	local pkglist=""
	for pkg in ${vpkglist}; do
		if echo "${pkg}" | grep -q "${short_name}-pkg"; then
			continue
		else
			pkglist="${pkglist} ${pkg}"
		fi
	done
	pkglist="$(echo "${pkglist}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'| xargs)"
	if [ -n "${pkglist}" ]; then
		Error "You have already installed next ${short_name} packages: "
		echo "${pkglist}"
		Error "If you want to install ${name} you should remove them first"
		CancelInstall conflicts
		exit 1
	fi
}

trap ErrorInstall TERM
set -e

# Parsing arguments
while true
do
	case "${1}" in
		-h | --help)
			Usage
			exit 0
			;;
		--mirror)
			ARGMIRROR="${2:-.}"
			shift 2
			if [ -z "${MIRROR}" ]; then
				Error "Empty mirror"
				exit 1
			fi
			;;
		--release)
			release=$(echo "${2:-.}" | awk -F. '{if(NF>1){print $1 "." $2}else{print $0}}')
			shift 2
			;;
		--osfamily)
			ISPOSTYPE="${2:-.}"
			if ! echo "${ISPOSTYPE}" | grep -qE "^(REDHAT|DEBIAN)$"; then
				Error "Incorrect OS"
				exit 1
			fi
			shift 2
			;;
		--osversion)
			OSVER="${2:-.}"
			shift 2
			;;
		--noinstall)
			noinstall="true"
			shift 1
			;;
		--silent)
			silent="true"
			ignore_hostname="true"
			ALLOW_EOL="true"
			if [ -z "${DBTYPE}" ]; then
				DBTYPE="sqlite"
			fi
			shift 1
			;;
		--ignore-hostname)
			ignore_hostname="true"
			shift 1
			;;
		--disable-fail2ban)
			disable_fail2ban="true"
			shift 1
			;;
		--no-letsencrypt)
			no_letsencrypt="true"
			shift 1
			;;
		--le-domain)
			LE_DOMAIN="${2:-.}"
			shift 2
			;;
		--ispmgr6)
			FORCE_ISP6="true"
			shift 1
			;;
		--ispmgr5)
			FORCE_ISP5="true"
			shift 1
			;;
		--openlitespeed)
			webserver=openlitespeed
			shift 1
			;;
		--dbtype)
			DBTYPE="${2:-.}"
			if ! echo "${DBTYPE}" | grep -qE "^(mysql|sqlite)$"; then
				Error "Incorrect database type"
				exit 1
			fi
			shift 2
			;;
		--mysql-server)
			mysqlserver="${2:-.}-server"
			if ! echo "${mysqlserver}" | grep -qE "^(mysql-server|mariadb-server)$"; then
				Error "Incorrect mysql server"
				exit 1
			fi
			shift 2
			;;
		--allow-eol-os)
			ALLOW_EOL="true"
			shift 1
			;;
		*)
			if [ -z "${1}" ]; then
				break
			fi
			inpkgname=${1}
			shift 1
			;;
	esac
done

if [ -f /.dockerinit ]; then
	export ignore_hostname="true"
fi

if [ -n "${release}" ]; then
	if [ "#${release}" = "#beta" ]; then
		release=beta6
	fi
	if [ "#${release}" = "#stable" ]; then
		release=stable6
	fi
fi

if [ "#$(echo "${release}" | head -c 1)" = "#4" ]; then
	Error "Unsupported version"
	exit 1
fi

if [ "#${MIGRATION}" = "#mgr5" ]; then
	Info "This is migration from 4th version"
fi

OSDetect
OSVersion

if [ "$(uname -m)" = "i686" ]; then
	if [ "${ISPOSTYPE}-${OSVER}" = "REDHAT-7" ]; then
		Error "i686 arch for CentOS-7 not supported"
		exit 1
	elif [ "${ISPOSTYPE}-${OSVER}" = "DEBIAN-jessie" ]; then
		Error "i686 arch for Debian-8 not supported"
		exit 1
	elif [ "${ISPOSTYPE}-${OSVER}" = "DEBIAN-xenial" ]; then
		Error "i686 arch for Ubuntu-16.04 not supported"
		exit 1
	fi
fi

if [ "${release}" = "4" ]; then
	Error "No such release"
	exit 1
fi

if [ -n "${mysqlserver}" ]; then
	if ([ "${ISPOSTYPE}" = "DEBIAN" ] && [ "$(lsb_release -s -i)" = "Debian" ]) || [ "${ISPOSTYPE}-${OSVER}" = "REDHAT-7" ]; then
		Error "The '--mysql-server' option not supported on this OS"
		exit 1
	fi
fi

Infon "Installing on ${ISPOSTYPE} ${OSVER}"
echo ""

Info "System memory:"
free -m
echo ""

Info "Disk space:"
df -h -P -l -x tmpfs -x devtmpfs
echo ""


DetectManager
CheckRoot
CheckSELinux
CheckAppArmor
CheckUnsupportedRepo
CheckDF /var/cache/yum/ 300
CheckDF /usr/local 1024
CheckDF / 300
CheckMEM

if [ "#${ignore_hostname}" != "#true" ]; then
	CheckHostname
else
	export IGNORE_HOSTNAME=yes
fi

DetectFetch
DetectInstalled

if [ -z "${release}" ]; then
	GetCurrentRepo
fi
if [ -n "${release}" ] && [ -n "${added_repo}" ]; then
	Info "Detected added repository: ${release}"
	Info "updating cache"
	case ${ISPOSTYPE} in
		REDHAT)
			yum clean all || :
		;;
		DEBIAN)
			apt-get -y update
		;;
	esac
fi

while [ -z "${release}" ]
do
	echo "Which version would you like to install ?"
	echo "b) beta version - has the latest functionality"
	echo "s) stable version - time-proved version"
	echo
	# shellcheck disable=SC2039,SC2162
	read -p "Choose repository type to work with: " n
	echo
	case ${n} in
		r|s|2|stable)
			release="stable6"
		;;
		b|1|beta)
			release="beta6"
		;;
		m|master)
			release="master"
		;;
		si)
			release="stable-int"
		;;
		bi)
			release="beta-int"
		;;
		ib)
			release="intbeta"
		;;
		is)
			release="intstable"
		;;
		i)
			# shellcheck disable=SC2039,SC2162
			read -p "Enter full repository name: " rn
			release="${rn}"
		;;
		*)
			:
		;;
	esac
done


InstallGpgKey() {
	# Install gpg key
	case ${ISPOSTYPE} in
		REDHAT)
			LOCAL_GPG_FILE=/etc/pki/rpm-gpg/$(GetGpgKeyName)
			if [ ${OSVER} -ge 9 ]; then
				REMOTE_GPG_FILE=ispmanager.gpg.key
			else
				REMOTE_GPG_FILE=ispsystem.gpg.key
			fi
			if [ ! -s ${LOCAL_GPG_FILE} ]; then
				Info "Adding ispmanager gpg key..."
				${fetch} ${LOCAL_GPG_FILE} "${SCHEMA}://${MIRROR}/repo/${REMOTE_GPG_FILE}" || return 1
				if [ -s ${LOCAL_GPG_FILE} ]; then
					rpm --import ${LOCAL_GPG_FILE} || return 1
				else
					return 1
				fi
			fi
			;;
		DEBIAN)
			if [ ! -s /etc/apt/trusted.gpg.d/ispsystem.gpg ]; then
				apt-key del 810F8996 >/dev/null 2>&1 || :
				${fetch} /etc/apt/trusted.gpg.d/ispsystem.gpg  ${SCHEMA}://${MIRROR}/repo/ispsystem.gpg || :
			fi
			;;
	esac
}

CheckRepo() {
	# Check if repository added
	# $1 - repo name
	case ${ISPOSTYPE} in
		REDHAT)
			# shellcheck disable=SC2086
			yum repolist enabled 2>/dev/null | awk '{print $1}' | grep -q ${1}
			;;
		DEBIAN)
			# shellcheck disable=SC2086,SC2086
			apt-cache policy | awk -vrname=${1}/main '$NF == "Packages" && $(NF-2) == rname' | grep -q ${1}
			;;
	esac
}

InstallEpelRepo() {
	# Install epel repo
	test "${ISPOSTYPE}" = "REDHAT" || return 0
	test -z "${BASEMIRROR}" && GetFastestMirror
	Infon "Checking epel... "
	if [ ! -f /etc/yum.repos.d/epel.repo ] || ! CheckRepo epel ; then
		if rpm -q epel-release >/dev/null ; then
			Warn "Epel repo file broken. Removing epel-release package"
			rpm -e --nodeps epel-release
		else
			Info "Epel repo not exists"
		fi
		rm -f /etc/yum.repos.d/epel.repo
	fi
	if grep -iq cloud /etc/redhat-release ; then
		Info "Importing EPEL key.."
		# shellcheck disable=SC2086
		rpm --import http://mirror.yandex.ru/epel/RPM-GPG-KEY-EPEL-${OSVER} || return 1
		if ! rpm -q epel-release >/dev/null ; then
			Info "Adding repository EPEL.."
			if [ "${OSVER}" = "6" ]; then
				rpm -iU http://${BASEMIRROR}/repo/centos/epel/6/x86_64/epel-release-6-8.noarch.rpm || return 1
			elif [ "${OSVER}" = "7" ]; then
				rpm -iU http://${BASEMIRROR}/repo/centos/epel/7/x86_64/e/epel-release-7-10.noarch.rpm || return 1
			fi
		fi
		yum -y update mysql-libs || return 1
	else
		if ! rpm -q epel-release >/dev/null ; then
			# epel-release already in extras repository which enabled by default
			Info "Installing epel-release package.."
			yum -y install epel-release || return 1
		else
			Info "Epel package already installed"
		fi
	fi
	if [ ${OSVER} -lt 8 ] && ! grep -qE "mirrorlist=http://${BASEMIRROR}/" /etc/yum.repos.d/epel.repo ; then
		sed -i -r "/ \[epel\] /,/\[epel/s|^(mirrorlist=).*|\1http://${BASEMIRROR}/repo/centos/epel/mirrorlist.txt|" /etc/yum.repos.d/epel.repo
		if ! grep -q mirrorlist /etc/yum.repos.d/epel.repo; then
			sed -i -r "/\[epel\]/,/\[epel/s|^(metalink=.*)|#\1\nmirrorlist=http://${BASEMIRROR}/repo/centos/epel/mirrorlist.txt|" /etc/yum.repos.d/epel.repo
		fi
		yum clean all || :
	fi

}

InstallDebRepo() {
	# Check debian/ubuntu base repo
	return 0 # Function disabled
	test "${ISPOSTYPE}" = "DEBIAN" || return 0
	if ! CheckRepo ${OSVER} ; then
		Warn "Standard ${reponame}-${OSVER} repository does not enabled. Add it to sources.list"
		if [ "${reponame}" = "debian" ]; then
			# shellcheck disable=SC2129
			echo "deb http://ftp.debian.org/debian ${OSVER} main contrib non-free" >> /etc/apt/sources.list
			echo "deb http://ftp.debian.org/debian ${OSVER}-updates main contrib non-free" >> /etc/apt/sources.list
			echo "deb http://security.debian.org ${OSVER}/updates main contrib non-free" >> /etc/apt/sources.list
		else
			# shellcheck disable=SC2129
			echo "deb http://archive.ubuntu.com/ubuntu ${OSVER} main restricted universe" >> /etc/apt/sources.list
			echo "deb http://archive.ubuntu.com/ubuntu ${OSVER}-updates main restricted universe" >> /etc/apt/sources.list
			echo "deb http://security.ubuntu.com/ubuntu ${OSVER}-security main restricted universe multiverse" >> /etc/apt/sources.list
		fi
		apt-get -y update || return 1
	fi
}

InstallBaseRepo() {
	# Check and install ispmanager-base repo
	test -z "${BASEMIRROR}" && GetFastestMirror
	InstallGpgKey || return 1
	case ${ISPOSTYPE} in
		REDHAT)
			Infon "Checking ispmanager-base repo... "
			if [ ! -f /etc/yum.repos.d/ispsystem-base.repo ] || ! CheckRepo ispsystem-base ; then
				Warn "Not found"
				Info "Adding repository ispmanager-base.."
				rm -f /etc/yum.repos.d/ispsystem-base.repo
				${fetch} /etc/yum.repos.d/ispsystem-base.repo "${SCHEMA}://${BASEMIRROR}/repo/centos/ispmanager-base.repo" >/dev/null 2>&1 || return 1
			else
				Info "Found"
			fi
			if echo "${MIRROR}" | grep -q intrepo && [ ! -f /etc/yum.repos.d/intrepo-base.repo ] ; then
				${fetch} /etc/yum.repos.d/intrepo-base.repo "http://${MIRROR}/repo/centos/intrepo-base.repo" >/dev/null 2>&1 || return 1
			fi
			:
			;;
		DEBIAN)
			Infon "Checking ispmanager-base repo... "
			# shellcheck disable=SC2086
			if ! CheckRepo base-${OSVER} ; then
				Warn "Not found"
				Info "Adding repository ispmanager-base.."
				rm -f /etc/apt/sources.list.d/ispsystem-base.list
				if [ ! -d /etc/apt/sources.list.d ]; then
					mkdir -p /etc/apt/sources.list.d
				fi
				echo "deb http://${BASEMIRROR}/repo/${reponame} base-${OSVER} main" > /etc/apt/sources.list.d/ispsystem-base.list
			else
				Info "Found"
			fi
			if echo "${MIRROR}" | grep -q intrepo && [ ! -f /etc/apt/sources.list.d/intrepo-base.list ] ; then
				echo "deb http://${MIRROR}/repo/${reponame} base-${OSVER} main" > /etc/apt/sources.list.d/intrepo-base.list
			fi
			;;
	esac
}

EnablePowerToolsRepo() {
	test "${ISPOSTYPE}" = "REDHAT" || return 0
	test ${OSVER} -ge 8 || return 0
    for f in CentOS-PowerTools.repo CentOS-Linux-PowerTools.repo CentOS-Stream-PowerTools.repo almalinux-powertools.repo Rocky-PowerTools.repo; do
        if [ -f /etc/yum.repos.d/${f} ]; then
            sed -i -r 's/enabled=0/enabled=1/' /etc/yum.repos.d/${f}
        fi
    done

	#for multiple repositories in one file, format: <file>.repo_<section>
	for f in vzlinux.repo_powertools almalinux-crb.repo_crb; do
		repofilename=$(echo "${f}" | cut -d_ -f1)
		section=$(echo "${f}" | cut -d_ -f2)
		if [ -f /etc/yum.repos.d/${repofilename} ]; then
			sed -i -r "/\[${section}\]/,//s/enabled=0/enabled=1/" /etc/yum.repos.d/${repofilename}
        	fi
	done
}

CentosRepo() {
    local release rname
    release="${1}"
    rname="${2}"

    rm -f /etc/yum.repos.d/${rname}.repo
    if echo "${release}" | grep -qE "^(6-)?(stable|beta|beta5|beta6|stable5|stable6|intbeta|intstable|5\.[0-9]+)$"; then
        ${fetch} /etc/yum.repos.d/${rname}.repo.tmp "${SCHEMA}://${MIRROR}/repo/centos/ispmanager.repo" >/dev/null 2>&1 || return 1
        sed -i -r "s/__VERSION__/${release}/g" /etc/yum.repos.d/${rname}.repo.tmp && mv /etc/yum.repos.d/${rname}.repo.tmp /etc/yum.repos.d/${rname}.repo || exit
    else
        ${fetch} /tmp/${rname}.repo "${SCHEMA}://${MIRROR}/repo/centos/ispmanager-template.repo" >/dev/null 2>&1 || return 1
        sed -i -r "s|TYPE|${release}|g" /tmp/${rname}.repo
        mv /tmp/${rname}.repo /etc/yum.repos.d/${rname}.repo
    fi
}


DebianRepo() {
    local release rname
    release="${1}"
    rname="${2}"

	rm -f /etc/apt/sources.list.d/${rname}.list
    if echo "${release}" | grep -qE "^(6-)?(stable|beta|intbeta|intstable|5\.[0-9]+)$"; then
		if echo "${release}" | grep -qE "5\.[0-9]+"; then
			echo "deb http://${MIRROR}/repo/${reponame} ${release}-${OSVER} main" > /etc/apt/sources.list.d/${rname}.list
		else
			echo "deb ${SCHEMA}://${MIRROR}/repo/${reponame} ${release}-${OSVER} main" > /etc/apt/sources.list.d/${rname}.list
		fi
	else
		echo "deb http://${MIRROR}/repo/${reponame} ${release}-${OSVER} main" > /etc/apt/sources.list.d/${rname}.list
	fi

}

InstallRepo() {
	# Install ispmanager main repo
	GetFastestMirror
	# shellcheck disable=SC2086
	InstallEpelRepo ${1} || return 1
	EnablePowerToolsRepo
	# shellcheck disable=SC2086
	InstallBaseRepo ${1} || return 1
	InstallGpgKey || return 1

	case ${ISPOSTYPE} in
		REDHAT)
			if [ -z "${FORCE_ISP5}" ]; then
				Info "Adding repository ispmanager-6.."
				CentosRepo "6-${release}" "exosoft"
			else
				Info "Adding repository ispmanager-5.."
				CentosRepo "${release}" "ispsystem"
			fi

			# Check if release support gpg
			# shellcheck disable=SC2039
			local gpgenable
			case ${release} in
				beta|beta5|beta6)
					gpgenable=yes
				;;
				5.*)
					if [ "${release#5.}" -gt 59 ]; then
						gpgenable=yes
					fi
					if [ -z "${FORCE_ISP5}" ] && [ "${release#5.}" -lt 361 ]; then
						Info "Adding repository COREmanager.."
						CentosRepo "${release}" "ispsystem"
					fi
				;;
				*)
				;;
			esac
			if echo "${MIRROR}" | grep -q intrepo ; then
				gpgenable=yes
			fi

			# Enable gpgkey verification
			if [ -n "${gpgenable}" ]; then
				for f in ispsystem ispsystem-base ; do
					fname=/etc/yum.repos.d/${f}.repo
					if [ -f ${fname} ]; then
						if grep -q 'gpgkey=$' ${fname} ; then
							sed -i -r "s/(gpgkey=)$/\1file:\/\/\/etc\/pki\/rpm-gpg\/$(GetGpgKeyName)/g" ${fname}
							sed -i -r "s/gpgcheck=0/gpgcheck=1/g" ${fname}
						fi
					fi
				done
			fi
			yum -y makecache || yum -y makecache || return 1
		;;
		DEBIAN)
			if [ -z "${FORCE_ISP5}" ]; then
				Info "Adding repository ispmanager-6.."
				DebianRepo "6-${release}" "exosoft"
			else
				Info "Adding repository ispmanager-5.."
				DebianRepo "${release}" "ispsystem"
			fi

			case ${release} in
				5.*)
					if [ -z "${FORCE_ISP5}" ] && [ "${release#5.}" -lt 361 ]; then
						Info "Adding repository COREmanager.."
						DebianRepo "${release}" "ispsystem"
					fi
				;;
				*)
				;;
			esac

			apt-get -y update >/dev/null
		;;
		*)
			Error "Unsupported os family: ${ISPOSTYPE}"
		;;
	esac

	mkdir -p /usr/local/mgr5/etc
	chmod 750 /usr/local/mgr5/etc
	if echo "${release}" | grep -qE '^5\.[0-9]+'; then
		echo "${release}" > /usr/local/mgr5/etc/repo.version
	elif [ "#${release}" = "#beta6" ]; then
		echo "beta" > /usr/local/mgr5/etc/repo.version
	elif [ "#${release}" = "#stable6" ]; then
		echo "stable" > /usr/local/mgr5/etc/repo.version
	else
		echo "${release}" > /usr/local/mgr5/etc/repo.version
	fi
}


PkgInstall() {
	# Install package if error change mirror if possible
	# shellcheck disable=SC2039
	local pi_fail
	pi_fail=1
	while [ "#${pi_fail}" = "#1" ]; do
		pi_fail=0
		case ${ISPOSTYPE} in
			REDHAT)
				# shellcheck disable=SC2068
				yum -y install ${@} || pi_fail=1
			;;
			DEBIAN)
				apt-get -y update
				# shellcheck disable=SC2068
				apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y -q install ${@} || pi_fail=1
			;;
			*)
			;;
		esac
		if [ "#${pi_fail}" = "#0" ]; then
			return 0
			break
		else
			return 1
			break
		fi
	done
}

PkgRemove() {
	# Remove package
	case ${ISPOSTYPE} in
		REDHAT)
			# shellcheck disable=SC2068
			yum -y remove ${@}
		;;
		DEBIAN)
			# shellcheck disable=SC2068
			apt-get -y -q remove ${@}
		;;
		*)
			return 1
		;;
	esac
}


CoreInstall() {
	PkgInstall coremanager
}


Fail2Ban() {
	if PkgAvailable coremanager-pkg-fail2ban ; then
		# Package coremanager-pkg-fail2ban exist in repo (bug #26482)
		PkgInstall coremanager-pkg-fail2ban || :
	elif [ -x /usr/local/mgr5/sbin/fail2ban.sh ]; then
		Info "Instaling fail2ban"
		# shellcheck disable=SC2039
		local failpkgs=fail2ban
		if [ "${ISPOSTYPE}-${OSVER}" = "REDHAT-7" ]; then
			failpkgs="fail2ban-server"
		fi
		PkgInstall ${failpkgs} || :
		# shellcheck disable=SC2015
		/usr/local/mgr5/sbin/fail2ban.sh && Info "fail2ban configured" || :
	fi
}


if [ "#${noinstall}" != "#true" ]; then
	# Installing coremanager
	if [ -n "${inpkgname}" ]; then
		inpkgname=$(echo "${inpkgname}" | awk '{print tolower($0)}')
		while [ -z "${mgr}" ] && [ -n "${inpkgname}" ]
		do
			case ${inpkgname} in
				coremanager)
					mgr=core
					pkgname=coremanager
				;;
				ispmanager-lite-common|ispmanager-lite|ispmanager-pro|ispmanager-business)
					mgr=ispmgr
					# Rename Pro
					if [ "${inpkgname}" = "ispmanager-pro" ]; then
						pkgname=ispmanager-business
					else
						pkgname=${inpkgname}
					fi
				;;

				ispmanager)
					mgr=ispmgr
				;;
				*)
					if echo "${inpkgname}" | grep -q '-' ; then
						inpkgname=$(echo "${inpkgname}" | cut -d- -f1)
					else
						Error "Incorrect package name"
						exit 1
					fi
				;;
			esac
		done
		if [ -z "${DBTYPE}" ]; then
			DBTYPE="sqlite"
		fi
	else
		mgr=ispmgr
	fi

	licname="${mgr%[0-9]}"

	case "${mgr}" in
    		ispmgr)
			while [ -z ${pkgname} ]
			do
				echo "What version do you want to install"
				echo "1) Ispmanager-lite,pro,host with recommended software"
				echo "2) Ispmanager-lite,pro,host minimal version"
				echo "3) Ispmanager-business"
				echo
				# shellcheck disable=SC2039,SC2162
				read -p "Choose version: " n
				echo

				echo "Chosen: ${n}"
				echo

				case "$n" in
					1)
						pkgname=ispmanager-lite
						install_recomended="yes"
						while [ -z ${webserver} ]
						do
							echo "Which web server would you like to install?"
							echo "1) Nginx + Apache"
							echo "2) OpenLiteSpeed"
							echo
							# shellcheck disable=SC2039,SC2162
							read -p "Choose web server: " w
							echo

							echo "Chosen: ${w}"
							echo

							case "$w" in
								1) webserver=nginx ;;
								2) webserver=openlitespeed ;;
								*) ;;
							esac
						done
					;;
					2) pkgname=ispmanager-lite-common ;;
					3) pkgname=ispmanager-business ;;
					*) ;;
				esac
			done
		;;
		core)
			pkgname=coremanager
		;;
	esac

	if PkgInstalled ${pkgname} ; then
		Error "You have already installed package ${pkgname}"
		Error "Do not use install.sh script for upgrading!"
		Error "Use \"/usr/local/mgr5/sbin/pkgupgrade.sh coremanager\" command instead"
		exit 1
	fi

	if [ "${pkgname}" != "ispmanager-lite" ]; then
		webserver=""
	fi

	case ${pkgname} in
		ispmanager-lite)
			if [ "${ISPOSTYPE}" = "REDHAT" ]; then
				if PkgInstalled ispmanager-business ; then
					Error "Ispmanager-business already installed"
					exit 1
				fi
				if PkgInstalled ispmanager-pkg-httpd || PkgInstalled ispmanager-pkg-httpd-itk ; then
					Error "Ispmanager-lite already installed"
					exit 1
				fi
			fi
			if [ -z "${webserver}" ]; then
				webserver=nginx
			fi
			pkgname=ispmanager-lite-common
		;;
		ispmanager-lite-common)
			if [ "${ISPOSTYPE}" = "REDHAT" ]; then
				if PkgInstalled ispmanager-business ; then
					Error "Ispmanager-business already installed"
					exit 1
				fi
			fi
		;;
		ispmanager-business)
			if [ "${ISPOSTYPE}" = "REDHAT" ]; then
				if PkgInstalled ispmanager-lite-common; then
					Error "Ispmanager-lite already installed"
					exit 1
				fi
			fi
		;;
		*) ;;
	esac

	if [ "${pkgname}" = "ispmanager-lite" ] || [ "${pkgname}" = "ispmanager-lite-common" ]; then
		while [ -z ${DBTYPE} ]
		do
			echo "Choose database server for ispmanager's internal data"
			echo "1) SQLite (regular load, up to 5-10 sites, 5-10 users)"
			echo "2) MySQL (recommended when maintaining a large number of sites and users)"
			echo
			# shellcheck disable=SC2039,SC2162
			read -p "Choose database server: " d
			echo

			echo "Chosen: ${d}"
			echo

			case "$d" in
				1) DBTYPE=sqlite ;;
				2) DBTYPE=mysql ;;
				*) ;;
			esac
		done
	fi
#	CheckConflicts ${pkgname}

	StartInstall
	trap CancelInstall INT

	if [ "#${added_repo}" != "#yes" ]; then

		if [ "${release}" = "beta6" ] && [ "${ISPOSTYPE}-${OSVER}" = "REDHAT-6" ]; then
			# Strict max version
			release=5.279
		fi

		if [ "${release}" = "beta6" -o "${release}" = "stable6" ] && [ "${mgr}" = "ispmgr" ] && [ -n "${FORCE_ISP5}" ]; then
			# Strict max version
			release=5.333
		fi

		# shellcheck disable=SC2119
		InstallDebRepo || ErrorInstall

		# Цикл из нескольких попыток. Можно надеяться, что за это время CDN разберётся с IP адресами
		IR_FAIL=0
		trc=0
		while [ ${trc} -le 3 ]; do
			trc=$((trc + 1))
			IR_FAIL=0
			InstallRepo true || IR_FAIL=1
			if [ ${IR_FAIL} -ne 0 ]; then
				Error "Some errors with repository"
				sleep 20
			else
				break
			fi
		done
		if [ ${IR_FAIL} -ne 0 ]; then
			Error "Problems with repository. Please try again in an hour"
			# shellcheck disable=SC2119
			ErrorInstall
		fi
	else
		# shellcheck disable=SC2119
		InstallDebRepo || ErrorInstall
		# shellcheck disable=SC2119
		InstallEpelRepo || ErrorInstall
		# shellcheck disable=SC2119
		InstallBaseRepo || ErrorInstall
	fi

	MgrNotExist() {
		cur_arch=$(uname -m)
		if [ "${ISPOSTYPE}" = "REDHAT" ]; then
			cur_os_name="centos"
		else
			cur_os_name=$(lsb_release -s -i | awk '{print tolower($0)}')
		fi
		cur_os_ver=${OSVER}
		cur_os="${cur_os_name}-${cur_os_ver}"
		mgrnotexist() {
			Error "${pkgname} was not found in repos for ${cur_os} ( ${cur_arch} )"
			CancelInstall norepo
		}
		mgrnotexist
		trap - INT TERM EXIT
		exit 1
	}

	PkgAvailable ${pkgname} || MgrNotExist

	if [ "${mgr}" != "core" ]; then
		# shellcheck disable=SC2119
		CoreInstall  || ErrorInstall

		# Xmlgen...
		/usr/local/mgr5/sbin/mgrctl exit >/dev/null

		# new license
		touch /usr/local/mgr5/var/new_license

		# License
		licfetch_count=0
		export HTTP_PROXY=""
		export http_proxy=""
		while true
		do
			licerror=0
			licfetch_count=$((licfetch_count + 1))
			/usr/local/mgr5/sbin/licctl fetch "${licname}" "${ACTIVATION_KEY}" >/dev/null 2>&1 || licerror=$?
			if [ ${licerror} -eq 0 ]; then
				# if not error code get info and exit
				LicInstall
				break
			elif [ "${licfetch_count}" -lt 3 ]; then
				# if less than 3 attempt
				sleep 2
			elif [ -z "${ACTIVATION_KEY}" ]; then
				if [ "#${mgr}" = "#ispmgr" ]; then
					Warning "Trial license for this IP has expired"
				else
					Warning "Can not fetch free license for this IP. You can try again later"
				fi
				Warning "You have no commercial license for ${pkgname} or it can't be activated automatically"
				if [ "#${silent}" != "#true" ]; then
					printf "Please enter activation key or press Enter to exit: "
					read -r ACTIVATION_KEY
					export ACTIVATION_KEY
				fi
				if [ -z "${ACTIVATION_KEY}" ]; then
					exit_flag=1
				fi
			else
				Error "Invalid activation key"
				exit_flag=1
			fi
			if [ -n "${exit_flag}" ]; then
				if locale 2>/dev/null | grep LANG | grep -q "ru_RU.UTF-8" ; then
					Info "Документация находится по адресу: https://docs.ispmanager.ru/coremanager/litsenzirovanie"
				else
					Info "Documentation can be found at https://docs.ispmanager.com/coremanager/types-of-licenses"
				fi
				CancelInstall nolic
				trap - INT TERM EXIT
				exit 1
			fi

		done

		grep -q "manager ispmgr" /usr/local/mgr5/etc/mgrlist.conf || echo "manager ispmgr" >> /usr/local/mgr5/etc/mgrlist.conf

		# Fetching license for repo change
		/usr/local/mgr5/sbin/licctl fetch ${mgr} >/dev/null 2>&1 || :

		if [ -z "${core_installed}" ]; then
			Info "Checking COREmanager downgrade"
			crelease=${release}
			GetCurrentRepo
			chk_inst_ver=$(VersionToRelease $(GetInstalledVersion))
			chk_avail_ver=$(VersionToRelease $(GetAvailVersion ${release}))
			Info "Installed version from repo ${crelease}: ${chk_inst_ver}"
			Info "Remote version in repo ${release}: ${chk_avail_ver}"
			if [ "${crelease}" != "${release}" ] && [ "${chk_inst_ver}" != "${chk_avail_ver}" ]; then
				Info "Downgrading COREmanager"
				PkgRemove coremanager
				PkgInstall coremanager
			else
				Info "Not need to downgrade COREmanager"
			fi
		else
			Info "COREmanager installed before this run. Downgrade checking skipped"
		fi

		LetsEncrypt || :

	fi

	if [ -n "${mysqlserver}" ]; then
		if [ "${pkgname}" = "ispmanager-business" ]; then
			Error "The '--mysql-server' option is only available on ispmanager lite/pro/host"
			exit 1
		fi
		PkgInstall "${mysqlserver}"
	fi

	if [ "${pkgname}" = "ispmanager-lite" ] || [ "${pkgname}" = "ispmanager-lite-common" ]; then
		if [ "${DBTYPE}" = "mysql" ]; then
			PkgInstall coremanager-pkg-mysql
		else
			mkdir -p /usr/local/mgr5/etc/ispmgr.conf.d
			touch /usr/local/mgr5/etc/ispmgr.conf.d/db.conf
		fi
	fi

	# shellcheck disable=SC2119
	PkgInstall ${pkgname} || ErrorInstall

	# TODO. Remove after full systemd-networkd support will be added
	if [ "${ISPOSTYPE}" = "DEBIAN" ]; then
		mkdir -p /etc/network/if-up.d
	fi

	# new license
	touch /usr/local/mgr5/var/new_license

	if [ -z "${disable_fail2ban}" ]; then
		Fail2Ban
	fi

	if [ -n "${webserver}" ]; then
		if [ -x /usr/local/mgr5/sbin/install_recommended.sh ]; then
			Info "Installing recommended packages"
			/usr/local/mgr5/sbin/install_recommended.sh ${webserver}
		else
			if [ "${webserver}" = "nginx" ]; then
				PkgInstall ispmanager-lite
			fi
			if [ -x /usr/local/mgr5/sbin/install_common_recommended.sh ]; then
				Info "Installing common recommended packages"
				/usr/local/mgr5/sbin/install_common_recommended.sh ${webserver}
			fi
		fi
	fi

	FinishInstall &
	MgrInstalled ${mgr} ${pkgname}
	trap - INT TERM EXIT
else
	InstallRepo
	LogClean
fi

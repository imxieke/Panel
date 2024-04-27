#!/bin/sh

set -e

if [ "$(id -u)" != "0" ]; then
	echo "You must be root to execute the script. Exiting."
	exit 1
fi

case $(uname -m) in
x86_64)
	ARCH=amd64
	;;
amd64)
	ARCH=amd64
	;;
aarch64)
	ARCH=arm64
	;;
*)
	echo "DirectAdmin does not support \"$(uname -m)\" CPU architecture. Exiting."
	exit 1
	;;
esac

if [ "$(uname -s)" != "Linux" ]; then
	echo "DirectAdmin does not support \"$(uname -s)\" Operating System. Exiting."
	exit 1
fi

DA_CHANNEL=${DA_CHANNEL:="current"}
DA_OS_SLUG=${DA_OS_SLUG:="linux_${ARCH}"}
DA_PATH=/usr/local/directadmin


case "${1}" in
	--help|help|\?|-\?|h)
		echo ""
		echo "Usage: $0 <license_key>"
		echo ""
		echo "or"
		echo ""
		echo "Usage: DA_CHANNEL=\"beta\" $0 <license_key>"
		echo ""
		echo "You may use the following environment variables to pre-define the settings:"
		echo "  DA_CHANNEL : Download channel: alpha, beta, current, stable"
		echo "   DA_COMMIT : Exact DA build to install, will use latest from update channel if empty"
		echo "  DA_OS_SLUG : Build targeting specific platform: linux_amd64, linux_arm64, ..."
		echo "    DA_EMAIL : Default email address"
		echo " DA_HOSTNAME : Hostname to use for installation"
		echo "  DA_ETH_DEV : Network device"
		echo "      DA_NS1 : pre-defined ns1"
		echo "      DA_NS2 : pre-defined ns2"
		echo ""
		echo "Just set any of these environment variables to non-empty value (for example, DA_SKIP_CSF=true) to:"
		echo "            DA_SKIP_FASTEST : do not check for fastest server"
		echo "                DA_SKIP_CSF : skip installation of CSF firewall"
		echo "      DA_SKIP_MYSQL_INSTALL : skip installation of MySQL/MariaDB"
		echo "         DA_SKIP_SECURE_PHP : skip disabling insecure PHP functions automatically"
		echo "        DA_SKIP_CUSTOMBUILD : skip all the CustomBuild actions"
		echo " DA_INTERACTIVE_CUSTOMBUILD : run interactive CustomBuild installation if DA_SKIP_CUSTOMBUILD is unset"
		echo " DA_FOREGROUND_CUSTOMBUILD  : run CustomBuild installation in foreground DA_SKIP_CUSTOMBUILD is unset"
		echo ""
		echo "To customize any CustomBuild options, we suggest using environment variables: https://docs.directadmin.com/getting-started/installation/overview.html#running-the-installation-with-predefined-options"
		echo ""
		exit 0
		;;
esac

if ! command -v dig > /dev/null || ! command -v curl > /dev/null || ! command -v tar > /dev/null; then
	echo "Installing dependencies..."
	if [ -e /etc/debian_version ]; then
	(
		export DEBIAN_FRONTEND=noninteractive
		export DEBCONF_NOWARNINGS=yes
		apt-get --quiet --yes update || true
		apt-get --quiet --quiet --yes install curl tar dnsutils || true
	)
	else
		yum --quiet --assumeyes install curl tar bind-utils || true
	fi
fi

if ! command -v curl > /dev/null; then
	echo "Please make sure 'curl' tool is available on your system and try again."
	exit 1
fi
if ! command -v tar > /dev/null; then
	echo "Please make sure 'tar' tool is available on your system and try again."
	exit 1
fi

if [ -z "${DA_COMMIT}" ]; then
	echo "Checking for latest build in '${DA_CHANNEL}' release channel..."
	DA_COMMIT=$( (dig +short -t txt "${DA_CHANNEL}-version.directadmin.com" 2>/dev/null || curl --silent "https://dns.google/resolve?name=${DA_CHANNEL}-version.directadmin.com&type=txt" || curl --silent --header 'Accept: application/dns-json' "https://cloudflare-dns.com/dns-query?name=${DA_CHANNEL}-version.directadmin.com&type=txt") | sed 's|.*commit=\([0-9a-f]*\).*|\1|')
fi

if [ -z "${DA_COMMIT}" ]; then
	echo "Unable to detect download URL. Please make sure there are no problems with internet connectivity, IPv6 may be configured improperly."
	exit 1
fi

FILE="directadmin_${DA_COMMIT}_${DA_OS_SLUG}.tar.gz"
TMP_DIR=$(mktemp -d)
cleanup() {
        rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

echo "Downloading DirectAdmin distribution package ${FILE}..."
curl --progress-bar --location --connect-timeout 60 -o "${TMP_DIR}/${FILE}" "https://download.directadmin.com/${FILE}" \
	|| curl --progress-bar --location --connect-timeout 60 -o "${TMP_DIR}/${FILE}" "https://download-alt.directadmin.com/${FILE}"

echo "Extracting DirectAdmin package ${FILE} to /usr/local/directadmin ..."
mkdir -p "${DA_PATH}"
tar xzf "${TMP_DIR}/${FILE}" -C "${DA_PATH}"

chmod 0755 ${DA_PATH}/scripts/setup.sh
${DA_PATH}/scripts/setup.sh "$@"

#!/bin/bash

set -e

info () {
    echo "[INFO] $@"
}

appSetup () {
    echo "[INFO] setup"

    chmod +x /postfix.sh

    echo "root:${ROOT_PASSWORD}" | chpasswd

    postconf -e mynetworks="127.0.0.0/8 [::ffff:127.0.0.0]/104 ${LOCALNETWORK} ${OTHERNETWORK} [::1]/128"
    postconf -e relayhost=[${RELAYHOST}]:587
    postconf -e smtp_sasl_auth_enable=yes
    postconf -e smtp_sasl_password_maps=hash:/etc/postfix/sasl_passwd
    postconf -e smtp_sasl_security_options=noanonymous
    postconf -e smtpd_tls_security_level=may

    echo [${RELAYHOST}]:587 ${RELAYUSER}:${RELAYUSERPASSWORD} >> /etc/postfix/sasl_passwd
    postmap /etc/postfix/sasl_passwd

    touch /etc/postfix/.alreadysetup

}

appStart () {
    [ -f /etc/postfix/.alreadysetup ] && echo "Skipping setup..." || appSetup

    # Start the services
    /usr/bin/supervisord
}

appHelp () {
	echo "Available options:"
	echo " app:start          - Starts all services needed for Samba AD DC"
	echo " app:setup          - First time setup."
	echo " app:help           - Displays the help"
	echo " [command]          - Execute the specified linux command eg. /bin/bash."
}

case "$1" in
	app:start)
		appStart
		;;
	app:setup)
		appSetup
		;;
	app:help)
		appHelp
		;;
	*)
		if [ -x $1 ]; then
			$1
		else
			prog=$(which $1)
			if [ -n "${prog}" ] ; then
				shift 1
				$prog $@
			else
				appHelp
			fi
		fi
		;;
esac

exit 0

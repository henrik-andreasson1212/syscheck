#!/bin/bash

# 1. First check if SYSCHECK_HOME is set then use that
if [ "x${SYSCHECK_HOME}" = "x" ] ; then
# 2. Check if /etc/syscheck.conf exists then source that (put SYSCHECK_HOME=/path/to/syscheck in ther)
    if [ -e /etc/syscheck.conf ] ; then
	source /etc/syscheck.conf
    else
# 3. last resort use default path
	SYSCHECK_HOME="/opt/syscheck"
    fi
fi

if [ ! -f ${SYSCHECK_HOME}/syscheck.sh ] ; then echo "$0: Can't find syscheck.sh in SYSCHECK_HOME ($SYSCHECK_HOME)" ;exit ; fi

## Import common definitions ##
. $SYSCHECK_HOME/config/related-scripts.conf

# scriptname used to map and explain scripts in icinga and other
SCRIPTNAME=copy_ejbca_conf

# uniq ID of script (please use in the name of this file also for convinice for finding next availavle number)
SCRIPTID=913

# Index is used to uniquely identify one test done by the script (a harddrive, crl or cert)
SCRIPTINDEX=00

getlangfiles $SCRIPTID
getconfig $SCRIPTID

ERRNO_1="${SCRIPTID}1"
ERRNO_2="${SCRIPTID}2"
ERRNO_3="${SCRIPTID}3"

### end config ###

PRINTTOSCREEN=1
if [ "x$1" = "x-h" -o "x$1" = "x--help" ] ; then
	echo "$ECRT_HELP"
	echo "$ERRNO_1/$COPY_EJBCA_CONF_DESCR_1 - $COPY_EJBCA_CONF_HELP_1"
	echo "$ERRNO_2/$COPY_EJBCA_CONF_DESCR_2 - $COPY_EJBCA_CONF_HELP_2"
	echo "${SCREEN_HELP}"
	exit
elif [ "x$1" = "x-s" -o  "x$1" = "x--screen" -o \
    "x$2" = "x-s" -o  "x$2" = "x--screen"   ] ; then
    PRINTTOSCREEN=1
fi


# Make sure you add quotation marks for the first argument when adding new files that should be copied, for exampel.
# $SYSCHECK_HOME/related-available/906_ssh-copy-to-remote-machine.sh "$EJBCA_HOME/conf/*.properties" $HOSTNAME_NODE2 $EJBCA_HOME/conf/

echo ""
read -p "Do you want to send EJBCA conf to $HOSTNAME_NODE2 (y/N):" question

if [ "x$question" = "xy" ] ; then
        ${SYSCHECK_HOME}/related-enabled/915_remote_command_via_ssh.sh ${HOSTNAME_NODE2} "mkdir -p /tmp/backup_ejbca/conf/" ${SSH_USER}
	$SYSCHECK_HOME/related-enabled/906_ssh-copy-to-remote-machine.sh -s "$EJBCA_HOME/conf/*" $HOSTNAME_NODE2 /tmp/backup_ejbca/conf/ $SSH_USER

	echo "#######################################################"
	echo "#                                                     #"
	echo "# The conf/ directory is placed in /tmp/backup_ejbca/ #"
	echo "# You have to manually move it to \$EJBCA_HOME/        #"
	echo "# You also have to change the user and group rights   #"
	echo "#                                                     #"
	echo "#######################################################"

	if [ $? -ne 0 ] ; then
		echo "Failed to contact other host"
	fi
else
	echo "Configuration not copied."
fi

echo ""
read -p "Do you want to send EJBCA keys to $HOSTNAME_NODE2 (y/N):" question

if [ "x$question" = "xy" ] ; then
        ${SYSCHECK_HOME}/related-enabled/915_remote_command_via_ssh.sh ${HOSTNAME_NODE2} "mkdir -p /tmp/backup_ejbca/p12/" ${SSH_USER}
	$SYSCHECK_HOME/related-enabled/906_ssh-copy-to-remote-machine.sh -s "$EJBCA_HOME/p12/*" $HOSTNAME_NODE2 /tmp/backup_ejbca/p12/ $SSH_USER

	echo "######################################################"
	echo "#                                                    #"
	echo "# The p12/ directory is placed in /tmp/backup_ejbca/ #"
	echo "# You have to manually move it to \$EJBCA_HOME/       #"
	echo "# You also have to change the user and group rights  #"
	echo "#                                                    #"
	echo "######################################################"

	if [ $? -ne 0 ] ; then
		echo ""
		echo "Failed to contact other host"
	fi
else
        echo "Keys not copied."
fi

echo ""
read -p "Do you want to send syscheck to $HOSTNAME_NODE2 (y/N):" question

if [ "x$question" = "xy" ] ; then
	$SYSCHECK_HOME/related-enabled/906_ssh-copy-to-remote-machine.sh -s "$SYSCHECK_HOME/" $HOSTNAME_NODE2 /tmp/backup_syscheck $SSH_USER
	if [ $? -eq 0 ] ; then
		echo "####################################################################"
		echo "#                                                                  #"
		echo "# The syscheck directory is placed in /tmp/backup_syscheck/        #"
		echo "# You have to manually move it to \$SYSCHECK_HOME/ and change the   #"
		echo "# owner to root and the name of the directory.                     #"
		echo "#                                                                  #"
		echo "# Before you can move /tmp/backup_syscheck/ you have to remove     #"
		echo "# \$SYSCHECK_HOME/ or move it to a different location.              #"
                echo "#                                                                  #"
                echo "# Example:                                                         #"
		echo "# mv /tmp/backup_syscheck \$SYSCHECK_HOME/                          #"
                echo "# chown -R root:root \$SYSCHECK_HOME/                               #"
                echo "#                                                                  #"
		echo "####################################################################"
		echo ""
	else
		echo "Failed to contact other host"
	fi
else
        echo "Syscheck not copied."
fi

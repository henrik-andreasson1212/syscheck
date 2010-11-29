#!/bin/sh

# Script will bring VIP online and make DefaultGateway aware of ARP change.

# Set SYSCHECK_HOME if not already set.

# 1. First check if SYSCHECK_HOME is set then use that
if [ "x${SYSCHECK_HOME}" = "x" ] ; then
# 2. Check if /etc/syscheck.conf exists then source that (put SYSCHECK_HOME=/path/to/syscheck in ther)
    if [ -e /etc/syscheck.conf ] ; then 
	source /etc/syscheck.conf 
    else
# 3. last resort use default path
	SYSCHECK_HOME="/usr/local/syscheck"
    fi
fi

if [ ! -f ${SYSCHECK_HOME}/syscheck.sh ] ; then echo "$0: Can't find syscheck.sh in SYSCHECK_HOME ($SYSCHECK_HOME)" ;exit ; fi





## Import common definitions ##
. $SYSCHECK_HOME/config/related-scripts.conf

# uniq ID of script (please use in the name of this file also for convinice for finding next availavle number)
SCRIPTID=911

getlangfiles $SCRIPTID 
getconfig $SCRIPTID 

ERRNO_1="${SCRIPTID}1"
ERRNO_2="${SCRIPTID}2"
ERRNO_3="${SCRIPTID}3"
ERRNO_4="${SCRIPTID}4"



PRINTTOSCREEN=
if [ "x$1" = "x-h" -o "x$1" = "x--help" ] ; then
	echo "$ACTVIP_HELP"
	echo "$ERRNO_1/$ACTVIP_DESCR_1 - $ACTVIP_HELP_1"
	echo "$ERRNO_2/$ACTVIP_DESCR_2 - $ACTVIP_HELP_2"
	echo "$ERRNO_3/$ACTVIP_DESCR_3 - $ACTVIP_HELP_3"
	echo "${SCREEN_HELP}"
	exit
elif [ "x$1" = "x-s" -o  "x$1" = "x--screen" -o \
    "x$2" = "x-s" -o  "x$2" = "x--screen"   ] ; then
    PRINTTOSCREEN=1
    shift
fi 

IP_GATEWAY=`$ROUTE -n | awk '/0.0.0.0/'| awk '{print $2}' |awk '!/0.0.0.0/'`



CHECK_VIP=`$IFCONFIG ${IF_VIRTUAL} | grep 'inet addr' | grep  ${HOSTNAME_VIRTUAL}` 
if [ "x${CHECK_VIP}" != "x" ] ; then 
	printlogmess $INFO $ERRNO_3 "$ACTVIP_DESCR_3"
	exit
fi

res=`ping -c4 ${HOSTNAME_VIRTUAL} 2>&1`
if [ $? -eq 0 ] ; then
	printlogmess $ERROR $ERRNO_4 "$ACTVIP_DESCR_4" 
	exit
fi

$IFCONFIG ${IF_VIRTUAL} inet ${HOSTNAME_VIRTUAL} netmask ${NETMASK_VIRTUAL} up
if [ $? -eq 0 ] ; then 
    date > ${SYSCHECK_HOME}/var/this_node_has_the_vip
    printlogmess $INFO $ERRNO_1 "$ACTVIP_DESCR_1" "$?" 
else
    printlogmess $ERROR $ERRNO_3 "$ACTVIP_DESCR_3" "$?" 
fi

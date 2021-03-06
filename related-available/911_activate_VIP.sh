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
SCRIPTNAME=activate_vip

# uniq ID of script (please use in the name of this file also for convinice for finding next availavle number)
SCRIPTID=911

# Index is used to uniquely identify one test done by the script (a harddrive, crl or cert)
SCRIPTINDEX=00

getlangfiles $SCRIPTID
getconfig $SCRIPTID

ERRNO_1="01"
ERRNO_2="02"
ERRNO_3="03"
ERRNO_4="04"



PRINTTOSCREEN=
if [ "x$1" = "x-h" -o "x$1" = "x--help" ] ; then
	echo "$HELP"
	echo "$ERRNO_1/$DESCR_1 - $HELP_1"
	echo "$ERRNO_2/$DESCR_2 - $HELP_2"
	echo "$ERRNO_3/$DESCR_3 - $HELP_3"
	echo "${SCREEN_HELP}"
	exit
elif [ "x$1" = "x-s" -o  "x$1" = "x--screen" -o \
    "x$2" = "x-s" -o  "x$2" = "x--screen"   ] ; then
    PRINTTOSCREEN=1
    shift
fi

IP_GATEWAY=`$ROUTE -n | awk '/0.0.0.0/'| awk '{print $2}' |awk '!/0.0.0.0/'`

SCRIPTINDEX=$(addOneToIndex $SCRIPTINDEX)
res=$($IFCONFIG ${IF_VIRTUAL} 2>&1 | grep 'inet addr' | grep  ${HOSTNAME_VIRTUAL} )
if [ "x$res" != "x" ] ; then
	printlogmess ${SCRIPTNAME} ${SCRIPTID} ${SCRIPTINDEX}   $INFO $ERRNO_3 "$DESCR_3" "$res"
	exit
fi

SCRIPTINDEX=$(addOneToIndex $SCRIPTINDEX)
res=$(ping -c4 ${HOSTNAME_VIRTUAL} )
if [ $? -eq 0 ] ; then
	printlogmess ${SCRIPTNAME} ${SCRIPTID} ${SCRIPTINDEX}   $ERROR $ERRNO_4 "$DESCR_4" "$res"
	exit
fi

SCRIPTINDEX=$(addOneToIndex $SCRIPTINDEX)
res=($IFCONFIG ${IF_VIRTUAL} inet ${HOSTNAME_VIRTUAL} netmask ${NETMASK_VIRTUAL} up)
if [ $? -ne 0 ] ; then
	printlogmess ${SCRIPTNAME} ${SCRIPTID} ${SCRIPTINDEX}   $ERROR $ERRNO_2 "$DESCR_2" "$res"
	exit
fi

SCRIPTINDEX=$(addOneToIndex $SCRIPTINDEX)
date > ${SYSCHECK_HOME}/var/this_node_has_the_vip
printlogmess ${SCRIPTNAME} ${SCRIPTID} ${SCRIPTINDEX}   $INFO $ERRNO_1 "$DESCR_1"

SCRIPTINDEX=$(addOneToIndex $SCRIPTINDEX)
res=$(arping -f -q -U ${IP_GATEWAY} -I ${IF_VIRTUAL} -s ${HOSTNAME_VIRTUAL} )
if [ $? -ne 0 ] ; then
    	printlogmess ${SCRIPTNAME} ${SCRIPTID} ${SCRIPTINDEX}   $WARN $ERRNO_6 "$DESCR_6" "$res"
else
	printlogmess ${SCRIPTNAME} ${SCRIPTID} ${SCRIPTINDEX}   $INFO $ERRNO_5 "$DESCR_5"
fi

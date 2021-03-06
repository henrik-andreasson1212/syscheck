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
source $SYSCHECK_HOME/config/syscheck-scripts.conf

# scriptname used to map and explain scripts in icinga and other
SCRIPTNAME=firewall

# uniq ID of script (please use in the name of this file also for convinice for finding next availavle number)
SCRIPTID=09

# Index is used to uniquely identify one test done by the script (a harddrive, crl or cert)
SCRIPTINDEX=00

getlangfiles $SCRIPTID
getconfig $SCRIPTID

ERRNO_1=01
ERRNO_2=02
ERRNO_3=03

# help
if [ "x$1" = "x--help" ] ; then
    echo "$0 $HELP"
    echo "$ERRNO_1/$DESCR_1 - $HELP_1"
    echo "$ERRNO_2/$DESCR_2 - $HELP_2"
    echo "$ERRNO_3/$DESCR_3 - $HELP_3"
    exit
elif [ "x$1" = "x-s" -o  "x$1" = "x--screen"  ] ; then
    PRINTTOSCREEN=1
fi

IPTABLES_TMP_FILE="/tmp/iptables.out"

SCRIPTINDEX=$(addOneToIndex $SCRIPTINDEX)
$IPTABLES_BIN -L -n> $IPTABLES_TMP_FILE
if [ $? -ne 0 ] ; then
	printlogmess ${SCRIPTNAME} ${SCRIPTID} ${SCRIPTINDEX}   $ERROR $ERRNO_1 "$DESCR_1"
	exit
fi
FIREWALLFAILED="0"


SCRIPTINDEX=$(addOneToIndex $SCRIPTINDEX)
# rule that must exist
rule1check=`grep "$IPTABLES_RULE1" $IPTABLES_TMP_FILE`
if [ "x$rule1check" = "x" ] ; then
	FIREWALLFAILED=1
fi

# rule that must not exist
rule2check=`grep "$IPTABLES_RULE2" $IPTABLES_TMP_FILE`
if [ "x$rule2check" != "x" ] ; then
	FIREWALLFAILED=1
fi

if [ $FIREWALLFAILED -ne 0 ] ; then
	printlogmess ${SCRIPTNAME} ${SCRIPTID} ${SCRIPTINDEX}   $ERROR $ERRNO_2 "$DESCR_2"
else
	printlogmess ${SCRIPTNAME} ${SCRIPTID} ${SCRIPTINDEX}   $INFO $ERRNO_3 "$DESCR_3"
fi

rm $IPTABLES_TMP_FILE

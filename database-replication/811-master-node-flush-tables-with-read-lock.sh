#!/bin/bash

#Scripts that creates replication privilegdes for the slave db to the master.

# Set SYSCHECK_HOME if not already set.

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
. $SYSCHECK_HOME/config/database-replication.conf

# uniq ID of script (please use in the name of this file also for convinice for finding next availavle number)
SCRIPTID=811

# Index is used to uniquely identify one test done by the script (a harddrive, crl or cert)
SCRIPTINDEX=00

getlangfiles $SCRIPTID || exit 1;
getconfig $SCRIPTID || exit 1;

ERRNO_1="${SCRIPTID}1"
ERRNO_2="${SCRIPTID}2"

schelp () {
        echo "$HELP"
        echo "$ERRNO_1/$DESCR_1 - $HELP_1"
        echo "$ERRNO_2/$DESCR_2 - $HELP_2"
        echo "${SCREEN_HELP}"
        exit
}

PRINTTOSCREEN=1

if [ "x$1" = "x-h" -o "x$1" = "x--help" ] ; then
        schelp
elif [ "x$1" = "x-s" -o  "x$1" = "x--screen" -o \
    "x$2" = "x-s" -o  "x$2" = "x--screen"   ] ; then
        PRINTTOSCREEN=1
elif [ "x$1" = "x-q" -o  "x$1" = "x--quiet" -o \
    "x$2" = "x-q" -o  "x$2" = "x--quiet"   ] ; then
        PRINTTOSCREEN=0
fi 


echo "Connecting to localhost, ARE YOU SURE THIS HOST IS ACTING AS MASTER"
echo "Enter manually:"
echo "FLUSH TABLES WITH READ LOCK;"
echo "keep the console open until the last step is done"
echo "then enter:"
echo "UNLOCK TABLES;"

SCRIPTINDEX=$(addOneToIndex $SCRIPTINDEX)
$MYSQL_BIN mysql -u root --password="$MYSQLROOT_PASSWORD" 
if [ $? -eq 0 ] ; then
        printlogmess ${SCRIPTNAME} ${SCRIPTID} ${SCRIPTINDEX}   $LEVEL_1 $ERRNO_1 "$DESCR_1"
else
        printlogmess ${SCRIPTNAME} ${SCRIPTID} ${SCRIPTINDEX}   $LEVEL_2 $ERRNO_2 "$DESCR_2"
fi


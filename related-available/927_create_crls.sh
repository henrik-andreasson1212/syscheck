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

# Import common resources
. $SYSCHECK_HOME/config/related-scripts.conf

# scriptname used to map and explain scripts in icinga and other
SCRIPTNAME=create_crls

# uniq ID of script (please use in the name of this file also for convinice for finding next availavle number)
SCRIPTID=927

# Index is used to uniquely identify one test done by the script (a harddrive, crl or cert)
SCRIPTINDEX=00

getlangfiles $SCRIPTID
getconfig $SCRIPTID

ERRNO_1=${SCRIPTID}1
ERRNO_2=${SCRIPTID}2
ERRNO_3=${SCRIPTID}3


if [ "x$1" = "x--help" -o "x$1" = "x-h" ] ; then
	echo $HELP
        echo "$ERRNO_1/$DESCR_1 - $HELP_1"
        echo "$ERRNO_2/$DESCR_2 - $HELP_2"
        echo "$0 <-s|--screen>"
        exit
elif [ "x$1" = "x-s" -o  "x$1" = "x--screen"  ] ; then
    PRINTTOSCREEN=1
fi



printtoscreen "${EJBCA_HOME}/bin/ejbca.sh ca createcrl"
CMD=$(${EJBCA_HOME}/bin/ejbca.sh ca createcrl 2>&1 | tr -d '\n'  | tr -d '\r')

RES=$(echo "$CMD" | grep "CRLs have been created.")
if [ "x$RES" = "x"  ] ; then
        printlogmess ${SCRIPTNAME} ${SCRIPTID} ${SCRIPTINDEX}   $ERROR $ERRNO_2 "$DESCR_2" "$CMD"
else
        printlogmess ${SCRIPTNAME} ${SCRIPTID} ${SCRIPTINDEX}   $INFO $ERRNO_1 "$DESCR_1" "$CMD"
fi
printtoscreen $CMD

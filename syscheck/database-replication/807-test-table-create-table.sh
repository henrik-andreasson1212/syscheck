#!/bin/sh

#Script that creates a test table on the master database.
#the table is created in the EJBCA database and contains a int columnt test
#with the value on 1.
#

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
. $SYSCHECK_HOME/config/database-replication.conf


OUTFILE="$CLUSTERSCRIPT_HOME/tmp_create-test-table.sql"

echo "USE $DB_NAME;" > $OUTFILE
echo 'DROP TABLE IF EXISTS `test`;' >> $OUTFILE
echo "CREATE TABLE test (value INT);" >> $OUTFILE
echo "INSERT INTO test SET value='1';"  >> $OUTFILE

echo "creating the test table:"

$MYSQL_BIN $DB_NAME -u root --password=$MYSQLROOT_PASSWORD < $OUTFILE
rm $OUTFILE
#!/bin/bash

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
. $SYSCHECK_HOME/config/common.conf



echo "# Syscheck version $SYSCHECK_VERSION " 
echo "Documentation generated: $(date)" 


cd $SYSCHECK_HOME/related-available
echo "# Syscheck related scripts " 
for file in * ; do 
	echo "##  $file "        
	echo '```  '             
	./$file --help          
	echo '``` '            
done

cd $SYSCHECK_HOME/scripts-available
echo "# Syscheck scripts" 
for file in * ; do 
	echo "##  $file "     
	echo '```  '         
	./$file --help      
	echo '``` '        
done


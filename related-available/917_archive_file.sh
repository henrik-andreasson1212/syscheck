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
SCRIPTNAME=archive_file

# uniq ID of script (please use in the name of this file also for convinice for finding next availavle number)
SCRIPTID=917

# Index is used to uniquely identify one test done by the script (a harddrive, crl or cert)
SCRIPTINDEX=00

getlangfiles $SCRIPTID
getconfig $SCRIPTID

### end config ###


ERRNO_1=${SCRIPTID}1
ERRNO_2=${SCRIPTID}2
ERRNO_3=${SCRIPTID}3
ERRNO_4=${SCRIPTID}4
ERRNO_5=${SCRIPTID}5
ERRNO_6=${SCRIPTID}6
ERRNO_7=${SCRIPTID}7
ERRNO_8=${SCRIPTID}8
ERRNO_9=${SCRIPTID}9


PRINTTOSCREEN=
if [ "x$1" = "x-h" -o "x$1" = "x--help" ] ; then
	echo "$ARCHIVE_HELP"
	echo "$ERRNO_1/$ARCHIVE_DESCR_1 - $ARCHIVE_HELP_1"
	echo "$ERRNO_2/$ARCHIVE_DESCR_2 - $ARCHIVE_HELP_2"
	echo "$ERRNO_3/$ARCHIVE_DESCR_3 - $ARCHIVE_HELP_3"
	echo "$ERRNO_4/$ARCHIVE_DESCR_4 - $ARCHIVE_HELP_4"
	echo "$ERRNO_5/$ARCHIVE_DESCR_5 - $ARCHIVE_HELP_5"
	echo "$ERRNO_6/$ARCHIVE_DESCR_6 - $ARCHIVE_HELP_6"
	echo "$ERRNO_7/$ARCHIVE_DESCR_7 - $ARCHIVE_HELP_7"
	echo "$ERRNO_8/$ARCHIVE_DESCR_8 - $ARCHIVE_HELP_8"
	echo "$ERRNO_9/$ARCHIVE_DESCR_9 - $ARCHIVE_HELP_9"
	echo "${SCREEN_HELP}"
	exit
elif [ "x$1" = "x-s" -o  "x$1" = "x--screen" -o \
    "x$2" = "x-s" -o  "x$2" = "x--screen"   ] ; then
    shift
    PRINTTOSCREEN=1
fi

KeepOrg=
if [ "x$1" =  "x--keep-org"  ] ; then
    shift
    KeepOrg=1
fi


if [ ! -d ${InTransitDir} ] ; then
	printlogmess ${SCRIPTNAME} ${SCRIPTID} ${SCRIPTINDEX}   $ERROR $ERRNO_9 "$ARCHIVE_DESCR_9"
	exit -1
fi

# arg1
FileToArchive=
if [ "x$1" = "x" ] ; then
	printlogmess ${SCRIPTNAME} ${SCRIPTID} ${SCRIPTINDEX}   $ERROR $ERRNO_3 "$ARCHIVE_DESCR_3"
	exit -1
else
    FileToArchive=$1
fi

# arg2 hostname
ArchiveServer=
if [ "x$2" = "x"  ] ; then
	printlogmess ${SCRIPTNAME} ${SCRIPTID} ${SCRIPTINDEX}   $ERROR $ERRNO_3 "$ARCHIVE_DESCR_3"
	exit -1
else
    ArchiveServer=$2
fi


# arg3 mandatory, eg.: "/store/logs/hostname/"
ArchiveDir=
if [ "x$3" = "x"  ] ; then
        printlogmess ${SCRIPTNAME} ${SCRIPTID} ${SCRIPTINDEX}   $ERROR $ERRNO_3 "$ARCHIVE_DESCR_3"
        exit -1
else
	ArchiveDir=$3
fi

# arg4 optional, if not specified the executing user will be used
SSHTOUSER=
if [ "x$4" != "x"  ] ; then
    SSHTOUSER="$4"
fi


# arg5 optional , if not specified the default key will be used
SSHFROMKEY=
if [ "x$5" != "x"  ] ; then
    SSHFROMKEY="$5"
fi

### func ... ###

moveToIntransit() {
	ShortFileName=$1
	reultFromLocalClaim=`mktemp -p ${InTransitDir} "${ShortFileName}.XXXXXXXXX" | grep  ${ShortFileName} `
	IntransitFileName=`basename $reultFromLocalClaim `

	if [ "x${IntransitFileName}" = "x" ] ; then
		printlogmess ${SCRIPTNAME} ${SCRIPTID} ${SCRIPTINDEX}   $ERROR $ERRNO_8 "$ARCHIVE_DESCR_8" ${IntransitFileName}
		exit -1
	fi
# move the file into the intransit dir and give it a unique name
	if [ "x${KeepOrg}" = "x" ] ; then
	        printtoscreen "mv ${file} ${InTransitDir}/${IntransitFileName}"
       		mv ${file} ${InTransitDir}/${IntransitFileName}
	else
	        printtoscreen "cp ${file} ${InTransitDir}/${IntransitFileName}"
       		cp ${file} ${InTransitDir}/${IntransitFileName}
	fi

	if [ $? != 0 ] ; then
	 	printlogmess ${SCRIPTNAME} ${SCRIPTID} ${SCRIPTINDEX}   $ERROR $ERRNO_2 "$ARCHIVE_DESCR_2" ${file} ${InTransitDir}/${IntransitFileName}
		exit -1
	else
		printlogmess ${SCRIPTNAME} ${SCRIPTID} ${SCRIPTINDEX}   $INFO $ERRNO_7 "$ARCHIVE_DESCR_7" ${file} ${InTransitDir}/${IntransitFileName}
		echo "${IntransitFileName}"
	fi
}

transferFile(){
	ShortFileName=$1
	IntransitFileName=$2

# claim the filename that the file is not already there
	printtoscreen "$SYSCHECK_HOME/related-available/915_remote_command_via_ssh.sh ${ArchiveServer} \"mktemp -p ${ArchiveDir} ${ShortFileName}.XXXXXXXXX\" ${SSHTOUSER} ${SSHFROMKEY}"
	reultFromClaim=`$SYSCHECK_HOME/related-available/915_remote_command_via_ssh.sh ${ArchiveServer} "mktemp -p ${ArchiveDir} ${ShortFileName}.XXXXXXXXX" ${SSHTOUSER} ${SSHFROMKEY}`
	if [ $? != 0 ] ; then
                printlogmess ${SCRIPTNAME} ${SCRIPTID} ${SCRIPTINDEX}   $ERROR $ERRNO_4 "$ARCHIVE_DESCR_4"
		exit -1
	fi
	baseFile=`echo $reultFromClaim | grep ${ShortFileName}`
	remoteFileName=`basename $baseFile`

# transfer the file
 	printtoscreen "$SYSCHECK_HOME/related-available/906_ssh-copy-to-remote-machine.sh "${InTransitDir}/${IntransitFileName}" $ArchiveServer ${ArchiveDir}/${remoteFileName} $SSHTOUSER ${SSHFROMKEY}"
 	$SYSCHECK_HOME/related-available/906_ssh-copy-to-remote-machine.sh "${InTransitDir}/${IntransitFileName}" $ArchiveServer ${ArchiveDir}/${remoteFileName} $SSHTOUSER ${SSHFROMKEY}
	if [ $? != 0 ] ; then
                printlogmess ${SCRIPTNAME} ${SCRIPTID} ${SCRIPTINDEX}   $ERROR $ERRNO_5 "$ARCHIVE_DESCR_5" "${InTransitDir}/${IntransitFileName} $ArchiveServer ${ArchiveDir}/${remoteFileName}"
		exit -1
	fi

	printtoscreen "$SYSCHECK_HOME/related-available/915_remote_command_via_ssh.sh ${ArchiveServer} \"md5sum ${ArchiveDir}/${remoteFileName}\" ${SSHTOUSER} ${SSHFROMKEY}"
	sshresult=`$SYSCHECK_HOME/related-available/915_remote_command_via_ssh.sh ${ArchiveServer} "md5sum ${ArchiveDir}/${remoteFileName}" ${SSHTOUSER} ${SSHFROMKEY}`
	if [ $? != 0 ] ; then
                printlogmess ${SCRIPTNAME} ${SCRIPTID} ${SCRIPTINDEX}   $ERROR $ERRNO_5 "$ARCHIVE_DESCR_5" "md5sum check failed"
		exit -1
	fi
	remoteMD5sum=`echo $sshresult | cut -f1 -d\  `
	localMD5sum=`md5sum ${InTransitDir}/${IntransitFileName} | cut -f1 -d\ `
	if [ "x${remoteMD5sum}" = "x" -o "x${localMD5sum}" = "x" -o ${remoteMD5sum} != ${localMD5sum} ] ; then
		printlogmess ${SCRIPTNAME} ${SCRIPTID} ${SCRIPTINDEX}   $ERROR $ERRNO_5 "$ARCHIVE_DESCR_5" "md5sum check failed"
                exit -1
	fi

# return the filename
        printlogmess ${SCRIPTNAME} ${SCRIPTID} ${SCRIPTINDEX}   $INFO $ERRNO_6 "$ARCHIVE_DESCR_6" "${InTransitDir}/${IntransitFileName} $ArchiveServer ${ArchiveDir}/${remoteFileName}"
	echo "${remoteFileName}"
}

archiveLocally() {
	remoteFileName=$1
	if [ "x${remoteFileName}" = "x" ] ; then exit -1 ; fi
	IntransitFileName=$2
	if [ "x${IntransitFileName}" = "x" ] ; then exit -1 ; fi
# ensure local file is uniq (should be, but just in case)
	i=0
	while [ -r ${remoteFileName} ] ; do
		remoteFileName="${remoteFileName}.$i"
		i=`expr $i + 1`
	done

# move the file locally also
        printtoscreen "mv ${InTransitDir}/${IntransitFileName} ${ArchiveDir}/${remoteFileName}"
        mv ${InTransitDir}/${IntransitFileName} ${ArchiveDir}/${remoteFileName}
	if [ $? != 0 ] ; then
	 	printlogmess ${SCRIPTNAME} ${SCRIPTID} ${SCRIPTINDEX}   $ERROR $ERRNO_2 "$ARCHIVE_DESCR_2" ${InTransitDir}/${IntransitFileName} ${ArchiveDir}/${remoteFileName}
		exit -1
	else
		printlogmess ${SCRIPTNAME} ${SCRIPTID} ${SCRIPTINDEX}   $INFO $ERRNO_1 "$ARCHIVE_DESCR_1" ${InTransitDir}/${IntransitFileName} ${ArchiveDir}/${remoteFileName}
	fi
}

#### end funcs #####


### loop over new files #####

for file in ${FileToArchive} ; do
	printtoscreen $ARCHIVE_PTS_1 $file
# it the file really there ?
	if [ ! -r $file ] ;  then
                printtoscreen "$ARCHIVE_PTS_3" $file
		continue
	fi

# get new filenames
	infile=`basename $file`
	datestr=`date +"%Y-%m-%d_%H.%M.%S"`
	ShortFileName="${datestr}_orgname__${infile}__"

	itFile=`moveToIntransit ${ShortFileName}`
	reFile=`transferFile ${ShortFileName} ${itFile}`
	archiveLocally ${reFile} ${itFile}
done


### loop over failed to transfer files ####

for file in $(ls ${InTransitDir}/* 2>/dev/null) ; do
	printtoscreen $ARCHIVE_PTS_2 $file
	infile=`basename $file`
        reFile=`transferFile ${infile} ${infile} `
        archiveLocally ${reFile} ${infile}
done

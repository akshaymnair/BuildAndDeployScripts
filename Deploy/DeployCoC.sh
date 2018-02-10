#!/usr/bin/ksh

###############################################################################################################
#                                                                                                             #
#       Description  : STELLA CoC Automated Deploy                                                            #
#       Author       : akshayms@in.ibm.com                                                                    #
#       Team         : ICPE	& US Parts                                                                        #
#       Environment	 : For All CoC environments                                                               #
#      Usage(example): ./DeployCoC.sh /home/wasuser/autoDeploy/deployConf/deployConfigDevLive.ini             #
###############################################################################################################


archive() {
echo "Archiving files under $LOGFILEPATH directory started at `date`" >> $LOGFILE
cd $LOGFILEPATH
mkdir $( date +%Y-%m-%d-%H.%M.%S)
dir=$(ls -ltr $LOGFILEPATH | grep '^d' | tail -1| awk '{print $9F}')
mv $LOGFILEPATH/*.log $LOGFILEPATH/$dir
}

CONFILE="$1"
if [ -z "$CONFILE" ]; then
        echo "Please pass the deployConfig file in Usage"
exit 1;
fi

LOGFILE=`grep "^logfile=" $CONFILE|awk '{split($0,A,"=");print A[2]}'`
if [ -z "$LOGFILE" ]; then
	echo "LOGFILE entry not found in $CONFILE" >> $LOGFILE
	exit 1;
fi

DEPLOYLOG=`grep "^deployLog=" $CONFILE|awk '{split($0,A,"=");print A[2]}'`
if [ -z "$DEPLOYLOG" ]; then
	echo "DEPLOYLOG entry not found in $CONFILE" >> $LOGFILE
	exit 1;
fi

LOGFILEPATH=`grep "^logfilepath=" $CONFILE|awk '{split($0,A,"=");print A[2]}'`
if [ -z "$LOGFILEPATH" ]; then
	echo "LOGFILEPATH entry not found in $CONFILE" >> $LOGFILE
	exit 1;
fi

DELETEDFILES=`grep "^deletedFiles=" $CONFILE|awk '{split($0,A,"=");print A[2]}'`
if [ -z "$DELETEDFILES" ]; then
	echo "DELETEDFILES entry not found in $CONFILE" >> $LOGFILE
	exit 1;
fi

HISTORY=`grep "^history=" $CONFILE|awk '{split($0,A,"=");print A[2]}'`
if [ -z "$HISTORY" ]; then
	echo "HISTORY entry not found in $CONFILE" >> $LOGFILE
	exit 1;
fi

CUSTOMFOLDER=`grep "^customFolder=" $CONFILE|awk '{split($0,A,"=");print A[2]}'`
if [ -z "$CUSTOMFOLDER" ]; then
	echo "CUSTOMFOLDER entry not found in $CONFILE" >> $LOGFILE
	exit 1;
fi

ENV=`grep "^env=" $CONFILE|awk '{split($0,A,"=");print A[2]}'`
if [ -z "$ENV" ]; then
	echo "ENV entry not found in $CONFILE" >> $LOGFILE
	exit 1;
fi

MAILBODYTEXTFILE=`grep "^mailbodytextfile=" $CONFILE|awk '{split($0,A,"=");print A[2]}'`
if [ -z "$MAILBODYTEXTFILE" ]; then
	echo "MAILBODYTEXTFILE entry not found in $CONFILE" >> $LOGFILE
	exit 1;
fi

BUILDPACKAGE=`grep "^buildPackage=" $CONFILE|awk '{split($0,A,"=");print A[2]}'`
if [ -z "$BUILDPACKAGE" ]; then
	echo "BUILDPACKAGE entry not found in $CONFILE" >> $LOGFILE
	exit 1;
fi

BACKUPPATH=`grep "^backupPath=" $CONFILE|awk '{split($0,A,"=");print A[2]}'`
if [ -z "$BACKUPPATH" ]; then
	echo "BACKUPPATH entry not found in $CONFILE" >> $LOGFILE
	exit 1;
fi

WCDEPLOY=`grep "^WCdeploy=" $CONFILE|awk '{split($0,A,"=");print A[2]}'`
if [ -z "$WCDEPLOY" ]; then
	echo "WCDEPLOY entry not found in $CONFILE" >> $LOGFILE
	exit 1;
fi

ENVMSG=`grep "^envMsg=" $CONFILE|awk '{split($0,A,"=");print A[2]}'`
if [ -z "$ENVMSG" ]; then
	echo "ENVMSG entry not found in $CONFILE" >> $LOGFILE
	exit 1;
fi

MAILLIST=`grep "^maillist=" $CONFILE|awk '{split($0,A,"=");print A[2]}'`
if [ -z "$MAILLIST" ]; then
       echo "No eMail list provided, add email list" >> $LOGFILE
       exit 1;
fi

orig=$SECONDS
echo "Automated Deploy started... " >> $LOGFILE
echo "====================================================================" >> $LOGFILE
echo "This is console output: Automated Deploy Script Started. Wait till it completes.. "


BACKUP_BUILDPACKAGE=$(echo "$BUILDPACKAGE`date +%m-%d-%Y.%H:%M:%S`")
echo "Backup File name: $BACKUP_BUILDPACKAGE" >> $LOGFILE
mv $CUSTOMFOLDER/$BUILDPACKAGE $BACKUPPATH/$BACKUP_BUILDPACKAGE

echo "" >> $LOGFILE
echo "Backup of build package $BACKUP_BUILDPACKAGE is taken to the path $BACKUPPATH " >> $LOGFILE
echo "" >> $LOGFILE

find $BACKUPPATH -mtime +30 -exec ls -l {} \; >> $DELETEDFILES
echo "Details of Build package's older than 30 days can be found in deletedfiles.log" >> $LOGFILE
echo "" >> $LOGFILE
echo "deleting build packages older than 30 days..." >> $LOGFILE
find $BACKUPPATH -mtime +30 -exec rm {} \;

find $LOGFILEPATH -mtime +30 -exec ls -l {} \; >> $DELETEDFILES
echo "Details of Log file's older than 30 days can be found in deletedfiles.log" >> $LOGFILE
echo "" >> $LOGFILE
echo "deleting log files/ folders older than 30 days..." >> $LOGFILE
find $LOGFILEPATH -mtime +30 -exec rm -r {} \;

cd $WCDEPLOY
nohup ./deploy.sh $BUILDPACKAGE $ENV > $DEPLOYLOG
if [ $? -ne 0 ]; then
	 echo "deploy.sh script's execution failed" >> $LOGFILE
	 mail -s "Build & Deploy Failed in $ENVMSG !!" $MAILLIST
	 exit 1;
 fi
		
echo "Automated Deploy was tried on $(date +"%m-%d-%Y-at%T")" >> $HISTORY
		
echo "Build completed, Logs can be checked on $LOGFILEPATH"  >> $LOGFILE
echo "History of the Automated deploy can be found on AutomatedDeployHistory.log"  >> $LOGFILE
		
mail -s "Build & Deploy Completed on $ENVMSG !!" $MAILLIST < $MAILBODYTEXTFILE
		
echo "Mails send !"  >> $LOGFILE

((ELAPSED=SECONDS-orig))
echo "" >> $LOGFILE
echo "Automated deploy script completed in $ELAPSED seconds !!" >> $LOGFILE
echo "=======================================================================" >> $LOGFILE

archive
echo "Automated deploy script completed in $ELAPSED seconds !!"

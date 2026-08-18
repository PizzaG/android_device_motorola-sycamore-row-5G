#!/system/bin/sh

umask 022

#yexh1 LOGFILE="/data/local/log/aplog/dmesglog"
#if [ $(getprop persist.sys.lenovo.log.path) = INVALID ]; then
#	exit
#fi

#if [ -z "$1" ]; then
#	LOGDIR=$(getprop persist.sys.lenovo.log.path)
#else 
#	LOGDIR=$1  
#fi

#MAIN_LOGFILE=$LOGDIR"/mainlog" #yexh1 
#/system/bin/logcat -r8096 -n 256 -v threadtime -f $MAIN_LOGFILE
/system/bin/logcat -P "" -b all

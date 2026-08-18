#!/system/bin/sh
umask 022

current=`date "+%Y-%m-%d-%H_%M_%S"`

# 'meminfo_${current}' should not be changed for file sort by TreeSet in AppProfiler.
pid=$(getprop sys.zuidebug.dump_pid_meminfo)
if [[ -n "$pid" ]] && [[ "$pid" -gt 0 ]]; then
    dumpsys -t 20 meminfo $pid -a > /data/anr/meminfo_${current}_${pid}.txt
    setprop sys.zuidebug.dump_pid_meminfo -1
    logcat -b all -d > /data/anr/log_${current}_${pid}.txt
else
    dumpsys -t 20 meminfo -a > /data/anr/meminfo_${current}.txt
fi

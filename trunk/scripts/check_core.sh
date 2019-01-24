#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
export PATH

version=`rpm -q srs`
core_log_path="/usr/local/srs/"
last_core_time_log="$core_log_path/last_core_time.log"
#srs_core_dir="/usr/local/srs/"
asynctest_core_dir="/usr/local/srs/"

function report_core()
{
	/usr/sbin/sender -n 'APP_srs_core' -i 's=N,info=${asynctest_core_dir/$core}'
	echo $core_time > $last_core_time_log

	local core_show_time=$(date +%Y%m%d%H%M%S -d "$(stat ${asynctest_core_dir}/$core | grep Modify | awk -F'.' '{print $1}' | awk '{printf("%s %s",$2,$3)}')")
	local pid=$(echo $core|awk -F '.' '{a=0;if(NF==2)print $2;else print a}')
	local file_name="TraceStack_srs_${core_show_time}_$pid.log"
	mkdir -p $report_dir
	echo "$app, $group, $ip, $cp_name, $version, ${asynctest_core_dir}/$core, ${core_show_time}" > $report_dir/$file_name	
}

core=`ls -a $asynctest_core_dir | grep -E '^core(\.[0-9]*)?$' | head -1`
echo $asynctest_core_dir $core

[ -z "$core" ] && exit
[ ! -d $core_log_path ] && mkdir -p $core_log_path
core_time=$(date +%s -d "$(stat $asynctest_core_dir/$core | grep Modify | awk -F'.' '{print $1}' | awk '{printf("%s %s",$2,$3)}')")
last_core_time=$(cat $last_core_time_log 2>/dev/null)

[ -z "$last_core_time" ] && last_core_time=0

if [ $core_time -gt $last_core_time ] && [[ -n `find $asynctest_core_dir -name "core.*" -mmin -5` ]]
then
	report_core
	echo "core happend" > $core_log_path/core_recover_file
else
	if [ -f "$core_log_path/core_recover_file" ]
	then
		/usr/sbin/sender -n 'APP_srs_core' -i 's=Y,info=no new core file'
		rm -f $core_log_path/core_recover_file
	fi
fi

#! /bin/sh
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
export PATH

beacon_core_dir="/usr/local/srs/"

if [ "$beacon_core_dir" != "" ]
then
	cd $beacon_core_dir >/dev/null 2>&1
	if [ $? -ne 0 ]
	then
		exit 1
	fi
	ls -t 2>/dev/null | awk ' BEGIN {core=0} {
	if($0~/^core(\.[0-9]*)?$/){
			if(core>=1) {print $NF} 
			else {core+=1}
		}
	}' | xargs rm -f
fi

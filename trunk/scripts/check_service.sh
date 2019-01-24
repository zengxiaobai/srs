#!/bin/sh
#author hongdj
#date 2017-11-30
#usage:check the service of srs,if restart fail,report to zabbix!
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
export PATH


fail=0
tmpfile=/tmp/srs_check_result

if [ ! -f "$tmpfile" ]; then
 touch "$tmpfile"
fi


#restart fail,report alarm
function report_to_zabbix()
{
   local fail
   local status_info
   fail=$1
   status_info=$2
   if_need_report=`cat $tmpfile|tail -2|grep -Pzo "fail(.|\n)success" |wc -l`
   if [[ $fail -eq 0 ]] ; then
       if [[ $if_need_report -eq 2 ]] ; then
           /usr/sbin/sender -n 'APP_srs_down' -i "s=Y,$status_info" > /dev/null 2>&1
       fi
   else
      /usr/sbin/sender -n 'APP_srs_down' -i "s=N,$status_info" > /dev/null 2>&1
   fi
#   echo $status_info
}


process=`/bin/systemctl status srs |grep "Active:" | egrep "start|reload|running|stop"  | wc -l`
if [ $process -eq 0 ]
then
    fail=`expr $fail + 1`
    status_info="The service of srs maybe is down."
    echo "fail" >> /tmp/srs_check_result

    /bin/systemctl start srs
    echo "`date|awk '{print $2,$3,$4}'` `hostname` check_srs_service.sh: try to start the service of srs" >> /var/log/messages
    sleep 3
    newprocess=`/bin/systemctl status srs |grep "Active:" | grep "active" | grep "running" | wc -l`
    if [ $newprocess -eq 0 ]
    then
         fail=`expr $fail + 1`
         status_info="The service of srs maybe is down."
         echo "fail" >> /tmp/srs_check_result
    fi
else
    echo "success" >> /tmp/srs_check_result
    status_info="The service of srs is ok."
fi
report_to_zabbix $fail "$status_info"
sed -i ':a;1,3{N;ba};N;D' /tmp/srs_check_result

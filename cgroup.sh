#!/bin/bash
#
# Usage: cgroup.sh <sudo_flag> <cgroup_name>
# sudo_flag: must be set to "sudo" to access root-only files, any other value will disable sudo usage
# cgroup_name: full cgroup name as listed in /sys/fs/cgroup
#
# Florent DELAHAYE - 2022


folder="/sys/fs/cgroup/$2"
[ ! -d "$folder" ] && exit 0

prefixsudo=""
if [ "$1" = "sudo" ]; then
  prefixsudo="sudo"
fi

numprocess=0
stat_numthread=0
stat_vsize=0
stat_rss=0
statm_shared=0
status_rss_anon=0
status_rss_file=0
status_rss_shared=0
status_data=0
status_stack=0
status_exe=0
status_lib=0
fdnum=0
io_rchar=0
io_wchar=0
io_read_bytes=0
io_write_bytes=0
io_cancelled_write_bytes=0

for i in $(cat $folder/cgroup.procs); do
  tmp_stat=$(cat "/proc/$i/stat" 2>/dev/null;)
  [ "$?" -ne "0" ] && break
  tmp_statm=$(cat "/proc/$i/statm" 2>/dev/null)
  [ "$?" -ne "0" ] && break
  tmp_status=$(cat "/proc/$i/status" 2>/dev/null)
  [ "$?" -ne "0" ] && break
  tmp_fdnum=$($prefixsudo ls "/proc/$i/fdinfo" 2>/dev/null | wc -l)
  [ "$?" -ne "0" ] && break
  tmp_io=$($prefixsudo cat "/proc/$i/io" 2>/dev/null)
  [ "$?" -ne "0" ] && break

  tmp_stat_numthread=$(echo $tmp_stat | cut -d ' ' -f 20)
  tmp_stat_vsize=$(echo $tmp_stat | cut -d ' ' -f 23)
  tmp_stat_rss=$(echo $tmp_stat | cut -d ' ' -f 24)
  tmp_statm_shared=$(echo $tmp_statm | cut -d ' ' -f 3)
  tmp_status_rss_anon=$(echo "$tmp_status" | grep RssAnon | tr -s ' ' | cut -d ' ' -f 2)
  tmp_status_rss_file=$(echo "$tmp_status" | grep RssFile | tr -s ' ' | cut -d ' ' -f 2)
  tmp_status_rss_shared=$(echo "$tmp_status" | grep RssShmem | tr -s ' ' | cut -d ' ' -f 2)
  tmp_status_data=$(echo "$tmp_status" | grep VmData | tr -s ' ' | cut -d ' ' -f 2)
  tmp_status_stack=$(echo "$tmp_status" | grep VmStk | tr -s ' ' | cut -d ' ' -f 2)
  tmp_status_exe=$(echo "$tmp_status" | grep VmExe | tr -s ' ' | cut -d ' ' -f 2)
  tmp_status_lib=$(echo "$tmp_status" | grep VmLib | tr -s ' ' | cut -d ' ' -f 2)
  tmp_io_rchar=$(echo $tmp_io | cut -d ' ' -f 2)
  tmp_io_wchar=$(echo $tmp_io | cut -d ' ' -f 4)
  tmp_io_read_bytes=$(echo $tmp_io | cut -d ' ' -f 10)
  tmp_io_write_bytes=$(echo $tmp_io | cut -d ' ' -f 12)
  tmp_io_cancelled_write_bytes=$(echo $tmp_io | cut -d ' ' -f 14)

  ((numprocess=numprocess+1))
  ((stat_numthread=stat_numthread+tmp_stat_numthread))
  ((stat_vsize=stat_vsize+tmp_stat_vsize))
  ((stat_rss=stat_rss+(tmp_stat_rss*4096)))
  ((statm_shared=statm_shared+(tmp_statm_shared*4096)))
  ((status_rss_anon=status_rss_anon+tmp_status_rss_anon))
  ((status_rss_file=status_rss_file+tmp_status_rss_file))
  ((status_rss_shared=status_rss_shared+tmp_status_rss_shared))
  ((status_data=status_data+tmp_status_data))
  ((status_stack=status_stack+tmp_status_stack))
  ((status_exe=status_exe+tmp_status_exe))
  ((status_lib=status_lib+tmp_status_lib))
  ((fdnum=fdnum+tmp_fdnum))
  ((io_rchar=io_rchar+tmp_io_rchar))
  ((io_wchar=io_wchar+tmp_io_wchar))
  ((io_read_bytes=io_read_bytes+tmp_io_read_bytes))
  ((io_write_bytes=io_write_bytes+tmp_io_write_bytes))
  ((io_cancelled_write_bytes=io_cancelled_write_bytes+tmp_io_cancelled_write_bytes))
done

echo "cgroup,name=$2 num_process=${numprocess}i,num_thread=${stat_numthread}i,memory_rss=${stat_rss}i,memory_vsize=${stat_vsize}i,memory_shared=${statm_shared}i,memory_rss_anon=${status_rss_anon}i,memory_rss_file=${status_rss_file}i,memory_rss_shared=${status_rss_shared}i,memory_data=${status_data}i,memory_stack=${status_stack}i,memory_exe=${status_exe}i,memory_lib=${status_lib}i,num_fd=${fdnum}i,io_rchar=${io_rchar}i,io_wchar=${io_wchar}i,io_read_bytes=${io_read_bytes}i,io_write_bytes=${io_write_bytes}i,io_cancelled_write_bytes=${io_cancelled_write_bytes}i"

exit 0

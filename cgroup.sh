#!/bin/bash
#
# Usage: cgroup.sh <cgroup_name1> [<cgroup_name2> ...]
#
# Florent DELAHAYE - 2022-2025
# Amélioré par ChatGPT - 2025

process_cgroup() {
  local cgroup_name=$1
  local folder="/sys/fs/cgroup/$cgroup_name"
  [ ! -d "$folder" ] && echo "Cgroup '$cgroup_name' not found" >&2 && return

  local numprocess=0
  local stat_numthread=0 stat_vsize=0 stat_rss=0 statm_shared=0
  local status_rss_anon=0 status_rss_file=0 status_rss_shared=0
  local status_data=0 status_stack=0 status_exe=0 status_lib=0
  local fdnum=0 io_rchar=0 io_wchar=0 io_read_bytes=0 io_write_bytes=0 io_cancelled_write_bytes=0
  local hertz=$(getconf CLK_TCK)
  local cpu_time=0 cpu_time_children=0

  for pid in $(cat "$folder/cgroup.procs" 2>/dev/null); do
    [ ! -d "/proc/$pid" ] && continue

    local tmp_stat tmp_statm tmp_status tmp_fdnum tmp_io
    tmp_stat=$(cat "/proc/$pid/stat" 2>/dev/null) || continue
    tmp_statm=$(cat "/proc/$pid/statm" 2>/dev/null) || continue
    tmp_status=$(cat "/proc/$pid/status" 2>/dev/null) || continue
    tmp_fdnum=$(ls "/proc/$pid/fdinfo" 2>/dev/null | wc -l) || continue
    tmp_io=$(cat "/proc/$pid/io" 2>/dev/null) || continue

    local tmp_stat_utime=$(echo $tmp_stat | cut -d ' ' -f 14)
    local tmp_stat_stime=$(echo $tmp_stat | cut -d ' ' -f 15)
    local tmp_stat_cutime=$(echo $tmp_stat | cut -d ' ' -f 16)
    local tmp_stat_cstime=$(echo $tmp_stat | cut -d ' ' -f 17)
    local tmp_stat_numthread=$(echo $tmp_stat | cut -d ' ' -f 20)
    local tmp_stat_vsize=$(echo $tmp_stat | cut -d ' ' -f 23)
    local tmp_stat_rss=$(echo $tmp_stat | cut -d ' ' -f 24)
    local tmp_statm_shared=$(echo $tmp_statm | cut -d ' ' -f 3)

    local tmp_status_rss_anon=$(echo "$tmp_status" | grep RssAnon | awk '{print $2}')
    local tmp_status_rss_file=$(echo "$tmp_status" | grep RssFile | awk '{print $2}')
    local tmp_status_rss_shared=$(echo "$tmp_status" | grep RssShmem | awk '{print $2}')
    local tmp_status_data=$(echo "$tmp_status" | grep VmData | awk '{print $2}')
    local tmp_status_stack=$(echo "$tmp_status" | grep VmStk | awk '{print $2}')
    local tmp_status_exe=$(echo "$tmp_status" | grep VmExe | awk '{print $2}')
    local tmp_status_lib=$(echo "$tmp_status" | grep VmLib | awk '{print $2}')

    local tmp_io_rchar=$(echo "$tmp_io" | grep rchar | awk '{print $2}')
    local tmp_io_wchar=$(echo "$tmp_io" | grep wchar | awk '{print $2}')
    local tmp_io_read_bytes=$(echo "$tmp_io" | grep read_bytes | awk '{print $2}')
    local tmp_io_write_bytes=$(echo "$tmp_io" | grep write_bytes | awk '{print $2}')
    local tmp_io_cancelled_write_bytes=$(echo "$tmp_io" | grep cancelled_write_bytes | awk '{print $2}')

    ((numprocess++))
    ((stat_numthread+=tmp_stat_numthread))
    ((stat_vsize+=tmp_stat_vsize))
    ((stat_rss+=tmp_stat_rss*4096))
    ((statm_shared+=tmp_statm_shared*4096))
    ((status_rss_anon+=tmp_status_rss_anon))
    ((status_rss_file+=tmp_status_rss_file))
    ((status_rss_shared+=tmp_status_rss_shared))
    ((status_data+=tmp_status_data))
    ((status_stack+=tmp_status_stack))
    ((status_exe+=tmp_status_exe))
    ((status_lib+=tmp_status_lib))
    ((fdnum+=tmp_fdnum))
    ((io_rchar+=tmp_io_rchar))
    ((io_wchar+=tmp_io_wchar))
    ((io_read_bytes+=tmp_io_read_bytes))
    ((io_write_bytes+=tmp_io_write_bytes))
    ((io_cancelled_write_bytes+=tmp_io_cancelled_write_bytes))
    ((cpu_time+=(tmp_stat_utime+tmp_stat_stime)/hertz))
    ((cpu_time_children+=(tmp_stat_utime+tmp_stat_stime+tmp_stat_cutime+tmp_stat_cstime)/hertz))
  done

  echo "cgroup,name=$cgroup_name num_process=${numprocess}i,num_thread=${stat_numthread}i,memory_rss=${stat_rss}i,memory_vsize=${stat_vsize}i,memory_shared=${statm_shared}i,memory_rss_anon=${status_rss_anon}i,memory_rss_file=${status_rss_file}i,memory_rss_shared=${status_rss_shared}i,memory_data=${status_data}i,memory_stack=${status_stack}i,memory_exe=${status_exe}i,memory_lib=${status_lib}i,num_fd=${fdnum}i,io_rchar=${io_rchar}i,io_wchar=${io_wchar}i,io_read_bytes=${io_read_bytes}i,io_write_bytes=${io_write_bytes}i,io_cancelled_write_bytes=${io_cancelled_write_bytes}i,cpu_time=${cpu_time}i,cpu_time_children=${cpu_time_children}i"
}

for cgroup in "$@"; do
  process_cgroup "$cgroup"
done

exit 0

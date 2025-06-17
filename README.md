# Cgroup metrics
Cgroup metrics using influx format. May be used with Telegraf as an alternative of the procstat plugin. It doesn't need to be run as root but may requires appropriate sudoers instead.

# Usage
```
Usage: Usage: cgroup.sh <cgroup_name1> [<cgroup_name2> ...]
cgroup_name: full cgroup name as listed in /sys/fs/cgroup

Returns values as influx format
```

# Metrics
| Name | Source | Root access required |
| - | - | - |
|num_process|/sys/fs/cgroup/CGROUP/procs|no|
|num_thread|/proc/PID/stat|no|
|memory_rss|/proc/PID/stat|no|
|memory_vsize|/proc/PID/stat|no|
|memory_shared|/proc/PID/statm|no|
|memory_rss_anon|/proc/PID/status|no|
|memory_rss_file|/proc/PID/status|no|
|memory_rss_shared|/proc/PID/status|no|
|memory_data|/proc/PID/status|no|
|memory_stack|/proc/PID/status|no|
|memory_exe|/proc/PID/status|no|
|memory_lib|/proc/PID/status|no|
|num_fd|/proc/PID/fdinfo|yes|
|io_rchar|/proc/PID/io|yes|
|io_wchar|/proc/PID/io|yes|
|io_read_bytes|/proc/PID/io|yes|
|io_write_bytes|/proc/PID/io|yes|
|io_cancelled_write_bytes|/proc/PID/io|yes|
|cpu_time|/proc/PID/stat|no|
|cpu_time_children|/proc/PID/stat|no|

# Implementation with Telegraf
Sudo configuration:
```
telegraf ALL=(root) NOPASSWD: /bin/bash /path/to/script/cgroup.sh *
```
Telegraf configuration:
```
[[inputs.exec]]
  commands = ["sudo bash /usr/lib/telegraf/plugins/cgroup.sh system.slice/nginx.service system.slice/fail2ban.service"]
  timeout = "5s"
  data_format = "influx"
```

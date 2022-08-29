# Cgroup metrics
Cgroup metrics using influx format. May be used with Telegraf as an alternative of the procstat plugin. It doesn't need to be run as root but may requires appropriate sudoers instead.

# Usage
```
Usage: cgroup.sh <sudo_flag> <cgroup_name>
sudo_flag: must be set to "sudo" to access root-only files using sudo, any other value will disable sudo usage
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

# Implementation with Telegraf
Sudo configuration:
```
telegraf ALL=(root) NOPASSWD: /usr/bin/ls /proc/*, /usr/bin/cat /proc/*
```
Telegraf configuration:
```
[[inputs.exec]]
  commands = ["sh /usr/lib/telegraf/plugins/cgroup.sh sudo systemd/system.slice/nginx.service"]
  timeout = "5s"
  data_format = "influx"
```

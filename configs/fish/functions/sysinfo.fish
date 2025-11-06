function sysinfo
  echo "Hostname: "(hostname)
  echo "Kernel: "(uname -r)
  echo "Uptime: "(uptime -p)
  echo "Memory: "(free -h | grep Mem | awk '{print $3 "/" $2}')
  echo "Disk: "(df -h / | tail -1 | awk '{print $3 "/" $2}')
end

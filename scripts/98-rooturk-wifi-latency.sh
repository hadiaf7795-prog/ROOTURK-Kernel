#!/system/bin/sh
# ROOTURK Wi-Fi: boost = game latency, save = power save.
if [ "$1" != apply ]; then
  until [ "$(getprop sys.boot_completed)" = 1 ]; do sleep 2; done
  sleep 12
fi
mode=$(cat /data/adb/rooturk/net_mode 2>/dev/null)
[ -z "$mode" ] && mode=boost
if [ "$mode" = save ]; then
  echo menu > /sys/devices/system/cpu/cpuidle/current_governor 2>/dev/null
  iw dev wlan0 set power_save on 2>/dev/null
  for c in 0 1 2 3 4 5 6 7; do
    echo 0 > /sys/devices/system/cpu/cpu$c/cpuidle/state2/disable 2>/dev/null
    echo 0 > /sys/devices/system/cpu/cpu$c/cpuidle/state3/disable 2>/dev/null
    echo 0 > /sys/devices/system/cpu/cpu$c/cpuidle/state4/disable 2>/dev/null
    echo 0 > /sys/devices/system/cpu/cpu$c/cpuidle/state5/disable 2>/dev/null
  done
  grep wlan0 /proc/interrupts | while read -r line; do
    irq=${line%%:*}
    irq=$(echo "$irq" | tr -d ' ')
    [ -n "$irq" ] && echo 0-7 > /proc/irq/$irq/smp_affinity_list 2>/dev/null
  done
else
  echo lpm_gov_mhsp > /sys/devices/system/cpu/cpuidle/current_governor 2>/dev/null
  iw dev wlan0 set power_save off 2>/dev/null
  for c in 0 1 2 3 4 5 6 7; do
    echo 1 > /sys/devices/system/cpu/cpu$c/cpuidle/state2/disable 2>/dev/null
    echo 1 > /sys/devices/system/cpu/cpu$c/cpuidle/state3/disable 2>/dev/null
    echo 1 > /sys/devices/system/cpu/cpu$c/cpuidle/state4/disable 2>/dev/null
    echo 1 > /sys/devices/system/cpu/cpu$c/cpuidle/state5/disable 2>/dev/null
  done
  grep wlan0 /proc/interrupts | while read -r line; do
    irq=${line%%:*}
    irq=$(echo "$irq" | tr -d ' ')
    [ -n "$irq" ] && echo 7 > /proc/irq/$irq/smp_affinity_list 2>/dev/null
  done
fi

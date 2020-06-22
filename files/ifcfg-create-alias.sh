#!/bin/bash

# Warewulf doesn't support network interface aliases (e.g. ib0:1).
# So create the ifcfg- files and bring up the Lustre networks here
# instead, and launch from a systemd unit.

parent=$1

parent_ip=$(ip a show dev ${parent} scope global | awk '{if ($1 == "inet") {print $2}}' | awk -F/ '{print $1}' | head -1 )

shift
while (( "$#" )); do
# Alias IP
aip=$(echo $parent_ip | awk -v aname=$1 'BEGIN {FS="."; OFS="."} {print $1, 10 + aname, $3, $4}')

alias_full="${parent}:$1"

cat <<EOF > /etc/sysconfig/network-scripts/ifcfg-${alias_full}
DEVICE=${alias_full}
NAME=${alias_full}
PHYSDEV=${parent}
BOOTPROTO=none
TYPE=InfiniBand
IPADDR=${aip}
ONBOOT=yes
NETMASK=255.255.0.0
IPV6INIT=no
NM_CONTROLLED=no
EOF

ifup ${alias_full}
shift

done

while ! dmesg | grep "${parent}: link becomes ready"
do
    sleep 1
done

modprobe lustre
mount /scratch

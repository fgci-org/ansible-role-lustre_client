# Add extra IPS to interface (to be used for Lustre Lnet multi-rail)
BEGIN {
    FS="=";
}
{
    if ($1 == "IPADDR") {
        split($2, ips, ".")
        printf "IPADDR0=%s\n", $2
        printf "IPADDR1=%s.%s.%s.%s\n", ips[1], ips[2] + 1, ips[3], ips[4]
        printf "IPADDR2=%s.%s.%s.%s\n", ips[1], ips[2] + 2, ips[3], ips[4]
    }
    else if ($1 == "NETMASK") {
        printf "NETMASK0=%s\nNETMASK1=%s\nNETMASK2=%s\n", $2, $2, $2
    }
    else {
        printf "%s=%s\n", $1, $2
    }
}

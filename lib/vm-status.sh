. $VM_LIB/functions-net.sh

vm_progress Getting ip address for $VM_NET_HOST
H_IP=`vm_get_ip`

if [ -z "$H_IP" ]; then
    test $QUIET -eq 1  || vm_echo unknown ip address for host $VM_NET_HOST
    exit 1
fi

vm_progress Getting fully qualified host name for $H_IP
H_NAME=`vm_get_full_name $H_IP`

if [ -z "$H_NAME" ]; then
    test $QUIET -eq 1 || vm_echo Unable to determine full name for "$H_IP ($VM_NET_HOST)"
    exit 1
fi

vm_progress Checking whether $H_IP is up
H_PING=`vm_ping`

if [ -z "$H_PING" ]; then
    test $QUIET -eq 1 || vm_echo Host $VM_NET_HOST is down
    exit 1
fi

vm_progress Retrieving virtual machine status
H_STAT=`vm_get_status`

if [ -z "$H_STAT" ]; then
    test $QUIET -eq 1 || vm_echo Error contacting monitor on $VM_NET_HOST port $VM_NET_PORT
    exit 1
fi

if [ "$H_STAT" != "running" ]; then
    test $QUIET -eq 1 || vm_echo Machine is $H_STAT
    exit 1
fi

vm_echo_if_verbose Host address is $H_IP
vm_echo_if_verbose Host name is $H_NAME
vm_echo_if_verbose Host ping returns $H_PING

vm_progress Checking if ssh is available
H_SSH=`vm_check_ssh`

if [ "$H_SSH" != "ok" -a "$NOSSH" = "0" ]; then
    test $QUIET -eq 1 || vm_echo Error contacting ssh service: $H_SSH
    exit 1
fi

vm_echo_if_verbose Guest ssh: $H_SSH

if [ "$H_SSH" != "ok" ]; then exit 0; fi

H_SUSP=`vm_get_suspend_method`

test -z $H_SUSP && H_SUSP='<not available>'

vm_echo_if_verbose Guest suspend: $H_SUSP

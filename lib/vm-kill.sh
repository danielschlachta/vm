. $VM_LIB/functions-net.sh

QPID=`ps ax|grep 77$VM_MACHINE_ID| awk '/qemu/ { print $1 }'`

test -z $QPID && vm_die virtual machine not running

vm_progress Retrieving virtual machine status
H_STAT=`vm_get_status`

if [ -z "$H_STAT" ]; then
    vm_echo_if_verbose Error contacting monitor on $VM_NET_HOST port $VM_NET_PORT
else
    vm_echo_if_verbose Machine is $H_STAT
    vm_echo_if_verbose Shutting down
    vm cmd q
fi

sleep 1

QPID=`ps ax|grep 77$VM_MACHINE_ID| awk '/qemu/ { print $1 }'`

if [ "$QPID" != "" ]; then
    vm_echo_if_verbose Process id $QPID still running, sending SIGQUIT
    kill -9 $QPID
fi


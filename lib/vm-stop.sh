. $VM_LIB/functions-net.sh

vm_progress Retrieving virtual machine status
H_STAT=`vm_get_status`

if [ -z "$H_STAT" ]; then
    vm_error Error contacting monitor on $VM_NET_HOST port $VM_NET_PORT
    exit 1
fi

vm_echo_if_verbose Machine is $H_STAT

vm_progress Checking if ssh is available
H_SSH=`vm_check_ssh`

if [ "$H_SSH" != "ok" ]; then
    vm_error Error contacting ssh service: $H_SSH
    exit 1
fi

if [ "$POWEROFF" = "1" ]; then
    vm_echo_if_verbose Sending poweroff command
    vm_poweroff
else
    vm_echo_if_verbose Sending suspend command
    vm_suspend
fi

sleep 2

if [ "$SAVEVM" != "" ]; then
    vm_echo_if_verbose Saving snapshot \'$SAVEVM\'
    vm cmd savevm $SAVEVM
    vm_echo_if_verbose Syncing filesystem
    sync
fi

vm_echo_if_verbose Shutting down
vm cmd q

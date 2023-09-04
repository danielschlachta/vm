. $VM_LIB/functions-net.sh

if [ "$POWEROFF" = "0" -a "`vm_get_suspend_method`" = "" ]; then vm_die suspend requested but not available; fi

vm_progress Retrieving virtual machine status
H_STAT=`vm_get_status`

if [ -z "$H_STAT" ]; then vm_die Error contacting monitor on $VM_NET_HOST port $VM_NET_PORT; fi

vm_echo_if_verbose Machine is $H_STAT

vm_progress Checking if ssh is available
H_SSH=`vm_check_ssh`

if [ "$H_SSH" != "ok" ]; then vm_die Error contacting ssh service: $H_SSH; fi

if [ "$POWEROFF" = "1" ]; then
    vm_echo_if_verbose Sending poweroff command
    vm_poweroff
else
    vm_echo_if_verbose Sending suspend command
    vm_suspend
fi

if [ "$SAVEVM" != "" ]; then
    vm_echo_if_verbose Saving snapshot \'$SAVEVM\'
    vm cmd savevm $SAVEVM
fi

sleep 5

vm_echo_if_verbose Shutting down
vm cmd q

if [ "$SAVEVM" != "" ]; then
    vm_echo_if_verbose Syncing filesystem
    sync .
fi

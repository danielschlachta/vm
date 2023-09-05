. $VM_LIB/functions-net.sh

vm_check_running || vm_die virtual machine not running

if [ "$POWEROFF" = "0" -a "$NOSUSPEND" = "0" -a "`vm_get_suspend_method`" = "" ]; then vm_die suspend requested but not available; fi

vm_progress Retrieving virtual machine status
H_STAT=`vm_get_status`

if [ -z "$H_STAT" ]; then vm_die Error contacting monitor on $VM_NET_HOST port $VM_NET_PORT; fi

vm_echo_if_verbose Machine is $H_STAT

if [ "$NOSUSPEND" = "0" ]; then
    vm_progress Checking if ssh is available
    H_SSH=`vm_check_ssh`

    if [ "$H_SSH" != "ok" ]; then vm_die Error contacting ssh service: $H_SSH; fi

    vm_echo_if_verbose Sending suspend command
    vm_suspend
fi

if [ "$SAVEVM" != "" ]; then
    vm_echo_if_verbose Saving snapshot \'$SAVEVM\'
    vm cmd savevm $SAVEVM
    # Need to give it time to actually save the snapshot!
    sleep 5
fi

vm_echo_if_verbose Shutting down
vm cmd q

if [ "$SAVEVM" != "" ]; then
    vm_echo_if_verbose Syncing filesystem
    sync .
fi

. $VM_LIB/functions-net.sh

vm_check_running || vm_die virtual machine not running

if [ "$POWEROFF" = "0" -a "$NOSUSPEND" = "0" -a "`vm_get_suspend_method`" = "" ]; then vm_die suspend requested but not available; fi

vm_progress Retrieving virtual machine status
H_STAT=`vm_get_status`

if [ -z "$H_STAT" ]; then vm_die Error contacting monitor on $VM_NET_HOST port $VM_NET_PORT; fi

vm_echo_if_verbose Machine is $H_STAT

if [ "$NOSUSPEND" = "0" -a "$POWEROFF"="0" ]; then
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

if [ "$POWEROFF" = "1" ]; then
    vm_echo_if_verbose Sending poweroff command
    vm_poweroff

    ATT=120

    while [ $ATT -gt 0 ]; do
        vm_progress Waiting for virtual machine to shut down \($ATT attempts remaining\)
        ATT=$(($ATT - 1))

        STAT=`vm_get_status | grep shutdown`

        if [ "$STAT" != "" ]; then break; fi

        sleep 2
    done
fi

vm_progress_stop

vm_echo_if_verbose Shutting down emulator
vm cmd q

vm_echo_if_verbose Syncing filesystem
sync .

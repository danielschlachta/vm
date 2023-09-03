. $VM_LIB/functions-net.sh

QPID=`ps ax|grep 77$VM_MACHINE_ID| awk '/qemu/ { print $1 }'`

test -z $QPID || vm_die virtual machine is already running

CMD="vm run"

if [ "$NAT" = "0" ]; then vm_check_root; else CMD="$CMD --nat"; fi
if [ "$VERBOSE" = "1" ]; then CMD="$CMD --verbose"; fi
if [ "$LOADVM" != "" ]; then CMD="$CMD --loadvm $LOADVM"; fi

vm_echo_if_verbose Starting virtual machine \'$VM_MACHINE_NAME\'

$CMD &

ATT=10

while [ $ATT -gt 0 ]; do
    vm_progress Waiting for virtual machine to come online \($ATT attempts remaining\)
    ATT=$(($ATT - 1))

    STAT=`vm_get_status`

    if [ "$STAT" != "" ]; then break; fi

    sleep 2
done

if [ "$ATT" = "0" ]; then vm_die Virtual machine did not start; fi

sleep 3

STAT=`vm_get_status`
vm_echo_if_verbose Machine is $STAT

if [ "`echo $STAT|grep susp`" != "" ]; then
    vm_echo_if_verbose Issuing wakeup command
    vm cmd system_wakeup
fi

if [ "$NAT" = "0" ]; then
    ATT=30

    while [ $ATT -gt 0 ]; do
        vm_progress Waiting for ssh service to become available \($ATT attempts remaining\)
        ATT=$(($ATT - 1))

        STAT=`vm_check_ssh`

        if [ "$STAT" = "ok" ]; then break; fi

        sleep 2
    done

    if [ "$ATT" = "0" ]; then vm_die Unable to connect to virtual machine via ssh; fi

    vm_echo_if_verbose Virtual machine is ready
fi

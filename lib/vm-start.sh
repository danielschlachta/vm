. $VM_LIB/functions-net.sh

if [ "$ENCAPSULATE" == "1" ]
then 
	vm_check_prog screen
	vm_die_if_error
fi

test "$VM_QEMU_DISPLAY" = "curses" -a "$ENCAPSULATE" = "0" && vm_die can\'t start curses interface in background - use --encapsulate or vm run

vm_check_running && vm_die virtual machine is already running

CMD="vm run"

if [ "$NAT" = "0" ]; then vm_check_root; else CMD="$CMD --nat"; fi
if [ "$LOADVM" != "" ]; then CMD="$CMD --loadvm $LOADVM"; fi

vm_echo_if_verbose Starting virtual machine \'$VM_MACHINE_NAME\'
if [ "$ENCAPSULATE" == "1" ]
then
	screen -md $CMD
else
        $CMD > /dev/null 2> /dev/null &
fi

ATT=10

while [ $ATT -gt 0 ]; do
    vm_progress Waiting for monitor interface to come up \($ATT attempts remaining\)
    ATT=$(($ATT - 1))

    STAT=`vm_get_status`

    if [ "$STAT" != "" ]; then break; fi

    sleep 2
done

if [ "$ATT" = "0" ]; then vm_echo_if_verbose Emulator is dead; exit 1; fi

sleep 3

STAT=`vm_get_status`
test -z "$STAT" || vm_echo_if_verbose Machine is $STAT

if [ "`echo $STAT|grep susp`" != "" ]; then
    vm_echo_if_verbose Issuing wakeup command
    vm cmd system_wakeup
fi

if [ "$NAT" = "0" ]; then
    ATT=$SSH_ATT

    while [ $ATT -gt 0 ]; do
        if [ ! vm_check_running ]; then
            echo Emulator has died
            exit 1
        fi
        
        vm_progress Waiting for ssh service to become available \($ATT attempts remaining\)

        ATT=$(($ATT - 1))

        STAT=`vm_check_ssh`

        if [ "$STAT" = "ok" ]; then break; fi

        sleep 2
    done

    if [ "$ATT" = "0" ]; then vm_echo_if_verbose Unable to connect to virtual machine via ssh; exit 1; fi

    vm_echo_if_verbose Virtual machine is ready
fi

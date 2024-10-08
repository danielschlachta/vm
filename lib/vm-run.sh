vm_check_var VM_MACHINE_MEM

vm_check_running && vm_die virtual machine is already running

if [ "`echo $VM_QEMU_EXTRA$* | grep daemonize`" != "" ]; then \
    vm_die -daemonize option is incompatible with vm run, please use vm start instead; fi

if [ "$VM_USE_SNAPSHOTS" != "no" -a ! -f "$VM_SNAPSHOT_BACKING_FILENAME" -a "$BASE" != "1" ]; then \
    vm_die snapshots configured, but backing file \'$VM_SNAPSHOT_BACKING_FILENAME\' not found, use -b to \
    use the base file instead; fi

if [ "$VM_USE_SNAPSHOTS" != "no" -a "$BASE" = "1" -a ! -f "$VM_SNAPSHOT_BASE_FILENAME"  ]; then vm_die base \
    file \'$VM_SNAPSHOT_BASE_FILENAME\' not found; fi

if [ "$VM_USE_SNAPSHOTS" != "no" ]
then
    if [ "$BASE" = "1" ]; then HDA=$VM_SNAPSHOT_BASE_FILENAME; else HDA=$VM_SNAPSHOT_BACKING_FILENAME; fi
else
    HDA=$VM_MACHINE_NAME.$VM_FMT
fi

if [ "$VM_QEMU_DISPLAY" != "" ]; then DISP="-display $VM_QEMU_DISPLAY"; fi
if [ "$VM_QEMU_VNC" != "" ]; then VNC="-vnc $VM_QEMU_VNC"; fi

function getid()
{
        nmcli connection show | awk '/UUID/ { ind=index($0, "UUID") } /^'$1'/ { print substr($0, ind, 36) }'
}

function flt() {
    if [ "$VERBOSE" = "1" ]
    then
        while read line; do vm_echo $line; done
    else
        cat > /dev/null
    fi
}

if [ "`pgrep NetworkManager`" != "" ]; then HAVE_NETMAN=yes; fi

if [ "`ip address show dev bridge0 2> /dev/null`" != "" ]; then HAVE_BRIDGE=yes; fi

if [ "$BRIDGE" = "1" ]
then
    if [ "$HAVE_BRIDGE" = "yes" ] 
    then
       vm_die device bridge0 already exists
    else
        if [ "$HAVE_NETMAN" = "yes" ]
        then
            vm_check_prog nmcli
            vm_die_if_error
            
            ETH=`ip address | awk '/^2:/ { print $2 }' | cut -d: -f1`
            
            if [ "$ETH" = "" ]; then vm_die could not find ethernet interface; fi

            nmcli connection add type bridge ifname bridge0 stp no | flt
            nmcli connection add type bridge-slave ifname $ETH master bridge0 | flt

            nmcli connection up `getid bridge-bridge0` | flt
            #nmcli connection up `getid bridge-slave` | flt

            sleep 2
        else
            vm_die bridge creation requested but nmcli not found
        fi
    fi
fi

if [ "`ip address show dev bridge0 2> /dev/null`" != "" ]; then HAVE_BRIDGE=yes; fi

if [ "$NAT" != "1" ]
then
    vm_check_prog ip
    vm_check_prog pgrep

    vm_die_if_error
fi

if [ "$HAVE_BRIDGE" = "" -a "$NAT" != "1" ]; then vm_die no bridge interface available; fi


if [ "$NAT" = "1" ]
then
    NET_IF=""
else
    vm_check_root
    NET_IF="-device e1000,netdev=net0,mac=DE:AD:BE:EF:${VM_MACHINE_ID}:11 -netdev tap,id=net0"
fi

CMD="qemu-system-x86_64 -enable-kvm -cpu host -m $VM_MACHINE_MEM \
    -monitor telnet:$VM_NET_LISTEN:$VM_NET_PORT,server,nowait \
    $NET_IF -hda $HDA -no-shutdown $LOADVM $DISP $VNC $VM_QEMU_EXTRA $*"

if [ "$VERBOSE" = "1" ]; then vm_echo $CMD; fi
$CMD

if [ "$BRIDGE" = "1" -a "$HAVE_BRIDGE" = "yes" ]
then
    nmcli connection del `getid bridge-slave-enp2s0` | flt
    nmcli connection del `getid bridge-bridge0` | flt
fi

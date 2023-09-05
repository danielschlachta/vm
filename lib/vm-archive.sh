test -z "$VM_USE_SNAPSHOTS" && vm_die snapshots not enabled
test -f $VM_SNAPSHOT_BASE_FILENAME || vm_die base file \'$VM_SNAPSHOT_BASE_FILENAME\' not found

VM_ARCHIVE=$VM_MACHINE_NAME-`date -r $VM_SNAPSHOT_BASE_FILENAME "+%Y%m%d%H%M%S"`

function save_backing()
{
    TSTAMP=`date -r $VM_SNAPSHOT_BACKING_FILENAME "+%Y%m%d%H%M%S"`
    TARGET=$VM_ARCHIVE/$VM_MACHINE_NAME-$VM_SNAPSHOT_BACKINGNAME-$TSTAMP.$VM_FMT

    if [ "$VERBOSE" = "1" ]; then vm_echo Securing backing file \'$VM_SNAPSHOT_BACKING_FILENAME\'; V=-v; else Q=-q; fi
    pv $Q $VM_SNAPSHOT_BACKING_FILENAME > $TARGET
    if [ "$COMPRESS" = "1" ]; then $COMPRESSOR -f $V $TARGET; fi
}

if [ "$CREATE" = "1" ]; then
    vm_check_prog pv
    vm_die_if_error

    test -d $VM_ARCHIVE && vm_die archive directory \'$VM_ARCHIVE\' already exists, not clobbering it
    test -f $VM_SNAPSHOT_BASE_FILENAME || vm_die base file \'$VM_SNAPSHOT_BASE_FILENAME\' not found

    vm_check_running && vm_die virtual machine is running

    if [ "$VERBOSE" = "1" ]; then vm_echo Creating archive directory \'$VM_ARCHIVE\'; V=-v; else Q=-q; fi
    mkdir -p $VM_ARCHIVE

    if [ "$VM" != "" ]; then
        if [ "$VERBOSE" = "1" ]; then vm_echo Deleting snapshot \'$VM\'; fi
        qemu-img snapshot $Q -d $VM $VM_SNAPSHOT_BACKING_FILENAME
    fi

    if [ "$VERBOSE" = "1" ]; then vm_echo Committing changes to base; else Q=-q; fi
    qemu-img commit $Q $VM_SNAPSHOT_BACKING_FILENAME || vm_die qemu-img commit failed

    if [ "$VERBOSE" = "1" ]; then vm_echo Creating new backing file; fi
    qemu-img create $Q -f $VM_FMT -b $VM_SNAPSHOT_BASE_FILENAME -F $VM_FMT $VM_SNAPSHOT_BACKING_FILENAME

    if [ "$VERBOSE" = "1" ]; then vm_echo Securing base file \'$VM_SNAPSHOT_BASE_FILENAME\'; fi
    pv $Q $VM_SNAPSHOT_BASE_FILENAME > $VM_ARCHIVE/$VM_SNAPSHOT_BASE_FILENAME
    if [ "$COMPRESS" = "1" ]; then $COMPRESSOR $V $VM_ARCHIVE/$VM_SNAPSHOT_BASE_FILENAME; fi

    save_backing
else
    test -d $VM_ARCHIVE || vm_die archive directory \'$VM_ARCHIVE\' not found, use --create
    test -f $VM_SNAPSHOT_BACKING_FILENAME || vm_die backing file \'$VM_SNAPSHOT_BACKING_FILENAME\' not found

    vm_check_running || vm_die virtual machine not running

    if [ "$VERBOSE" = "1" ]; then vm_echo Stopping virtual machine; fi
    vm cmd stop

    if [ "$VERBOSE" = "1" ]; then vm_echo Saving snapshot \'$VM\' ; fi
    vm cmd savevm $VM

    save_backing

    if [ "$VERBOSE" = "1" ]; then vm_echo re-starting virtual machine; fi
    vm cmd cont
fi
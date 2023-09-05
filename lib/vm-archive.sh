test -z "$VM_USE_SNAPSHOTS" && vm_die snapshots not enabled
test -f $VM_SNAPSHOT_BASE_FILENAME || vm_die base file \'$VM_SNAPSHOT_BASE_FILENAME\' not found

function save_backing()
{
    TSTAMP=`date -r $VM_SNAPSHOT_BACKING_FILENAME "+%Y%m%d%H%M%S"`
    TARGET=$VM_ARCHIVE/$VM_MACHINE_NAME-$VM_SNAPSHOT_BACKINGNAME-$TSTAMP.$VM_FMT

    if [ "$VERBOSE" = "1" ]; then vm_echo Saving backing file \'$VM_SNAPSHOT_BACKING_FILENAME\'; else Q=-q; fi
    pv $Q $VM_SNAPSHOT_BACKING_FILENAME > $TARGET
}

function compress_backing()
{
    TSTAMP=`date -r $VM_SNAPSHOT_BACKING_FILENAME "+%Y%m%d%H%M%S"`
    TARGET=$VM_ARCHIVE/$VM_MACHINE_NAME-$VM_SNAPSHOT_BACKINGNAME-$TSTAMP.$VM_FMT

    if [ "$COMPRESS" = "1" ]; then
        if [ "$VERBOSE" = "1" ]; then vm_echo Compressing archived file using $COMPRESSOR; V=-v; fi
        $COMPRESSOR -f $V $TARGET;
    fi
}

VM_ARCHIVE=$VM_MACHINE_NAME-`date -r $VM_SNAPSHOT_BASE_FILENAME "+%Y%m%d%H%M%S"`

if [ "$CREATE" = "1" ]; then
    vm_check_prog pv
    vm_die_if_error

    vm_check_running && vm_die virtual machine is running

    if [ "$VERBOSE" = "1" ]; then vm_echo Creating archive directory \'$VM_ARCHIVE\'; V=-v; else Q=-q; fi
    mkdir -p $VM_ARCHIVE

    if [ "$VM" != "" ]; then
        if [ "$VERBOSE" = "1" ]; then vm_echo Deleting snapshot \'$VM\'; fi
        qemu-img snapshot $Q -d $VM $VM_SNAPSHOT_BACKING_FILENAME
    fi

    if [ "$VERBOSE" = "1" ]; then vm_echo Committing changes to base; else Q=-q; fi
    qemu-img commit $Q $VM_SNAPSHOT_BACKING_FILENAME || vm_die qemu-img commit failed

    VM_ARCHIVE=$VM_MACHINE_NAME-`date -r $VM_SNAPSHOT_BASE_FILENAME "+%Y%m%d%H%M%S"`

    if [ "$VERBOSE" = "1" ]; then vm_echo Creating new backing file; fi
    qemu-img create $Q -f $VM_FMT -b $VM_SNAPSHOT_BASE_FILENAME -F $VM_FMT $VM_SNAPSHOT_BACKING_FILENAME

    if [ "$VERBOSE" = "1" ]; then vm_echo Securing base file \'$VM_SNAPSHOT_BASE_FILENAME\'; fi
    pv $Q $VM_SNAPSHOT_BASE_FILENAME > $VM_ARCHIVE/$VM_SNAPSHOT_BASE_FILENAME
    if [ "$COMPRESS" = "1" ]; then $COMPRESSOR $V $VM_ARCHIVE/$VM_SNAPSHOT_BASE_FILENAME; fi

    save_backing
    compress_backing
else
    test -d $VM_ARCHIVE || vm_die archive directory \'$VM_ARCHIVE\' not found, use --create
    test -f $VM_SNAPSHOT_BACKING_FILENAME || vm_die backing file \'$VM_SNAPSHOT_BACKING_FILENAME\' not found

    vm_check_running || vm_die virtual machine not running

    if [ "$VERBOSE" = "1" ]; then vm_echo Stopping virtual machine; fi
    vm cmd stop

    if [ "$VM" != "" ]; then
        if [ "$VERBOSE" = "1" ]; then vm_echo Saving snapshot \'$VM\' ; fi
        vm cmd savevm $VM
        sleep 5
    fi

    save_backing

    if [ "$VERBOSE" = "1" ]; then vm_echo re-starting virtual machine; fi
    vm cmd cont

    compress_backing
fi

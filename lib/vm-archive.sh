test -z "$VM_USE_SNAPSHOTS" && vm_die snapshots not enabled
test -f $VM_SNAPSHOT_BASE_FILENAME || vm_die base file \'$VM_SNAPSHOT_BASE_FILENAME\' not found

function save_backing()
{
    TSTAMP=`date -r $VM_SNAPSHOT_BACKING_FILENAME "+%Y%m%d%H%M%S"`
    TARGET=$VM_ARCHIVE/$VM_MACHINE_NAME-$VM_SNAPSHOT_BACKINGNAME-$TSTAMP.$VM_FMT

    vm_echo_if_verbose Saving backing file \'$VM_SNAPSHOT_BACKING_FILENAME\'
    if [ "$VERBOSE" = "0" ]; then Q=-q; fi
    pv $Q $VM_SNAPSHOT_BACKING_FILENAME > $TARGET
}

function compress_backing()
{
    TSTAMP=`date -r $VM_SNAPSHOT_BACKING_FILENAME "+%Y%m%d%H%M%S"`
    TARGET=$VM_ARCHIVE/$VM_MACHINE_NAME-$VM_SNAPSHOT_BACKINGNAME-$TSTAMP.$VM_FMT

    if [ "$COMPRESS" = "1" ]; then
        vm_echo_if_verbose Compressing archived file using $COMPRESSOR
        if [ "$VERBOSE" = "1" ]; then V=-v; fi
        $COMPRESSOR -f $V $TARGET;
    fi
}

VM_ARCHIVE=$VM_MACHINE_NAME-`date -r $VM_SNAPSHOT_BASE_FILENAME "+%Y%m%d%H%M%S"`

if [ "$CREATE" = "1" ]; then
    vm_check_prog pv
    vm_die_if_error

    vm_check_running && vm_die virtual machine is running

    vm_echo_if_verbose Creating archive directory \'$VM_ARCHIVE\'
    mkdir -p $VM_ARCHIVE 2> /dev/null || vm_die creating archive directory \'$VM_ARCHIVE\' failed

    if [ "$VERBOSE" = "1" ]; then V=-v; else Q=-q; fi

    if [ "$VM" != "" ]; then
        vm_echo_if_verbose Deleting snapshot \'$VM\'
        qemu-img snapshot $Q -d $VM $VM_SNAPSHOT_BACKING_FILENAME
    fi

    vm_echo_if_verbose Committing changes to base
    qemu-img commit $Q $VM_SNAPSHOT_BACKING_FILENAME || vm_die qemu-img commit failed

    VM_ARCHIVE=$VM_MACHINE_NAME-`date -r $VM_SNAPSHOT_BASE_FILENAME "+%Y%m%d%H%M%S"`

    vm_echo_if_verbose Creating new backing file
    qemu-img create $Q -f $VM_FMT -b $VM_SNAPSHOT_BASE_FILENAME -F $VM_FMT $VM_SNAPSHOT_BACKING_FILENAME

    vm_echo_if_verbose Saving base file \'$VM_SNAPSHOT_BASE_FILENAME\'
    pv $Q $VM_SNAPSHOT_BASE_FILENAME > $VM_ARCHIVE/$VM_SNAPSHOT_BASE_FILENAME
    if [ "$COMPRESS" = "1" ]; then $COMPRESSOR $V $VM_ARCHIVE/$VM_SNAPSHOT_BASE_FILENAME; fi

    save_backing
    compress_backing
else
    test -d $VM_ARCHIVE || vm_die archive directory \'$VM_ARCHIVE\' not found, use --create
    test -f $VM_SNAPSHOT_BACKING_FILENAME || vm_die backing file \'$VM_SNAPSHOT_BACKING_FILENAME\' not found
    vm_check_running || vm_die virtual machine not running

    vm_echo_if_verbose Using archive directory \'$VM_ARCHIVE\'

    vm_echo_if_verbose Stopping virtual machine
    vm cmd stop

    if [ "$VM" != "" ]; then
        vm_echo_if_verbose Saving snapshot \'$VM\'
        vm cmd savevm $VM
        sleep 5
    fi

    save_backing

    vm_echo_if_verbose Resuming virtual machine
    vm cmd cont

    compress_backing
fi

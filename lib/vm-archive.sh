test "$VM_USE_SNAPSHOTS" = "no" && vm_die snapshots not enabled
test -f $VM_SNAPSHOT_BASE_FILENAME || vm_die base file \'$VM_SNAPSHOT_BASE_FILENAME\' not found

function save_backing()
{
    TSTAMP=`date -r $VM_SNAPSHOT_BACKING_FILENAME "+%Y%m%d%H%M%S"`
    TARGET=$VM_ARCHIVE/$VM_MACHINE_NAME-$VM_SNAPSHOT_BACKINGNAME-$TSTAMP.$VM_FMT

    vm_echo_if_verbose Saving backing file \'$VM_SNAPSHOT_BACKING_FILENAME\'
    if [ "$VERBOSE" = "0" ]; then Q=-q; fi
    pv $Q $VM_SNAPSHOT_BACKING_FILENAME > $TARGET

    if [ "$DELVM" != "" ]; then
        vm_echo_if_verbose Deleting snapshot \'$DELVM\' from \'$TARGET\'
        RES=`qemu-img snapshot $Q -d $DELVM $TARGET 2>&1`
        vm_echo_if_verbose $RES
    fi
}

function compress_backing()
{
    TSTAMP=`date -r $VM_SNAPSHOT_BACKING_FILENAME "+%Y%m%d%H%M%S"`
    TARGET=$VM_ARCHIVE/$VM_MACHINE_NAME-$VM_SNAPSHOT_BACKINGNAME-$TSTAMP.$VM_FMT

    if [ "$COMPRESSOR" != "" ]; then
        vm_echo_if_verbose Compressing archived backing file using $COMPRESSOR
        if [ "$VERBOSE" = "1" ]; then V=-v; fi
        $COMPRESSOR -f $V $TARGET;
    fi
}

if [ "$COMPRESSOR" = "lz4" ]; then COMPRESSOR="$COMPRESSOR --rm"; fi

if [ "$CREATE" = "1" ]; then
    vm_check_prog pv
    vm_die_if_error

    vm_check_running && vm_die virtual machine is running

    if [ "$VERBOSE" = "1" ]; then V=-v; else Q=-q; fi

    vm_echo_if_verbose Committing changes from \'$VM_SNAPSHOT_BACKING_FILENAME\'
    RES=`qemu-img commit $Q $VM_SNAPSHOT_BACKING_FILENAME` || vm_die qemu-img commit failed
    vm_echo_if_verbose $RES

    VM_ARCHIVE=$VM_MACHINE_NAME-`date -r $VM_SNAPSHOT_BASE_FILENAME "+%Y%m%d%H%M%S"`

    test -d $VM_ARCHIVE && vm_die Archive directory already exists, not overwriting

    vm_echo_if_verbose Creating archive directory \'$VM_ARCHIVE\'
    mkdir -p $VM_ARCHIVE 2> /dev/null || vm_die creating archive directory \'$VM_ARCHIVE\' failed

    vm_echo_if_verbose Saving base file \'$VM_SNAPSHOT_BASE_FILENAME\'
    pv $Q $VM_SNAPSHOT_BASE_FILENAME > $VM_ARCHIVE/$VM_SNAPSHOT_BASE_FILENAME || vm_die pv returned status $?

    if [ "$COMPRESSOR" != "" -a "$CMPBASE" = "1" ]; then
        vm_echo_if_verbose Compressing archived base file using $COMPRESSOR
        $COMPRESSOR $V $VM_ARCHIVE/$VM_SNAPSHOT_BASE_FILENAME;
    fi

    vm_echo_if_verbose Creating new backing file
    RES=`qemu-img create $Q -f $VM_FMT -b $VM_SNAPSHOT_BASE_FILENAME -F $VM_FMT $VM_SNAPSHOT_BACKING_FILENAME` || vm_die qemu-img create failed
    vm_echo_if_verbose $RES

    save_backing
    compress_backing
else
    VM_ARCHIVE=$VM_MACHINE_NAME-`date -r $VM_SNAPSHOT_BASE_FILENAME "+%Y%m%d%H%M%S"`

    test -d $VM_ARCHIVE || vm_die archive directory \'$VM_ARCHIVE\' not found, use --create
    test -f $VM_SNAPSHOT_BACKING_FILENAME || vm_die backing file \'$VM_SNAPSHOT_BACKING_FILENAME\' not found
    vm_check_running || vm_die virtual machine not running

    vm_echo_if_verbose Using archive directory \'$VM_ARCHIVE\'

    vm_echo_if_verbose Syncing filesystem on \'$VM_MACHINE_NAME\'
    vm_sync

    vm_echo_if_verbose Stopping virtual machine
    vm cmd stop

    if [ "$SAVEVM" != "" ]; then
        vm_echo_if_verbose Saving snapshot \'$SAVEVM\'
        vm cmd savevm $SAVEVM
        sleep 5
    fi

    save_backing
    vm_echo_if_verbose Resuming virtual machine
    vm cmd cont

    compress_backing
fi

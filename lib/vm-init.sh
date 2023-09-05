. $VM_LIB/init.sh

vm_check_var VM_MACHINE_NAME

if [ "$VM_USE_SNAPSHOTS" != "yes" ]; then vm_die snapshots not configured; fi

vm_check_var VM_SNAPSHOT_SEED_FILENAME
vm_check_var VM_SNAPSHOT_BASE_FILENAME
vm_check_var VM_SNAPSHOT_BACKING_FILENAME

vm_check_prog pv
vm_check_prog qemu-img
vm_die_if_error

if [ -f "$VM_SNAPSHOT_BASE_FILENAME" -a "$OK" = "1"  ]; then CLOBBER_BACKING=yes; fi
if [ -f "$VM_SNAPSHOT_BASE_FILENAME" -a ! -f "$VM_SNAPSHOT_BACKING_FILENAME"  ]; then CLOBBER_BACKING=yes; fi

if [ -f "$VM_SNAPSHOT_BASE_FILENAME" -a "$OB" != "1" -a "$CLOBBER_BACKING" != "yes" ]; then \
    vm_die base file \'$VM_SNAPSHOT_BASE_FILENAME\' exists, use -b to overwrite, -k \
    to create new backing file only; fi

if [ ! -f "$VM_SNAPSHOT_BASE_FILENAME" -a -f "$VM_SNAPSHOT_BACKING_FILENAME" -a "$OK" != "1" ]; then \
    vm_die orphaned backing file \'$VM_SNAPSHOT_BACKING_FILENAME\' found, use -k to overwrite; fi

if [ "$CLOBBER_BACKING" = "yes" -a "$OB" != "1" ]
then
    if [ "$OK" != "1" ]; then vm_echo Base file \'$VM_SNAPSHOT_BASE_FILENAME\' already exists; fi
else
    if [ ! -f "$VM_SNAPSHOT_SEED_FILENAME" ]; then vm_die seed file \'$VM_SNAPSHOT_SEED_FILENAME\' not found; fi
    vm_echo Checking if base file \'$VM_SNAPSHOT_BASE_FILENAME\' is writable
    CMD="touch $VM_SNAPSHOT_BASE_FILENAME"
    if [ "$VERBOSE" = "1" ]; then vm_echo Running \'$CMD\'; fi
    if [ -z $DRYRUN ]; then ERR="`$CMD 2>&1`" || vm_die "$ERR"; else vm_echo Testing only, not running command; fi

    vm_echo Creating base file \'$VM_SNAPSHOT_BASE_FILENAME\'
    CMD="pv $VM_SNAPSHOT_SEED_FILENAME > $VM_SNAPSHOT_BASE_FILENAME"
    if [ "$VERBOSE" = "1" ]; then vm_echo Running \'$CMD\'; fi

    if [ -z $DRYRUN ]; then
        echo "$CMD" | sh
        test $? -gt 0 && vm_die Error copying \'$VM_SNAPSHOT_SEED_FILENAME\' to \'$VM_SNAPSHOT_BASE_FILENAME\'
    else
        vm_echo Testing only, not running command
    fi
fi

vm_echo Creating backing file \'$VM_SNAPSHOT_BACKING_FILENAME\'
CMD="qemu-img create -f $VM_FMT -b $VM_SNAPSHOT_BASE_FILENAME -F $VM_FMT $VM_SNAPSHOT_BACKING_FILENAME"
if [ "$VERBOSE" = "1" ]; then vm_echo Running \'$CMD\'; fi
if [ -z $DRYRUN ]; then ERR="`echo $CMD '|| exit 1' | sh 2>&1`" || vm_die "$ERR"; else vm_echo Testing only, not running command; fi

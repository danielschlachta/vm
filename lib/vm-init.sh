#!/bin/bash

. $VM_LIB/init.sh

vm_check_var VM_MACHINE_NAME

if [ "$VM_USE_SNAPSHOTS" != "yes" ]; then vm_die snapshots not configured; fi

vm_check_var VM_SNAPSHOT_SEED_FILENAME
vm_check_var VM_SNAPSHOT_BASE_FILENAME
vm_check_var VM_SNAPSHOT_BACKING_FILENAME

vm_check_prog pv
vm_check_prog qemu-img
vm_die_if_error

if [ ! -z $VM_LIST_PKG ]; then exit; fi

VERBOSE=0

for i in 1 2 3 5; do
    if [ "$1" = "-t" ]; then DRYRUN=1; shift; fi
    if [ "$1" = "-ob" ]; then OB=1; shift; fi
    if [ "$1" = "-ok" ]; then OK=1; shift; fi
    if [ "$1" = "-v" ]; then VERBOSE=$(($VERBOSE + 1)); shift; fi
done

if [ ! -f "$VM_SNAPSHOT_SEED_FILENAME" ]; then vm_die seed file \'$VM_SNAPSHOT_SEED_FILENAME\' not found; fi

if [ -f "$VM_SNAPSHOT_BASE_FILENAME" -a "$OK" = "1"  ]; then CLOBBER_BACKING=yes; fi
if [ -f "$VM_SNAPSHOT_BASE_FILENAME" -a ! -f "$VM_SNAPSHOT_BACKING_FILENAME"  ]; then CLOBBER_BACKING=yes; fi

if [ -f "$VM_SNAPSHOT_BASE_FILENAME" -a "$OB" != "1" -a "$CLOBBER_BACKING" != "yes" ]; then \
    vm_die base file \'$VM_SNAPSHOT_BASE_FILENAME\' exists, use -ob to overwrite, -ok \
    to create new backing file only; fi

if [ ! -f "$VM_SNAPSHOT_BASE_FILENAME" -a -f "$VM_SNAPSHOT_BACKING_FILENAME" -a "$OK" != "1" ]; then \
    vm_die orphaned backing file \'$VM_SNAPSHOT_BACKING_FILENAME\' found, use -ok to overwrite; fi

if [ "$CLOBBER_BACKING" = "yes" -a "$OB" != "1" ]
then
    if [ "$OK" != "1" ]; then vm_echo Base file \'$VM_SNAPSHOT_BASE_FILENAME\' already exists; fi
else
    vm_echo Checking if base file \'$VM_SNAPSHOT_BASE_FILENAME\' is writable
    CMD="touch $VM_SNAPSHOT_BASE_FILENAME"
    if [ $VERBOSE -gt 1 ]; then vm_echo $CMD; fi
    if [ -z $DRYRUN ]; then ERR="`$CMD 2>&1`" || (vm_error "$ERR"; exit 1) || exit 1; else vm_echo Testing only, not running command; fi

    vm_echo Creating base file \'$VM_SNAPSHOT_BASE_FILENAME\'
    CMD="pv $VM_SNAPSHOT_SEED_FILENAME > $VM_SNAPSHOT_BASE_FILENAME"
    if [ $VERBOSE -gt 1 ]; then vm_echo $CMD; fi
    if [ -z $DRYRUN ]; then ERR="`bash -c $CMD | sh 2>&1`" || (vm_error "$ERR"; exit 1); else vm_echo Testing only, not running command; fi
fi

vm_echo Creating backing file \'$VM_SNAPSHOT_BACKING_FILENAME\'
CMD="qemu-img create -f $VM_FMT -b $VM_SNAPSHOT_BASE_FILENAME -F $VM_FMT $VM_SNAPSHOT_BACKING_FILENAME"
if [ $VERBOSE -gt 1 ]; then vm_echo $CMD; fi
if [ -z $DRYRUN ]; then ERR="`echo $CMD '|| exit 1' | sh 2>&1`" || (vm_error "$ERR"; exit 1); else vm_echo Testing only, not running command; fi

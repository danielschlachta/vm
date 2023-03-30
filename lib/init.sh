PROG=`basename $0`

VM_GLOBAL_CONFIG=$VM_LIB/vmrc
VERBOSE=0

if [ ! -f $VM_GLOBAL_CONFIG ]; then vm_die configuration file \'$VM_GLOBAL_CONFIG\' not present; fi

. $VM_GLOBAL_CONFIG
. $VM_LIB/functions.sh

VM_HOME_ORIGIN="$VM_HOME"

if [ "$VM_HOME" = "" ]
then
    VM_HOME=`pwd`
else
    VM_HOME="`echo $VM_HOME | sed 's,/$,,'`"

    if [ -f $VM_CONFIG -a "$VM_HOME" != "`pwd`" -a "$VM_HOME_OVERRIDES_CWD" != "yes" ]; then \
        vm_die configuration file \($VM_CONFIG\) found \
            in current directory but VM_HOME points someplace \
            else \(to suppress this check, set VM_HOME_OVERRIDES_CWD \
            to \'yes\'\); fi
fi

VM_CALLING_DIR=`pwd`

RES=`cd "$VM_HOME" 2>&1 | sed 's,.* cd: ,,'; cd "$VM_HOME" 2> /dev/null` || \
    vm_die could not cd to \$VM_HOME: $RES

cd "$VM_HOME"

if [ ! -f $VM_CONFIG ]; then vm_die configuration file \'$VM_CONFIG\' not present in \'$VM_HOME\'; fi

. $VM_CONFIG

if [ "$VM_NET_LISTEN" = "" ]; then VM_NET_LISTEN=0.0.0.0; fi
if [ "$VM_NET_HOST" = "" ]; then VM_NET_HOST=localhost; fi
if [ "$VM_NET_PORT" = "" ]; then VM_NET_PORT=77${VM_MACHINE_ID}; fi

if [ "$VM_USE_SNAPSHOTS" = "yes" ]
then
    if [ "$VM_SNAPSHOT_SEEDNAME" = "" ]; then VM_SNAPSHOT_SEEDNAME=$VM_SNAPSHOT_SEEDNAME_DEFAULT; fi
    if [ "$VM_SNAPSHOT_BASENAME" = "" ]; then VM_SNAPSHOT_BASENAME=$VM_SNAPSHOT_BASENAME_DEFAULT; fi
    if [ "$VM_SNAPSHOT_BACKINGNAME" = "" ]; then VM_SNAPSHOT_BACKINGNAME=$VM_SNAPSHOT_BACKINGNAME_DEFAULT; fi

    VM_SNAPSHOT_SEED_FILENAME=$VM_MACHINE_NAME-$VM_SNAPSHOT_SEEDNAME.$VM_FMT
    VM_SNAPSHOT_BASE_FILENAME=$VM_MACHINE_NAME-$VM_SNAPSHOT_BASENAME.$VM_FMT
    VM_SNAPSHOT_BACKING_FILENAME=$VM_MACHINE_NAME-$VM_SNAPSHOT_BACKINGNAME.$VM_FMT
fi

vm_check_var VM_CONFIG
vm_check_var VM_FMT
vm_check_var VM_MACHINE_NAME
vm_check_var VM_MACHINE_ID

. $VM_LIB/spinner.sh

PROG=`basename $0`

function vm_die()
{
        echo $PROG: $* 1>&2
        exit 1
}

GLOBCONF=$VM_LIB/vmrc
VERBOSE=0

if [ ! -f $GLOBCONF ]; then vm_die configuration file \'$GLOBCONF\' not present; fi
. $GLOBCONF

if [ "$VM_HOME" = "" ]; then VM_HOME=`pwd`; fi

VM_CALLING_DIR=`pwd`

RES=`cd "$VM_HOME" 2>&1 | sed 's,.* cd: ,,'; cd "$VM_HOME" 2> /dev/null` || vm_die could not cd to \$VM_HOME: $RES

cd "$VM_HOME"

if [ ! -f $CONFFILE ]; then vm_die configuration file \'$CONFFILE\' not present in \'$VM_HOME\'; fi
. $CONFFILE

if [ "$NET_LISTEN" = "" ]; then NET_LISTEN=0.0.0.0; fi
if [ "$NET_HOST" = "" ]; then NET_HOST=localhost; fi
if [ "$NET_PORT" = "" ]; then NET_PORT=${MACHINE_ID}11; fi

if [ "$USE_SNAPSHOTS" = "yes" -a "$SNAPSHOT_SEEDNAME" = "" ]; then SNAPSHOT_SEEDNAME=$SNAPSHOT_SEEDNAME_DEFAULT; fi
if [ "$USE_SNAPSHOTS" = "yes" -a "$SNAPSHOT_BASENAME" = "" ]; then SNAPSHOT_BASENAME=$SNAPSHOT_BASENAME_DEFAULT; fi
if [ "$USE_SNAPSHOTS" = "yes" -a "$SNAPSHOT_BACKINGNAME" = "" ]; then SNAPSHOT_BACKINGNAME=$SNAPSHOT_BACKINGNAME_DEFAULT; fi

if [ "$USE_SNAPSHOTS" = "yes" ]
then
    SEED_FILENAME=$MACHINE_NAME-$SNAPSHOT_SEEDNAME.$FMT
    BASE_FILENAME=$MACHINE_NAME-$SNAPSHOT_BASENAME.$FMT
    BACKING_FILENAME=$MACHINE_NAME-$SNAPSHOT_BACKINGNAME.$FMT
fi

. $VM_LIB/functions.sh

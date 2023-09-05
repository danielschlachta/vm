VM_ERRCNT=0

function vm_squeal()
{
    VM_ERRCNT=$(($VM_ERRCNT + 1))
    echo "vm: $*" 1>&2
}

function vm_die_if_error()
{
    if [ $VM_ERRCNT -gt 0 ]
    then
        if [ $VM_ERRCNT -gt 1 ]; then s=s; fi
        echo vm: exiting after $VM_ERRCNT error$s 1>&2
        exit 1
    fi
}

function vm_get_timestamp()
{
    if [ "$VM_DATEFMT" = "" ]; then date; else date +"$VM_DATEFMT"; fi
}

function vm_progress()
{
    if [ "$VERBOSE" = "1" -a -t 1 ]; then
        if [ "$SPINNER_RUNNING" -lt "1" ]; then
            export SPINNER_DONEFILE=`mktemp -u /tmp/vm.XXXXXXXXX`
            spinner &
            SPINNER_RUNNING=1
        fi

        tput el
        echo -en "  " $* "\r"
    fi
}

function vm_progress_stop()
{
    if [ "$SPINNER_RUNNING" = "1" -a "$SPINNER_DONEFILE" != "" ]; then
        touch $SPINNER_DONEFILE
        SPINNER_RUNNING=0
        sleep 0.3
    fi
}

function vm_die()
{
    vm_progress_stop
    echo $PROG: $* 1>&2
    if [ "$VM_ERRLOG" != "" ]; then echo \[`vm_get_timestamp` $VM_CMD\] $* >> "$VM_ERRLOG" 2> /dev/null; fi
    exit 1
}

function vm_echo()
{
    vm_progress_stop
    echo \[`vm_get_timestamp`\] $*
}

function vm_echo_if_verbose()
{
    vm_progress_stop
    if [ "$VERBOSE" = "1" ]; then vm_echo $*; fi
    if [ "$VM_LOG" != "" ]; then vm_echo $* >> "$VM_LOG" 2> /dev/null; fi
}

function vm_check_root() {
    if [ "$USER" != "root" ]
    then
        vm_die this command needs root privileges
    fi
}

function vm_check_var()
{
    if [[ ! -v $1 ]]
    then
        vm_die $VM_CONFIG: "mandatory variable $1 not set"
    fi
}

function vm_check_prog()
{
    PRG=`which $1`
    if [ -z "$PRG" -o ! -z $VM_LIST_PKG ]
    then
        if [ -z "$PRG" ]
        then
            PKG=not-yet-known
            MSG="program '$1' not found"
            test -x /usr/lib/command-not-found && \
                MSG="$MSG (`/usr/lib/command-not-found $1 2>&1 | tail -n 1`)"
            vm_squeal "$MSG"
        else
            test -d /var/lib/apt && echo $1 `dpkg -S $PRG | cut -f1 -d:`
        fi
    fi
}

function vm_check_running()
{
    QPID=`ps ax|grep 77$VM_MACHINE_ID| awk '/qemu/ { print $1 }'`
    test -z "$QPID" || return 0
    return 1
}

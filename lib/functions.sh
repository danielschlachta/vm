VM_ERRCNT=0

function vm_squeal()
{
    VM_ERRCNT=$(($VM_ERRCNT + 1))
    echo "$*" 1>&2
}

function vm_die_if_error()
{
    if [ $VM_ERRCNT -gt 0 ]
    then
        if [ $VM_ERRCNT -gt 1 ]; then s=s; fi
        echo exiting after $VM_ERRCNT error$s 1>&2
        exit 1
    fi
}

function vm_get_timestamp()
{
    if [ "$VM_DATEFMT" = "" ]; then date; else date +"$VM_DATEFMT"; fi
}

function vm_echo ()
{
    echo \[`vm_get_timestamp`\] $*
}

function vm_error()
{
    vm_echo $* 1>&2
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
            vm_squeal "$1 not found, install it using 'sudo apt install $PKG'"
        else
            test -d /var/lib/apt && echo $1 `dpkg -S $PRG | cut -f1 -d:`
        fi
    fi
}

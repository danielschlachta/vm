function vm_get_timestamp()
{
    echo [`date`]
}

function vm_echo ()
{
    echo `vm_get_timestamp` $*
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
    if [ "`echo . $CONFFILE\; echo \\$$1 | bash`" = "" ]
    then
        vm_die $CONFFILE: "mandatory variable $1 not set"
    fi
}

function vm_get_hd()
{
    vm_check_var MACHINE_NAME

    echo $1

    if [ "$USE_SNAPSHOTS" = "yes" ]
    then
        if [ -f $BACKINGFILENAME ]
        then
            echo $BACKINGFILENAME
        else
            if [ $# ]; then vm_add_msg no backing file found, using base;  fi
            echo $BASEFILENAME
        fi
    else
        echo $MACHINE_NAME.$FMT
    fi
}

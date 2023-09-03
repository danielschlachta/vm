vm_check_prog nslookup
vm_check_prog ping
vm_check_prog ssh
vm_die_if_error

function vm_get_ip()
{
    ping -c 1 $VM_NET_HOST 2> /dev/null | head -n 1 | cut -d'(' -f 2 | cut -d ')' -f 1
}

function vm_get_full_name()
{
    FQ=`nslookup $1| awk '/name = / { print $4 }' | sed 's,.$,,'`

    test -z $FQ && FQ=''

    echo $FQ
}

function vm_ping()
{
    ping -c 1 $VM_NET_HOST | tail -n 1 | cut -c24-
}

function vm_get_status()
{
    vm cmd info status 2> /dev/null | sed -e 's,VM status: ,,' -e 's,..$,,'
}

SSH="ssh -o ServerAliveInterval=2 -o StrictHostKeyChecking=no -o PasswordAuthentication=no $VM_MACHINE_OWNER@$VM_NET_GUEST"

function vm_check_ssh()
{
    $SSH  echo ok 2>&1 | sed 's,ssh: ,,'
}

function vm_get_suspend_method()
{
    SCT=`$SSH which systemctl 2> /dev/null`

    if [ "$SCT" = "" ]; then
        ZZZ=`$SSH which zzz 2> /dev/null`

        if [ "$ZZZ" != "" ]; then
            echo $ZZZ
        fi
    else
        echo $SCT suspend
    fi
}

function vm_suspend()
{
    SPM=`vm_get_suspend_method`

    if [ "$SPM" != "" ]; then $SSH sudo -n $SPM > /dev/null 2> /dev/null; fi
}

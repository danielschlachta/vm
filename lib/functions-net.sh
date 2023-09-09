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
    FQ=`nslookup $1| awk '/name = / { print $4 }' | sed 's,\r$,,'`

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


OH="`eval echo ~$VM_MACHINE_OWNER`"

OU=$VM_MACHINE_OWNER

if [ "$VM_MACHINE_USER" != "" ]; then OU=$VM_MACHINE_USER; fi

SSH="ssh -o User=$OU -o IdentityFile=$OH/.ssh/id_rsa -o ServerAliveInterval=2 -o StrictHostKeyChecking=no -o PasswordAuthentication=no $VM_NET_GUEST"

function vm_check_ssh()
{
    $SSH echo ok 2>&1 | sed 's,ssh: ,,'
}

function vm_get_control_method()
{
    SCT=`$SSH which systemctl 2> /dev/null`

    test -z $SCT && SCT=`$SSH which loginctl 2> /dev/null`
    test -z $SCT && exit
    
    echo $SCT
}

function vm_ssh()
{
    $SSH $* 2>&1
}
    
function vm_sudo()
{     
    vm_ssh sudo -n $*
}

function vm_sync()
{
    $SSH sync
}


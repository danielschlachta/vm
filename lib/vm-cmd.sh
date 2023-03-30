#!/bin/bash

. $VM_LIB/init.sh

vm_check_var VM_NET_HOST
vm_check_var VM_NET_PORT

if [ $# -lt 1 ]; then vm_die too few arguments; fi

function do_expect()
{
expect <<-END
    set timeout 2
    spawn nc $VM_NET_HOST $VM_NET_PORT
    expect {
        eof {}
        "qemu) " {
            send "$*\n"
            expect "qemu)" { send_user "$expect_out" }
        }
    }
END
}

function filter()
{
    sed 's,\r\n,\n,g' | tail -n +4 | head -n -1
}

function send_cmd()
{
    do_expect $* | filter else
}


if [ "$*" = "q" -o "$*" = "quit" ]
then
    vm cmd info status > /dev/null && echo q | nc $VM_NET_HOST $VM_NET_PORT 2>&1 > /dev/null
else
    send_cmd $* | (
    read dummy

    if [ "$dummy" = "" ]
    then
        vm_die could not connect to host $VM_NET_HOST port $VM_NET_PORT
    fi

    while read RESP; do echo $RESP; done
    )
fi

. $VM_LIB/init.sh

vm_check_var VM_NET_HOST
vm_check_var VM_NET_PORT

vm_check_prog expect
vm_die_if_error

if [ $# -lt 1 ]; then vm_usage; exit 1; fi

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
    do_expect $* | filter
}

send_cmd $* | (
read dummy
while read RESP; do echo $RESP; done
)

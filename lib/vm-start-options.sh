VM_LONGOPTS=nat,loadvm:,ssh-attempts
VM_OPTIONS=n,l:,s:

function vm_help()
{
       cat <<EOT
  -n | --use-nat          do not attempt to create a bridge interface
  -s | --ssh-attempts     try <n> times before giving up on ssh connection
  -l | --loadvm           load named snapshot
EOT
}

. $VM_LIB/options.sh

vm_check_var VM_SSH_ATTEMPTS
vm_die_if_error

NAT=0
NOSSH=0
SSH_ATT=$VM_SSH_ATTEMPTS

while true; do
    case "$1" in
      --)
            shift
            break
            ;;
      -n|--use-nat)
            NAT=1
            shift
            ;;
      -l|--loadvm)
            LOADVM="$2"
            shift 2
            ;;
      -s|--ssh-attempts)
            SSH_ATT="$2"
            shift 2
            ;;
        *)
            shift
            ;;
    esac
done



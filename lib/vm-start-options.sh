VM_LONGOPTS=nat,loadvm:
VM_OPTIONS=n,l:

function vm_help()
{
       cat <<EOT
  -n | --use-nat          do not attempt to create a bridge interface
  -l | --loadvm           load named snapshot
EOT
}

. $VM_LIB/options.sh

NAT=0

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
        *)
            shift
            ;;
    esac
done



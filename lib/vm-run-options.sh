VM_LONGOPTS=use-nat,base-only,loadvm:
VM_OPTIONS=nbl:

function vm_help()
{
    cat <<EOT
  -n | --use-nat          do not attempt to create a bridge interface
  -b | --base-only        when snapshots are enabled, do not use any backing file
  -l | --loadvm           load named snapshot
EOT
}

. $VM_LIB/options.sh

NAT=0
BASE=0
LOADVM=''

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
        -b|--base-only)
            BASE=1
            shift
            ;;
        -l|--loadvm)
            LOADVM="-loadvm $2"
            shift 2
            ;;
        *)
            shift
            ;;
    esac
done




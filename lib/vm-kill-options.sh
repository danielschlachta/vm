VM_LONGOPTS=
VM_OPTIONS=

function vm_help()
{
    return
}

. $VM_LIB/options.sh

POWEROFF=0
KILL=0

while true; do
    case "$1" in
        --)
            shift
            break
            ;;
        -s|--savevm)
            SAVEVM="$2"
            shift 2
            ;;
        -p|--poweroff)
            POWEROFF=1
            shift
            ;;
        *)
            shift
            ;;
    esac
done



VM_LONGOPTS=savevm:,no-suspend
VM_OPTIONS=s:r

function vm_help()
{
       cat <<EOT
  -s | --savevm           save named snapshot
  -r | --no-suspend       do not suspend the machine
EOT
}

. $VM_LIB/options.sh

POWEROFF=0
NOSUSPEND=0

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
        -r|--no-suspend)
            NOSUSPEND=1
            shift
            ;;
        *)
            shift
            ;;
    esac
done


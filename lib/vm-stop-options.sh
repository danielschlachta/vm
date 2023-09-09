VM_LONGOPTS=savevm:,no-suspend,poweroff
VM_OPTIONS=s:pr

function vm_help()
{
       cat <<EOT
  -s | --savevm           save named snapshot
  -p | --poweroff         power the machine off
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
        -p|--poweroff)
            POWEROFF=1
            shift
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


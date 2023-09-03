VM_LONGOPTS=savevm:,poweroff,kill
VM_OPTIONS=s:pk

function vm_help()
{
       cat <<EOT
  -s | --savevm           save named snapshot
  -p | --poweroff         power the machine down instead of suspending it
EOT
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



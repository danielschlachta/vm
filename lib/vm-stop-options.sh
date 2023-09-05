VM_LONGOPTS=savevm:,poweroff,no-suspend
VM_OPTIONS=s:pr

function vm_help()
{
       cat <<EOT
  -s | --savevm           save named snapshot
  -p | --poweroff         power the machine down instead of suspending it
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

if [ "$POWEROFF" = "1" -a "$NOSUSPEND" = "1" ]; then vm_die options --no-suspend and --poweroff are mutually exclusive; fi



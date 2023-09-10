VM_LONGOPTS=savevm:,poweroff,reboot,no-suspend
VM_OPTIONS=s:prn

function vm_help()
{
       cat <<EOT
  -s | --savevm           save the machine state
  -p | --poweroff         power the machine off, implies --no-suspend
  -r | --reboot           just reboot the machine, do not suspend or quit
  -n | --no-suspend       do not suspend the machine (but save the state and quit)
EOT
}

. $VM_LIB/options.sh

POWEROFF=0
REBOOT=0
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
            NOSUSPEND=1
            shift
            ;;
        -r|--reboot)
            REBOOT=1
            NOSUSPEND=1
            shift      
            ;;
        -n|--no-suspend)
            NOSUSPEND=1
            shift
            ;;
        *)
            shift
            ;;
    esac
done

if [ "$POWEROFF" = "1" -a "$REBOOT" = "1" ]; then vm_die --poweroff and --reboot are mutually exclusive; fi
if [ "$SAVEVM" != "" -a "$REBOOT" = "1" ]; then vm_die --restart are mutually exclusive; fi


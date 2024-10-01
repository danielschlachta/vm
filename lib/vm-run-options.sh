VM_LONGOPTS=bridge,nat,base-only,loadvm:
VM_OPTIONS=cnbl:

function vm_help()
{
    cat <<EOT
  -c | --bridge           try to create a bridge interface using mncli
  -n | --nat              use builtin nat
  -b | --base-only        do not use backing with snapshot files
  -l | --loadvm           load named memory snapshot
EOT
}

. $VM_LIB/options.sh

NAT=0
BASE=0
BRIDGE=0
LOADVM=''

while true; do
    case "$1" in
        --)
            shift
            break
            ;;
        -c|--bridge)
            BRIDGE=1
            shift
            ;;
        -n|--nat)
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

if [ "$BRIDGE" = "1" -a "$NAT" = "1" ]; then vm_die options --bridge and --nat are mutually exclusive; fi

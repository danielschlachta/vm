VM_LONGOPTS=quiet,no-ssh-fail
VM_OPTIONS=qs

function vm_help()
{
    cat <<EOT
  -q | --quiet            do not display anything
  -s | --no-ssh-fail      do not exit with error if ssh is not available
EOT
}

. $VM_LIB/options.sh

QUIET=0
NOSSH=0

while true; do
    case "$1" in
        --)
            shift
            break
            ;;
        -q|--quiet)
            QUIET=1
            shift
            ;;
        -s|--no-ssh-fail)
            NOSSH=1
            shift
            ;;
        *)
            shift
            ;;
    esac
done

if [ "$QUIET" = "1" -a "$VERBOSE" = "1" ]; then vm_die options --quiet and --verbose are mutually exclusive; fi



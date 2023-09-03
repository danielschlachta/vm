LONGOPTS=verbose
OPTIONS=v

. $VM_LIB/options.sh

VERBOSE=0

while true; do
    case "$1" in
        --)
            shift
            break
            ;;
        -v|--verbose)
            VERBOSE=1
            shift
            ;;
    esac
done




VM_LONGOPTS=create,compress:,saved-state:
VM_OPTIONS=cz:s:

function vm_help()
{
    cat <<EOT
  -c | --create           commit to base and create new backing file
  -z | --compress         use compressor, one of xz, gzip, bzip2, lz4
  -s | --saved-state      delete named snapshot before creating archive, save it otherwise
  -l | --list             list archived files
EOT
}

. $VM_LIB/options.sh

CREATE=0
COMPRESS=0

while true; do
    case "$1" in
        --)
            shift
            break
            ;;
        -c|--create)
            CREATE=1
            shift
            ;;
        -z|--compress)
            COMPRESS=1
            COMPRESSOR=$2
            shift 2
            ;;
        -s|--saved-state)
            VM=$2
            shift 2
            ;;
        *)
            shift
            ;;
    esac
done

if [ "$COMPRESS" = 1 ]; then
    case "$COMPRESSOR" in
        xz|gzip|bzip2|lz4)
            test -z "`which $COMPRESSOR`" && vm_die compressor \'$COMPRESSOR\' not found
            ;;
        *)
            vm_die unknown compressor \'$COMPRESSOR\'
    esac
fi

VM_LONGOPTS=create,delvm:,savevm:,compress:,compress-base
VM_OPTIONS=cd:s:z:b

function vm_help()
{
    cat <<EOT
  -c | --create           commit to base and create new backing file
  -d | --delvm            delete saved state from archived base file
  -s | --savevm           save named snapshot to backing file before archiving
  -z | --compress         use compression, one of xz, gzip, bzip2, lz4
  -b | --compress-base    compress the base file as well (default is not to)
EOT
}

. $VM_LIB/options.sh

CREATE=0
DELVM=0
NOBASE=0

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
        -d|--delvm)
            DELVM=$2
            shift
            ;;
        -s|--savevm)
            SAVEVM=$2
            shift 2
            ;;
        -z|--compress)
            COMPRESSOR=$2
            shift 2
            ;;
        -b|--compress-base)
            CMPBASE=1
            shift
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

if [ "$CREATE" = "1" -a "$SAVEVM" != "" ]; then vm_die --savevm only makes sense in conjunction with --create; fi
if [ "$CREATE" = "0" -a "$DELVM" != "" ]; then vm_die --delvm does not make sense in conjunction with --create; fi
if [ "$COMPRESSOR" = "" -a "$CMPBASE" = "1" ]; then vm_die --compress-base does not make sense without --compress; fi

VM_LONGOPTS=dry-run,clobber-backing,clobber-base
VM_OPTIONS=tbk

function vm_help()
{
    cat <<EOT
  -t | --dry-run          do not execute commands, just play what-if
  -k | --clobber-backing  overwrite existing backing file
  -b | --clobber-base     overwrite existing base file
EOT
}

. $VM_LIB/options.sh

while true; do
    case "$1" in
        --)
            shift
            break
            ;;
        -t|--dry-run)
            DRYRUN=1
            shift
            ;;
        -k|--clobber-backing)
            OK=1
            shift
            ;;
        -b|--clobber-base)
            OB=1
            shift
            ;;
        *)
            shift
            ;;
    esac
done




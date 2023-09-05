VM_LONGOPTS=dry-run,clobber-backing,clobber-base
VM_OPTIONS=tbk

VM_USAGE='<command>'

function vm_help()
{
    cat <<EOT
EOT
}

. $VM_LIB/options.sh

while true; do
    case "$1" in
        --)
            shift
            break
            ;;
        *)
            shift
            ;;
    esac
done


LONGOPTS=help,show-commands,dry-run,clobber-backing,clobber-base
OPTIONS=hctbk

. $VM_LIB/options.sh

while true; do
    case "$1" in
        --)
            shift
            break
            ;;
        -h|--help)
                cat 1>&2 <<EOT
  -c | --show-commands    show commands being executed
  -t | --dry-run          do not execute commands, just play what-if
  -k | --clobber-backing  overwrite existing backing file
  -b | --clobber-base     overwrite existing base file
EOT
                exit 0
                ;;

        -c|--show-commands)
            VERBOSE=1
            SHOWCOM=1
            shift
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
            vm_die internal error parsing command line
            ;;
    esac
done




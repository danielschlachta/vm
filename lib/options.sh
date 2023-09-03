vm_check_prog getopt
vm_die_if_error

getopt --test > /dev/null
if [[ $? -ne 4 ]]; then
    vm_die getopt --test failed
fi

LONGOPTS=help,verbose,$VM_LONGOPTS
OPTIONS=hv,$VM_OPTIONS

PARSED=$(getopt --options=$OPTIONS --longoptions=$LONGOPTS --name "$0" -- "$@" 2>&1)

if [[ $? -ne 0 ]]; then
    vm_die `echo $PARSED | sed -e 's,.*:,,' -e 's, --$,,'`
fi

eval set -- "$PARSED"

VERBOSE=0

for i in $*; do
    case "$i" in
        -v|--verbose)
            VERBOSE=1
            ;;
        -h|--help)
            cat 1>&2 <<EOT
  -h | --help             display this text
  -v | --verbose          be chatty, precise meaning depends on command
EOT
            vm_help 1>&2
            exit 0
            ;;
    esac
done


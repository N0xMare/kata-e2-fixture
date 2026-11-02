# number: prefix every line with its line number and a separator.

usage_number() {
	printf 'usage: linekit number [-s SEP] [-n START] [FILE...]\n'
}

cmd_number() {
	_sep='	'
	_start=
	OPTIND=1
	while getopts ':hn:s:' _opt; do
		case $_opt in
		h)
			usage_number
			exit 0
			;;
		n)
			case $OPTARG in
			'' | *[!0-9]*)
				printf 'linekit: number: invalid start: %s\n' "$OPTARG" >&2
				exit 1
				;;
			esac
			_start=$OPTARG
			;;
		s) _sep=$OPTARG ;;
		:) lk_missing_argument number "$OPTARG" ;;
		*) lk_bad_option number "$OPTARG" ;;
		esac
	done
	shift $((OPTIND - 1))
	lk_check_files number $@
	# Line numbers run on across FILEs, like `cat -n`, and begin at START.
	_offset=${_start:-0}
	awk -v sep="$_sep" -v offset="$_offset" '{ printf "%d%s%s\n", NR + offset, sep, $0 }' "$@"
}

# number: prefix every line with its line number and a separator.

usage_number() {
	printf 'usage: linekit number [-s SEP] [FILE...]\n'
}

cmd_number() {
	_sep='	'
	OPTIND=1
	while getopts ':hs:' _opt; do
		case $_opt in
		h)
			usage_number
			exit 0
			;;
		s) _sep=$OPTARG ;;
		:) lk_missing_argument number "$OPTARG" ;;
		*) lk_bad_option number "$OPTARG" ;;
		esac
	done
	shift $((OPTIND - 1))
	lk_check_files number "$@"
	# Line numbers run on across FILEs, like `cat -n`.
	awk -v sep="$_sep" '{ printf "%d%s%s\n", NR, sep, $0 }' "$@"
}

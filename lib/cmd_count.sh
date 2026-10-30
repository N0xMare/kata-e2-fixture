# count: print the number of input lines.

usage_count() {
	printf 'usage: linekit count [FILE...]\n'
}

cmd_count() {
	OPTIND=1
	while getopts ':h' _opt; do
		case $_opt in
		h)
			usage_count
			exit 0
			;;
		*) lk_bad_option count "$OPTARG" ;;
		esac
	done
	shift $((OPTIND - 1))
	lk_check_files count "$@"
	awk 'END { print NR }' "$@"
}

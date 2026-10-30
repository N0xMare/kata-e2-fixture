# squeeze: replace every run of blank lines (empty, or only spaces and tabs)
# with one empty line.

usage_squeeze() {
	printf 'usage: linekit squeeze [FILE...]\n'
}

cmd_squeeze() {
	OPTIND=1
	while getopts ':h' _opt; do
		case $_opt in
		h)
			usage_squeeze
			exit 0
			;;
		*) lk_bad_option squeeze "$OPTARG" ;;
		esac
	done
	shift $((OPTIND - 1))
	lk_check_files squeeze "$@"
	awk '/^[ \t]*$/ { if (!blank) print ""; blank = 1; next } { blank = 0; print }' "$@"
}

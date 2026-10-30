# trim: remove leading and trailing blanks (spaces and tabs) from every line.

usage_trim() {
	printf 'usage: linekit trim [FILE...]\n'
}

cmd_trim() {
	OPTIND=1
	while getopts ':h' _opt; do
		case $_opt in
		h)
			usage_trim
			exit 0
			;;
		*) lk_bad_option trim "$OPTARG" ;;
		esac
	done
	shift $((OPTIND - 1))
	lk_check_files trim "$@"
	awk '{ sub(/^[ \t]+/, ""); sub(/[ \t]+$/, ""); print }' "$@"
}

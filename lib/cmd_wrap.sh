# wrap: greedily fill paragraphs to a maximum byte width.

usage_wrap() {
	printf 'usage: linekit wrap [-w WIDTH] [FILE...]\n'
}

cmd_wrap() {
	_width=72
	OPTIND=1
	while getopts ':hw:' _opt; do
		case $_opt in
		h)
			usage_wrap
			exit 0
			;;
		w)
			case $OPTARG in
			'' | 0* | *[!0-9]*) lk_usage_error wrap "invalid width: $OPTARG" ;;
			esac
			_width=$OPTARG
			;;
		:)
			lk_missing_argument wrap "$OPTARG"
			;;
		*) lk_bad_option wrap "$OPTARG" ;;
		esac
	done
	shift $((OPTIND - 1))
	lk_check_files wrap "$@"
	LC_ALL=C awk -v width="$_width" '
	function flush_paragraph(    i, word, candidate, line) {
		if (nwords == 0) return
		if (printed) print ""
		line = words[1]
		for (i = 2; i <= nwords; i++) {
			word = words[i]
			candidate = line " " word
			if (length(candidate) <= width) line = candidate
			else { print line; line = word }
		}
		print line
		printed = 1
		nwords = 0
	}
	{
		if ($0 ~ /^[ \t]*$/) { flush_paragraph(); next }
		rest = $0
		while (match(rest, /[^ \t]+/)) {
			words[++nwords] = substr(rest, RSTART, RLENGTH)
			rest = substr(rest, RSTART + RLENGTH)
		}
	}
	END { flush_paragraph() }
	' "$@"
}

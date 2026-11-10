# wrap: greedily fill paragraphs to a maximum line width.

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
	function flush_line() {
		if (line != "") {
			if (paragraphs > 0 && need_separator) print ""
			print line
			paragraphs++
			need_separator = 0
			line = ""
		}
	}
	{
		if ($0 ~ /^[ \t]*$/) {
			flush_line()
			if (paragraphs > 0) need_separator = 1
			next
		}
		s = $0
		while (match(s, /[^ \t]+/)) {
			word = substr(s, RSTART, RLENGTH)
			if (line == "") line = word
			else if (length(line) + 1 + length(word) <= width) line = line " " word
			else flush_line_and_start(word)
			s = substr(s, RSTART + RLENGTH)
		}
	}
	function flush_line_and_start(word) {
		flush_line()
		line = word
	}
	END { flush_line() }
	' "$@"
}

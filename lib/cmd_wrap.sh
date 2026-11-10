# wrap: fill paragraphs to a maximum line width.

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
		w) _width=$OPTARG ;;
		:) lk_missing_argument wrap "$OPTARG" ;;
		*) lk_bad_option wrap "$OPTARG" ;;
		esac
	done
	shift $((OPTIND - 1))
	case $_width in
	'' | 0* | *[!0-9]*) lk_usage_error wrap "invalid width: $_width" ;;
	esac
	lk_check_files wrap "$@"
	awk -v w="$_width" '
	function flush() {
		if (line != "") print line
		line = ""
	}
	{
		if (NF == 0) {
			flush()
			brk = 1
			next
		}
		for (i = 1; i <= NF; i++) {
			if (line == "") {
				if (brk && printed) print ""
				brk = 0
				line = $i
				printed = 1
			} else if (length(line) + 1 + length($i) <= w + 0) {
				line = line " " $i
			} else {
				print line
				line = $i
			}
		}
	}
	END { flush() }
	' "$@"
}

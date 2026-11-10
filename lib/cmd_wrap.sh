# linekit-cmd: wrap
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
		w)
			case $OPTARG in
			'' | 0* | *[!0-9]*) lk_usage_error wrap "invalid width: $OPTARG" ;;
			esac
			_width=$OPTARG
			;;
		:) lk_missing_argument wrap "$OPTARG" ;;
		*) lk_bad_option wrap "$OPTARG" ;;
		esac
	done
	shift $((OPTIND - 1))
	lk_check_files wrap "$@"
	awk -v w="$_width" '
	function flush() {
		if (line != "") {
			if (printed && gap) print ""
			print line
			printed = 1
			gap = 0
			line = ""
		}
	}
	NF == 0 { flush(); if (printed) gap = 1; next }
	{
		for (i = 1; i <= NF; i++) {
			if (line == "") line = $i
			else if (length(line) + 1 + length($i) <= w + 0) line = line " " $i
			else {
				if (printed && gap) print ""
				print line
				printed = 1
				gap = 0
				line = $i
			}
		}
	}
	END { flush() }
	' "$@"
}

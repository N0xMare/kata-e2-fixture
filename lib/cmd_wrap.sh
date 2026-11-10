# linekit-cmd: wrap
# wrap: greedily fill paragraphs to a maximum byte width.

usage_wrap() {
	printf 'usage: linekit wrap [-w WIDTH] [FILE...]\n'
}

cmd_wrap() {
	_width=72
	OPTIND=1
	while getopts ':hw:' _opt; do
		case $_opt in
		h) usage_wrap; exit 0 ;;
		w) _width=$OPTARG ;;
		:) lk_missing_argument wrap "$OPTARG" ;;
		*) lk_bad_option wrap "$OPTARG" ;;
		esac
	done
	shift $((OPTIND - 1))
	case $_width in
	''|0*|*[!0-9]*) lk_usage_error wrap "invalid width: $_width" ;;
	esac
	lk_check_files wrap "$@"
	awk -v width="$_width" '
	function flush(    i, n, words, line, out) {
		if (para == "") return
		if (printed) print ""
		printed = 1
		n = split(para, words, /[ \t]+/)
		line = ""
		for (i = 1; i <= n; i++) {
			if (line == "") line = words[i]
			else if (length(line) + 1 + length(words[i]) <= width) line = line " " words[i]
			else { print line; line = words[i] }
		}
		if (line != "") print line
		para = ""
	}
	{
		line = $0
		if (line ~ /^[ \t]*$/) { flush(); next }
		sub(/^[ \t]+/, "", line); sub(/[ \t]+$/, "", line)
		para = para (para == "" ? "" : " ") line
	}
	END { flush() }
	' "$@"
}

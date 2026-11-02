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
		w)
			case $OPTARG in
			''|0*|*[!0-9]*) lk_usage_error wrap "invalid width: $OPTARG" ;;
			esac
			_width=$OPTARG
			;;
		:) lk_missing_argument wrap "$OPTARG" ;;
		*) lk_bad_option wrap "$OPTARG" ;;
		esac
	done
	shift $((OPTIND - 1))
	lk_check_files wrap "$@"
	LC_ALL=C awk -v width="$_width" '
	function flush(    i, line, n) {
		if (count == 0) return
		line = words[1]
		for (i = 2; i <= count; i++) {
			n = length(line)
			if (n + 1 + length(words[i]) <= width) line = line " " words[i]
			else { print line; line = words[i] }
		}
		print line
		count = 0
	}
	{
		if ($0 ~ /^[ \t]*$/) { flush(); if (had_para) { pending = 1; had_para = 0 }; next }
		if (!had_para) { if (pending) print ""; pending = 0; had_para = 1 }
		s = $0
		gsub(/^[ \t]+|[ \t]+$/, "", s)
		n = split(s, a, /[ \t]+/)
		for (i = 1; i <= n; i++) words[++count] = a[i]
	}
	END { flush() }
	' "$@"
}

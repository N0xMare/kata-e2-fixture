# linekit-cmd: wrap
# wrap: fill paragraphs greedily to a maximum byte width.

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
	awk -v width="$_width" '
	function flush_line() { if (line != "") { print line; line = "" } }
	{
		if ($0 ~ /^[ \t]*$/) {
			if (line != "") { flush_line(); had_para = 1 }
			if (had_para) pending = 1
			next
		}
		n = split($0, words, /[ \t]+/)
		for (i = 1; i <= n; i++) {
			word = words[i]
			if (word == "") continue
			if (line == "") {
				if (pending) { print ""; pending = 0 }
				line = word
			}
			else if (length(line) + 1 + length(word) <= width) line = line " " word
			else flush_line(), line = word
		}
	}
	END { if (line != "") { flush_line(); had_para = 1 } }
	' "$@"
}

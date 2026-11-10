# wrap: greedily fill paragraphs to a maximum byte width.

usage_wrap() {
	printf 'usage: linekit wrap [-w WIDTH] [FILE...]\n'
}

cmd_wrap() {
	_wrap_width=72
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
			_wrap_width=$OPTARG
			;;
		:)
			lk_missing_argument wrap "$OPTARG"
			;;
		*) lk_bad_option wrap "$OPTARG" ;;
		esac
	done
	shift $((OPTIND - 1))
	lk_check_files wrap "$@"
	LC_ALL=C awk -v width="$_wrap_width" '
	function flush_paragraph(    i, line, word) {
		if (had_paragraph) print ""
		line = ""
		for (i = 1; i <= count; i++) {
			word = words[i]
			if (line == "") {
				line = word
			} else if (length(line) + 1 + length(word) <= width) {
				line = line " " word
			} else {
				print line
				line = word
			}
		}
		if (line != "") print line
		for (i in words) delete words[i]
		count = 0
		had_paragraph = 1
	}
	{
		if ($0 ~ /^[ \t]*$/) {
			if (count) flush_paragraph()
			next
		}
		n = split($0, fields, /[ \t]+/)
		for (i = 1; i <= n; i++) {
			if (fields[i] != "") words[++count] = fields[i]
		}
	}
	END {
		if (count) flush_paragraph()
	}
	' "$@"
}

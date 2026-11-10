# wrap: fill paragraphs greedily to a maximum byte width.

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
	awk -v width="$_wrap_width" '
	{
		if ($0 ~ /^[ \t]*$/) {
			if (line != "") {
				print line
				line = ""
			}
			if (paragraph_open) {
				have_paragraph = 1
				paragraph_open = 0
			}
			next
		}
		text = $0
		gsub(/^[ \t]+|[ \t]+$/, "", text)
		n = split(text, words, /[ \t]+/)
		for (i = 1; i <= n; i++) {
			if (!paragraph_open) {
				if (have_paragraph) print ""
				paragraph_open = 1
			}
			if (line == "") line = words[i]
			else if (length(line) + 1 + length(words[i]) <= width) line = line " " words[i]
			else { print line; line = words[i] }
		}
	}
	END { if (line != "") print line }
	' "$@"
}

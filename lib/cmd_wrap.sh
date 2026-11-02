# wrap: fill paragraphs to a maximum byte width.

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
	function finish_paragraph() {
		if (have_paragraph) {
			if (line != "") print line
			line = ""
			have_paragraph = 0
		}
	}
	{
		if ($0 ~ /^[ \t]*$/) {
			finish_paragraph()
			next
		}
		n = split($0, words, /[ \t]+/)
		for (i = 1; i <= n; i++) {
			word = words[i]
			if (word == "") continue
			if (!have_paragraph) {
				if (seen_paragraph) print ""
				have_paragraph = 1
				seen_paragraph = 1
				line = word
			} else if (line == "") {
				line = word
			} else if (length(line) + 1 + length(word) <= width) {
				line = line " " word
			} else {
				print line
				line = word
			}
		}
	}
	END { finish_paragraph() }
	' "$@"
}

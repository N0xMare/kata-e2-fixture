# wrap: greedily fill paragraphs to a maximum byte width.

usage_wrap() {
	printf 'usage: linekit wrap [-w WIDTH] [FILE...]\n'
}

cmd_wrap() {
	_wrap_width=72
	OPTIND=1
	while getopts ':hw:' _opt; do
		case $_opt in
		h) usage_wrap; exit 0 ;;
		w)
			_wrap_width=$OPTARG
			case $_wrap_width in
			'' | 0* | *[!0-9]*) lk_usage_error wrap "invalid width: $_wrap_width" ;;
			esac
			;;
		:) lk_missing_argument wrap "$OPTARG" ;;
		*) lk_bad_option wrap "$OPTARG" ;;
		esac
	done
	shift $((OPTIND - 1))
	lk_check_files wrap "$@"
	awk -v width="$_wrap_width" '
	function finish_paragraph() {
		if (line != "") {
			if (paragraphs) print ""
			print line
			paragraphs++
			line = ""
			length_line = 0
		}
	}
	{
		text = $0
		if (text ~ /^[ \t]*$/) {
			finish_paragraph()
			next
		}
		sub(/^[ \t]+/, "", text)
		sub(/[ \t]+$/, "", text)
		count = split(text, words, /[ \t]+/)
		for (i = 1; i <= count; i++) {
			word = words[i]
			word_length = length(word)
			if (line == "") {
				line = word
				length_line = word_length
			} else if (length_line + 1 + word_length <= width) {
				line = line " " word
				length_line += 1 + word_length
			} else {
				print line
				line = word
				length_line = word_length
			}
		}
	}
	END { finish_paragraph() }
	' "$@"
}

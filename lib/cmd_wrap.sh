# wrap: greedily fill paragraphs to a maximum byte width.

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
			_width=$OPTARG
			case $_width in
			'' | 0* | *[!0-9]*) lk_usage_error wrap "invalid width: $_width" ;;
			esac
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
			if (have_output) print ""
			print line
			have_output = 1
			line = ""
		}
	}
	{
		text = $0
		gsub(/^[ \t]+|[ \t]+$/, "", text)
		if (text == "") {
			flush_line()
			next
		}
		count = split(text, words, /[ \t]+/)
		for (i = 1; i <= count; i++) {
			word = words[i]
			if (line == "") line = word
			else if (length(line) + 1 + length(word) <= width) line = line " " word
			else {
				print line
				line = word
			}
		}
	}
	END { flush_line() }
	' "$@"
}

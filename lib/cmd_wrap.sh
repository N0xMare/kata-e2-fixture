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
	# Read each file as lines so a final unterminated line cannot run into the
	# first line of the next file. Re-emit a newline for every input line.
	_wrap_lines() {
		if [ "$#" -eq 0 ]; then
			while IFS= read -r _wrap_line || [ -n "$_wrap_line" ]; do
				printf '%s\n' "$_wrap_line"
			done
		else
			for _wrap_file do
				if [ "$_wrap_file" = - ]; then
					while IFS= read -r _wrap_line || [ -n "$_wrap_line" ]; do
						printf '%s\n' "$_wrap_line"
					done
				else
					while IFS= read -r _wrap_line || [ -n "$_wrap_line" ]; do
						printf '%s\n' "$_wrap_line"
					done <"$_wrap_file"
				fi
			done
		fi
	}
	_wrap_lines "$@" | LC_ALL=C awk -v width="$_width" '
	function finish_paragraph() {
		if (line != "") print line
		line = ""
		in_paragraph = 0
	}
	/^[ \t]*$/ {
		if (in_paragraph) {
			finish_paragraph()
			ended_paragraph = 1
		}
		next
	}
	{
		text = $0
		sub(/^[ \t]+/, "", text)
		sub(/[ \t]+$/, "", text)
		n = split(text, words, /[ \t]+/)
		for (i = 1; i <= n; i++) {
			word = words[i]
			if (word == "") continue
			if (!in_paragraph) {
				if (ended_paragraph) print ""
				in_paragraph = 1
				ended_paragraph = 0
			}
			if (line == "") line = word
			else if (length(line) + 1 + length(word) <= width) line = line " " word
			else {
				print line
				line = word
			}
		}
	}
	END {
		if (in_paragraph && line != "") print line
	}'
}

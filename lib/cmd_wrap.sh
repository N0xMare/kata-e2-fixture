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
			'' | *[!0-9]* | 0*) lk_usage_error wrap "invalid width: $OPTARG" ;;
			esac
			_width=$OPTARG
			;;
		:) lk_missing_argument wrap "$OPTARG" ;;
		*) lk_bad_option wrap "$OPTARG" ;;
		esac
	done
	shift $((OPTIND - 1))
	lk_check_files wrap "$@"
	# Default field splitting treats runs of spaces and tabs as one gap.
	awk -v width="$_width" '
		NF == 0 { if (cur != "") brk = 1; next }
		{
			if (brk) {
				print cur
				print ""
				cur = ""
				brk = 0
			}
			for (i = 1; i <= NF; i++) {
				if (cur == "") cur = $i
				else if (length(cur) + 1 + length($i) <= width) cur = cur " " $i
				else {
					print cur
					cur = $i
				}
			}
		}
		END { if (cur != "") print cur }
	' "$@"
}

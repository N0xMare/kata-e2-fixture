# wrap: fill paragraphs greedily to a maximum line width.

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
	awk -v w="$_width" '
	function flush() {
		if (cur != "") {
			print cur
			cur = ""
		}
	}
	NF == 0 {
		if (cur != "") {
			flush()
			pending = 1
		}
		next
	}
	{
		for (i = 1; i <= NF; i++) {
			if (cur == "") {
				if (pending) print ""
				pending = 0
				cur = $i
			} else if (length(cur) + 1 + length($i) <= w + 0) {
				cur = cur " " $i
			} else {
				print cur
				cur = $i
			}
		}
	}
	END { flush() }
	' "$@"
}

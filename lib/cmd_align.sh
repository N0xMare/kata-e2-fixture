# linekit-cmd: align
# align: align table cells by column.

usage_align() {
	printf 'usage: linekit align [-H] [-s SEP] [FILE...]\n'
}

cmd_align() {
	_sep=
	_has_sep=0
	_header=0
	OPTIND=1
	while getopts ':hHs:' _opt; do
		case $_opt in
		h) usage_align; exit 0 ;;
		H) _header=1 ;;
		s)
			[ "${#OPTARG}" -eq 1 ] || lk_usage_error align "invalid separator: $OPTARG"
			_sep=$OPTARG
			_has_sep=1
			;;
		:) lk_missing_argument align "$OPTARG" ;;
		*) lk_bad_option align "$OPTARG" ;;
		esac
	done
	shift $((OPTIND - 1))
	lk_check_files align "$@"
	LC_ALL=C awk -v sep="$_sep" -v use_sep="$_has_sep" -v has_header="$_header" '
	function trim(s) { sub(/^[ \t]+/, "", s); sub(/[ \t]+$/, "", s); return s }
	function numeric(s) { return s ~ /^-?[0-9]+(\.[0-9]+)?$/ }
	function padding(n,    s) { while (n-- > 0) s = s " "; return s }
	function addcell(r, c, s) {
		cells[r, c] = s
		if (length(s) > width[c]) width[c] = length(s)
		if (c > cols[r]) cols[r] = c
	}
	function parse_row(s, r,    rest,p,c) {
		rows++
		if (s ~ /^[ \t]*$/) { blank[rows] = 1; return }
		if (has_header && header == 0) header = rows
		if (!use_sep) {
			s = trim(s)
			if (s == "") return
			c = split(s, part, /[ \t]+/)
			for (p = 1; p <= c; p++) addcell(rows, p, part[p])
		} else {
			rest = s; c = 1
			while ((p = index(rest, sep)) > 0) {
				addcell(rows, c++, trim(substr(rest, 1, p - 1)))
				rest = substr(rest, p + 1)
			}
			addcell(rows, c, trim(rest))
		}
	}
	{ parse_row($0, rows + 1) }
	END {
		for (r = 1; r <= rows; r++) if (!blank[r]) for (c = 1; c <= cols[r]; c++) {
			s = cells[r, c]
			if (r == header) continue
			if (s == "") continue
			seen[c] = 1
			if (!numeric(s)) allnum[c] = 0
			else if (!(c in allnum)) allnum[c] = 1
		}
		for (r = 1; r <= rows; r++) {
			if (blank[r]) { print ""; continue }
			out = ""
			for (c = 1; c <= cols[r]; c++) {
				s = cells[r, c]
				pad = width[c] - length(s)
				if (c > 1) out = out "  "
				if (seen[c] && allnum[c]) out = out padding(pad) s
				else out = out s padding(pad)
			}
			sub(/[ ]+$/, "", out)
			print out
		}
	}
	' "$@"
}

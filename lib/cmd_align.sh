# linekit-cmd: align
# align: line up the columns of a table.

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
		s) _sep=$OPTARG; _has_sep=1 ;;
		:) lk_missing_argument align "$OPTARG" ;;
		*) lk_bad_option align "$OPTARG" ;;
		esac
	done
	shift $((OPTIND - 1))
	if [ "$_has_sep" -eq 1 ] && [ "${#_sep}" -ne 1 ]; then
		lk_usage_error align "invalid separator: $_sep"
	fi
	lk_check_files align "$@"
	awk -v sep="$_sep" -v use_sep="$_has_sep" -v header="$_header" '
	function trim(s) { sub(/^[ \t]+/, "", s); sub(/[ \t]+$/, "", s); return s }
	function spaces(n,    s) { s = ""; while (n-- > 0) s = s " "; return s }
	function addcell(r, c, value) {
		value = trim(value); cells[r, c] = value
		if (length(value) > widths[c]) widths[c] = length(value)
		if (c > cols) cols = c
	}
	function numeric(s) { return s ~ /^-?[0-9]+(\.[0-9]+)?$/ }
	function parse(line, r, n, i, start, pos, c, value, rest, count, a) {
		r = ++rows
		if (line ~ /^[ \t]*$/) { blank[r] = 1; return }
		nonblank++
		if (use_sep == 1) {
			start = 1; c = 0
			while ((pos = index(substr(line, start), sep)) > 0) {
				pos += start - 1; addcell(r, ++c, substr(line, start, pos - start)); start = pos + 1
			}
			addcell(r, ++c, substr(line, start))
		} else {
			line = trim(line)
			count = split(line, a, /[ \t]+/)
			for (i = 1; i <= count; i++) addcell(r, i, a[i])
		}
		if (header && nonblank == 1) headerrow = r
	}
	{
		parse($0)
	}
	END {
		for (c = 1; c <= cols; c++) {
			seen = 0; isnum = 1
			for (r = 1; r <= rows; r++) {
				if (r == headerrow) continue
				v = cells[r, c]
				if (v != "") { seen++; if (!numeric(v)) isnum = 0 }
			}
			numericcol[c] = seen > 0 && isnum
		}
		for (r = 1; r <= rows; r++) {
			if (blank[r]) { print ""; continue }
			out = ""
			for (c = 1; c <= cols && ((r SUBSEP c) in cells); c++) {
				v = cells[r, c]; pad = widths[c] - length(v)
				if (c > 1) out = out "  "
				if (numericcol[c]) out = out spaces(pad) v
				else out = out v spaces(pad)
			}
			sub(/[ \t]+$/, "", out); print out
		}
	}
	' "$@"
}

# align: line up table columns.

usage_align() {
	printf 'usage: linekit align [-H] [-s SEP] [FILE...]\n'
}

cmd_align() {
	_header=0
	_sep=
	_has_sep=0
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
	if [ "$_has_sep" -eq 1 ]; then
		[ "${#_sep}" -eq 1 ] || lk_usage_error align "invalid separator: $_sep"
	fi
	lk_check_files align "$@"
	LK_ALIGN_SEP=$_sep LC_ALL=C awk -v header="$_header" -v have_sep="$_has_sep" '
	BEGIN { sep = ENVIRON["LK_ALIGN_SEP"] }
	function trim(s) { sub(/^[ \t]+/, "", s); sub(/[ \t]+$/, "", s); return s }
	function addcell(r, c, v) {
		cells[r, c] = v
		if (length(v) > width[c]) width[c] = length(v)
		if (c > cols[r]) cols[r] = c
	}
	function parse(s, r,    p, q, n, a, i) {
		r++
		if (s ~ /^[ \t]*$/) { blank[r] = 1; rows = r; return }
		if (header && headrow == 0) headrow = r
		if (!have_sep) {
			n = split(trim(s), a, /[ \t]+/)
			for (i = 1; i <= n; i++) addcell(r, i, a[i])
		} else {
			n = 1; p = 1
			while ((q = index(substr(s, p), sep)) > 0) {
				addcell(r, n++, trim(substr(s, p, q - 1)))
				p += q
			}
			addcell(r, n, trim(substr(s, p)))
		}
		rows = r
	}
	function numeric(s) { return s ~ /^-?[0-9]+([.][0-9]+)?$/ }
	{
		parse($0, rows)
	}
	END {
		for (c = 1; c <= 10000; c++) {
			seen = 0; ok = 1
			for (r = 1; r <= rows; r++) if (!blank[r] && r != headrow && c <= cols[r] && cells[r, c] != "") {
				seen = 1
				if (!numeric(cells[r, c])) ok = 0
			}
			isnum[c] = (seen && ok)
		}
		for (r = 1; r <= rows; r++) {
			if (blank[r]) { print ""; continue }
			out = ""
			for (c = 1; c <= cols[r]; c++) {
				v = cells[r, c]; pad = width[c] - length(v)
				if (c > 1) out = out "  "
				spaces = ""
				for (i = 0; i < pad; i++) spaces = spaces " "
				if (isnum[c]) out = out spaces v
				else out = out v spaces
			}
			sub(/[ \t]+$/, "", out)
			print out
		}
	}
	' "$@"
}

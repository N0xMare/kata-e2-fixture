# linekit-cmd: align
# align: line up the columns of a table.

usage_align() {
	printf 'usage: linekit align [-H] [-s SEP] [FILE...]\n'
}

cmd_align() {
	_header=0
	_hassep=0
	_sep=
	OPTIND=1
	while getopts ':hHs:' _opt; do
		case $_opt in
		h)
			usage_align
			exit 0
			;;
		H) _header=1 ;;
		s)
			if [ "${#OPTARG}" -ne 1 ]; then
				lk_usage_error align "invalid separator: $OPTARG"
			fi
			_hassep=1
			_sep=$OPTARG
			;;
		:) lk_missing_argument align "$OPTARG" ;;
		*) lk_bad_option align "$OPTARG" ;;
		esac
	done
	shift $((OPTIND - 1))
	lk_check_files align "$@"
	LK_SEP=$_sep LK_HASSEP=$_hassep LK_HDR=$_header awk '
	BEGIN { sep = ENVIRON["LK_SEP"]; hassep = ENVIRON["LK_HASSEP"] + 0; hdr = ENVIRON["LK_HDR"] + 0 }
	/^[ \t]*$/ { n++; blank[n] = 1; next }
	{
		n++
		r = ++nrows
		rowof[n] = r
		k = 0
		if (hassep) {
			s = $0
			while ((p = index(s, sep)) > 0) {
				add(r, ++k, substr(s, 1, p - 1))
				s = substr(s, p + 1)
			}
			add(r, ++k, s)
		} else {
			for (i = 1; i <= NF; i++) add(r, ++k, $i)
		}
		nc[r] = k
	}
	function add(r, k, c) {
		sub(/^[ \t]+/, "", c)
		sub(/[ \t]+$/, "", c)
		cell[r, k] = c
		if (length(c) > wid[k]) wid[k] = length(c)
		if (k > maxc) maxc = k
		if (hdr && r == 1) return
		if (c != "") {
			nonempty[k]++
			if (c !~ /^-?[0-9]+(\.[0-9]+)?$/) bad[k] = 1
		}
	}
	END {
		for (i = 1; i <= n; i++) {
			if (blank[i]) { print ""; continue }
			r = rowof[i]
			out = ""
			for (k = 1; k <= nc[r]; k++) {
				c = cell[r, k]
				if (nonempty[k] > 0 && !bad[k]) f = "%" wid[k] "s"
				else f = "%-" wid[k] "s"
				out = out (k > 1 ? "  " : "") sprintf(f, c)
			}
			sub(/ +$/, "", out)
			print out
		}
	}
	' "$@"
}

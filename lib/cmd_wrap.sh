# linekit-cmd: wrap
usage_wrap() { printf 'usage: linekit wrap [-w WIDTH] [FILE...]\n'; }
cmd_wrap() {
	_width=72
	OPTIND=1
	while getopts ':hw:' _opt; do
		case $_opt in
		h) usage_wrap; exit 0 ;;
		w) _width=$OPTARG ;;
		:) lk_missing_argument wrap "$OPTARG" ;;
		*) lk_bad_option wrap "$OPTARG" ;;
		esac
	done
	shift $((OPTIND - 1))
	case $_width in ''|0*|*[!0-9]*) lk_usage_error wrap "invalid width: $_width" ;; esac
	lk_check_files wrap "$@"
	awk -v width="$_width" '
	function flush(  i,n,line,w) {
		if (count == 0) return
		if (printed) print ""
		line=""
		for (i=1;i<=count;i++) {
			w=words[i]
			if (line == "") line=w
			else if (length(line)+1+length(w) <= width) line=line " " w
			else { print line; line=w }
		}
		print line; printed=1; delete words; count=0
	}
	{ if ($0 ~ /^[ \t]*$/) { flush(); next }
	  n=split($0,a,/[ \t]+/)
	  for(i=1;i<=n;i++) if(a[i]!="") words[++count]=a[i]
	}
	END { flush() }' "$@"
}

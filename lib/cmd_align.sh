# linekit-cmd: align
usage_align() { printf 'usage: linekit align [-H] [-s SEP] [FILE...]\n'; }
cmd_align() {
	_sep= _sep_set=0 _header=0
	OPTIND=1
	while getopts ':hHs:' _opt; do
		case $_opt in
		h) usage_align; exit 0 ;;
		H) _header=1 ;;
		s) _sep=$OPTARG; _sep_set=1 ;;
		:) lk_missing_argument align "$OPTARG" ;;
		*) lk_bad_option align "$OPTARG" ;;
		esac
	done
	shift $((OPTIND - 1))
	if [ "$_sep_set" = 1 ] && [ "${#_sep}" -ne 1 ]; then lk_usage_error align "invalid separator: $_sep"; fi
	lk_check_files align "$@"
	awk -v sep="$_sep" -v header="$_header" '
	function trim(s){sub(/^[ \t]+/,"",s);sub(/[ \t]+$/,"",s);return s}
	function parse(s, a, n,i) {
		delete cells
		if (sep == "") { n=split(trim(s),a,/[ \t]+/); for(i=1;i<=n;i++) cells[i]=a[i]; return n }
		n=1; while ((i=index(s,sep))>0) { cells[n++]=trim(substr(s,1,i-1)); s=substr(s,i+length(sep)) } cells[n]=trim(s); return n
	}
	{ if ($0 ~ /^[ \t]*$/) { blank[++rows]=1; next }
	  rows++; n=parse($0); nr[rows]=n; if(header && !seen++) ishead[rows]=1
	  for(i=1;i<=n;i++){ cell[rows,i]=cells[i]; l=length(cells[i]); if(l>width[i])width[i]=l }
	}
	END {
	 for(r=1;r<=rows;r++) { if(blank[r])continue
	   for(k=1;k<=nr[r];k++) if(!ishead[r] && cell[r,k]!="") { seenval[k]=1; if(cell[r,k] !~ /^-?[0-9]+(\.[0-9]+)?$/) numeric[k]=0; else if(!(k in numeric)) numeric[k]=1 }
	 }
	 for(r=1;r<=rows;r++){ if(blank[r]){print "";continue} out=""; for(k=1;k<=nr[r];k++){v=cell[r,k]; pad=width[k]-length(v); spaces=""; for(j=0;j<pad;j++)spaces=spaces " "; if(k>1)out=out "  "; if(numeric[k] && seenval[k])out=out spaces v; else out=out v spaces } sub(/[ ]+$/, "",out); print out }
	}' "$@"
}

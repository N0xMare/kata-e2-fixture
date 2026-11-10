# wrap

run 'the quick brown fox jumps over the lazy dog\n' wrap -w 10
check 'A1 greedily wraps words' 0 'the quick\nbrown fox\njumps over\nthe lazy\ndog\n'

run 'aaaa bbbbb\n' wrap -w 10
check 'A2 exact width fits' 0 'aaaa bbbbb\n'

run 'aaaa bbbbb\n' wrap -w 9
check 'A3 over width starts a line' 0 'aaaa\nbbbbb\n'

run 'a supercalifragilistic b\n' wrap -w 5
check 'A4 overlong word remains unbroken' 0 'a\nsupercalifragilistic\nb\n'

run '  lots   of\t\tspace  \n' wrap
check 'A5 joins whitespace separated words' 0 'lots of space\n'

run '\n\none\ntwo\n\n \n\t\nthree\n\n\n' wrap
check 'A6 separates paragraphs once' 0 'one two\n\nthree\n'

run 'last line' wrap -w 4
check 'A7 handles missing final newline' 0 'last\nline\n'

run '' wrap
check 'A8 empty input' 0 ''

run ' \n\t\n\n' wrap
check 'A9 blank input' 0 ''

_many=
_expected=
_i=1
while [ "$_i" -le 30 ]; do
	_many="${_many}word"
	[ "$_i" -eq 30 ] || _many="${_many} "
	case $_i in
	15) _expected="${_expected% }\n" ;;
	29) _expected="${_expected% }\n" ;;
	esac
	_expected="${_expected}word "
	_i=$((_i + 1))
done
_expected="${_expected% }\n"
run "$_many\n" wrap
check 'A10 default width wraps 30 words' 0 "$_expected"

run 'a b c\n' wrap -w3
check 'A11 accepts attached width' 0 'a b\nc\n'

printf 'alpha' >"$WORK/F1"
printf 'beta\n' >"$WORK/F2"
run '' wrap "$WORK/F1" "$WORK/F2"
check 'A12 combines files as one stream' 0 'alpha beta\n'

for _bad_width in 0 07 -3 abc 5x ''; do
	run 'a\n' wrap -w "$_bad_width"
	check_error "A13 rejects width '$_bad_width'" 2 "linekit: wrap: invalid width: $_bad_width"
	if [ "$(sed -n '2p' "$WORK/err")" = 'usage: linekit wrap [-w WIDTH] [FILE...]' ]; then
		pass "A13 usage follows invalid width $_bad_width"
	else
		fail "A13 usage follows invalid width $_bad_width" 'missing usage line'
	fi
done

run '' wrap -w
check_error 'A14 reports missing width argument' 2 'linekit: wrap: missing argument for -w'

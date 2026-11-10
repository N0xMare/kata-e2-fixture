# wrap

USAGE='usage: linekit wrap [-w WIDTH] [FILE...]'

run 'the quick brown fox jumps over the lazy dog\n' wrap -w 10
check 'A1 fills greedily' 0 'the quick\nbrown fox\njumps over\nthe lazy\ndog\n'

run 'aaaa bbbbb\n' wrap -w 10
check 'A2 a line of exactly the width fits' 0 'aaaa bbbbb\n'

run 'aaaa bbbbb\n' wrap -w 9
check 'A3 one byte over the width breaks' 0 'aaaa\nbbbbb\n'

run 'a supercalifragilistic b\n' wrap -w 5
check 'A4 a long word sits alone' 0 'a\nsupercalifragilistic\nb\n'

run '  lots   of\t\tspace  \n' wrap
check 'A5 blanks collapse and are trimmed' 0 'lots of space\n'

run '\n\none\ntwo\n\n \n\t\nthree\n\n\n' wrap
check 'A6 paragraphs separated by one empty line' 0 'one two\n\nthree\n'

run 'last line' wrap -w 4
check 'A7 final line without newline' 0 'last\nline\n'

run '' wrap
check 'A8 empty input prints nothing' 0 ''

run ' \n\t\n\n' wrap
check 'A9 blank-only input prints nothing' 0 ''

_in=word
_i=1
while [ "$_i" -lt 30 ]; do
	_in="$_in word"
	_i=$((_i + 1))
done
_w14='word word word word word word word word word word word word word word'
run "$_in\n" wrap
check 'A10 default width is 72' 0 "$_w14\n$_w14\nword word\n"

run 'a b c\n' wrap -w3
check 'A11 attached -wWIDTH' 0 'a b\nc\n'

printf 'alpha' >"$WORK/wrap-1"
printf 'beta\n' >"$WORK/wrap-2"
run '' wrap "$WORK/wrap-1" "$WORK/wrap-2"
check 'A12 files form one stream' 0 'alpha beta\n'

for _w in 0 07 -3 +5 abc 5x ''; do
	run 'a\n' wrap -w "$_w"
	check_error "A13 invalid width '$_w'" 2 "linekit: wrap: invalid width: $_w"
	_line=$(sed -n 2p "$WORK/err")
	if [ "$_line" = "$USAGE" ]; then
		pass "A13 invalid width '$_w' shows usage"
	else
		fail "A13 invalid width '$_w' shows usage" "want usage on stderr line 2"
	fi
done

run '' wrap -w
check_error 'A14 -w without an argument' 2 'linekit: wrap: missing argument for -w'

run '' wrap -Z
check_error 'unknown option' 2 'linekit: wrap: unknown option: -Z'

run '' wrap -h
check '-h prints usage' 0 "$USAGE\n"

run 'a b\n' wrap -w 1
check '-w 1 puts each word on its own line' 0 'a\nb\n'

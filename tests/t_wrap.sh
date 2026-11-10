# wrap

run 'the quick brown fox jumps over the lazy dog\n' wrap -w 10
check 'A1 fills greedily' 0 'the quick\nbrown fox\njumps over\nthe lazy\ndog\n'

run 'aaaa bbbbb\n' wrap -w 10
check 'A2 a line of exactly WIDTH fits' 0 'aaaa bbbbb\n'

run 'aaaa bbbbb\n' wrap -w 9
check 'A3 one byte over WIDTH breaks' 0 'aaaa\nbbbbb\n'

run 'a supercalifragilistic b\n' wrap -w 5
check 'A4 a long word sits alone' 0 'a\nsupercalifragilistic\nb\n'

run '  lots   of\t\tspace  \n' wrap
check 'A5 blanks are normalised' 0 'lots of space\n'

run '\n\none\ntwo\n\n \n\t\nthree\n\n\n' wrap
check 'A6 paragraphs are separated by one empty line' 0 'one two\n\nthree\n'

run 'last line' wrap -w 4
check 'A7 final line without newline' 0 'last\nline\n'

run '' wrap
check 'A8 empty input prints nothing' 0 ''

run ' \n\t\n\n' wrap
check 'A9 blank-only input prints nothing' 0 ''

_w=
_i=0
while [ "$_i" -lt 30 ]; do
	_w="$_w${_w:+ }word"
	_i=$((_i + 1))
done
_l14='word word word word word word word word word word word word word word'
run "$_w\n" wrap
check 'A10 default width is 72' 0 "$_l14\n$_l14\nword word\n"

run 'a b c\n' wrap -w3
check 'A11 -w3 is the same as -w 3' 0 'a b\nc\n'

printf 'alpha' >"$WORK/wrap-1"
printf 'beta\n' >"$WORK/wrap-2"
run '' wrap "$WORK/wrap-1" "$WORK/wrap-2"
check 'A12 files form one stream' 0 'alpha beta\n'

for _bad in 0 07 -3 +5 abc 5x ''; do
	run 'a\n' wrap -w "$_bad"
	check_error "A13 invalid width '$_bad'" 2 "linekit: wrap: invalid width: $_bad"
	_l2=$(sed -n 2p "$WORK/err")
	if [ "$_l2" = 'usage: linekit wrap [-w WIDTH] [FILE...]' ]; then
		pass "A13 invalid width '$_bad' is followed by the usage line"
	else
		fail "A13 invalid width '$_bad' is followed by the usage line" "want stderr line 2: the usage line"
	fi
done

run '' wrap -w
check_error 'A14 -w without an argument' 2 'linekit: wrap: missing argument for -w'

run '' wrap -h
check '-h prints the usage' 0 'usage: linekit wrap [-w WIDTH] [FILE...]\n'

run 'a\n' wrap -w 1 -q
check_error 'unknown option' 2 'linekit: wrap: unknown option: -q'

run 'a\n' wrap "$WORK/no-such-wrap"
check_error 'unreadable file' 1 "linekit: wrap: $WORK/no-such-wrap: cannot read"

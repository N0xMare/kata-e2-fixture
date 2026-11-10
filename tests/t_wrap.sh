# wrap

run 'the quick brown fox jumps over the lazy dog\n' wrap -w 10
check 'A1 greedily wraps words' 0 'the quick\nbrown fox\njumps over\nthe lazy\ndog\n'

run 'aaaa bbbbb\n' wrap -w 10
check 'A2 fits exact width' 0 'aaaa bbbbb\n'

run 'aaaa bbbbb\n' wrap -w 9
check 'A3 wraps past width' 0 'aaaa\nbbbbb\n'

run 'a supercalifragilistic b\n' wrap -w 5
check 'A4 leaves long words unbroken' 0 'a\nsupercalifragilistic\nb\n'

run '  lots   of\t\tspace  \n' wrap
check 'A5 collapses spaces and tabs' 0 'lots of space\n'

run '\n\none\ntwo\n\n \n\t\nthree\n\n\n' wrap
check 'A6 separates paragraphs once' 0 'one two\n\nthree\n'

run 'last line' wrap -w 4
check 'A7 terminates final unterminated line' 0 'last\nline\n'

run '' wrap
check 'A8 empty input' 0 ''

run ' \n\t\n\n' wrap
check 'A9 blank input' 0 ''

_words=
_i=1
while [ "$_i" -le 30 ]; do
	_words="$_words${_words:+ }word"
	_i=$((_i + 1))
done
_want=
_i=1
while [ "$_i" -le 14 ]; do
	_want="$_want${_want:+ }word"
	_i=$((_i + 1))
done
_expected="$_want\n$_want\nword word\n"
run "$_words\n" wrap
check 'A10 default width wraps thirty words' 0 "$_expected"

run 'a b c\n' wrap -w3
check 'A11 accepts compact option argument' 0 'a b\nc\n'

printf 'alpha' >"$WORK/wrap-f1"
printf 'beta\n' >"$WORK/wrap-f2"
run '' wrap "$WORK/wrap-f1" "$WORK/wrap-f2"
check 'A12 joins input files as one stream' 0 'alpha beta\n'

for _bad in 0 07 -3 abc 5x ''; do
	run 'a\n' wrap -w "$_bad"
	check_error "A13 rejects width '$_bad'" 2 "linekit: wrap: invalid width: $_bad"
	if [ "$(sed -n '2p' "$WORK/err")" = 'usage: linekit wrap [-w WIDTH] [FILE...]' ]; then
		pass "A13 usage follows invalid width '$_bad'"
	else
		fail "A13 usage follows invalid width '$_bad'" 'usage line must be second stderr line'
	fi
done

run '' wrap -w
check_error 'A14 rejects missing width argument' 2 'linekit: wrap: missing argument for -w'

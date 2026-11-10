# wrap

run 'the quick brown fox jumps over the lazy dog\n' wrap -w 10
check 'wraps greedily at width 10' 0 'the quick\nbrown fox\njumps over\nthe lazy\ndog\n'

run 'aaaa bbbbb\n' wrap -w 10
check 'fits words exactly at the width' 0 'aaaa bbbbb\n'

run 'aaaa bbbbb\n' wrap -w 9
check 'wraps when a word would exceed the width' 0 'aaaa\nbbbbb\n'

run 'a supercalifragilistic b\n' wrap -w 5
check 'leaves overlong words unbroken' 0 'a\nsupercalifragilistic\nb\n'

run '  lots   of\t\tspace  \n' wrap
check 'collapses spaces and tabs between words' 0 'lots of space\n'

run '\n\none\ntwo\n\n \n\t\nthree\n\n\n' wrap
check 'separates paragraphs with one blank line' 0 'one two\n\nthree\n'

run 'last line' wrap -w 4
check 'terminates and wraps an unterminated final input line' 0 'last\nline\n'

run '' wrap
check 'empty input prints nothing' 0 ''

run ' \n\t\n\n' wrap
check 'all blank input prints nothing' 0 ''

_many=
_expected=
_i=0
while [ "$_i" -lt 30 ]; do
	_many="$_many word"
	_i=$((_i + 1))
done
_many=${_many# }
_i=0
while [ "$_i" -lt 14 ]; do
	_expected="$_expected word"
	_i=$((_i + 1))
done
_expected=${_expected# }
_expected="$_expected\n$_expected"
_expected="$_expected\nword word\n"
run "$_many\n" wrap
check 'wraps thirty default width words as 14, 14, and 2' 0 "$_expected"

run 'a b c\n' wrap -w3
check 'accepts attached width option arguments' 0 'a b\nc\n'

printf 'alpha' >"$WORK/wrap-1"
printf 'beta\n' >"$WORK/wrap-2"
run '' wrap "$WORK/wrap-1" "$WORK/wrap-2"
check 'joins input lines across files as one stream' 0 'alpha beta\n'

for _bad in 0 07 -3 +5 abc 5x ''; do
	run 'a\n' wrap -w "$_bad"
	check_error "rejects invalid width [$_bad]" 2 "linekit: wrap: invalid width: $_bad"
	printf 'usage: linekit wrap [-w WIDTH] [FILE...]\n' >"$WORK/want-usage"
	tail -n 1 "$WORK/err" >"$WORK/got-usage"
	if cmp -s "$WORK/want-usage" "$WORK/got-usage"; then
		pass "invalid width [$_bad] prints usage"
	else
		fail "invalid width [$_bad] prints usage" 'usage line did not match'
	fi
done

run '' wrap -w
check_error 'missing width argument is a usage error' 2 'linekit: wrap: missing argument for -w'
printf 'usage: linekit wrap [-w WIDTH] [FILE...]\n' >"$WORK/want-usage"
tail -n 1 "$WORK/err" >"$WORK/got-usage"
if cmp -s "$WORK/want-usage" "$WORK/got-usage"; then
	pass 'missing width argument prints usage'
else
	fail 'missing width argument prints usage' 'usage line did not match'
fi

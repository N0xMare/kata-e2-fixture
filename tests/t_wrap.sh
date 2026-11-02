# wrap

run 'the quick brown fox jumps over the lazy dog\n' wrap -w 10
check 'greedily fills lines' 0 'the quick\nbrown fox\njumps over\nthe lazy\ndog\n'

run 'aaaa bbbbb\n' wrap -w 10
check 'fits an exactly full line' 0 'aaaa bbbbb\n'

run 'aaaa bbbbb\n' wrap -w 9
check 'moves a word when it exceeds width' 0 'aaaa\nbbbbb\n'

run 'a supercalifragilistic b\n' wrap -w 5
check 'leaves long words unbroken' 0 'a\nsupercalifragilistic\nb\n'

run '  lots   of\t\tspace  \n' wrap
check 'collapses spaces and tabs' 0 'lots of space\n'

run '\n\none\ntwo\n\n \n\t\nthree\n\n\n' wrap
check 'separates paragraphs with one blank line' 0 'one two\n\nthree\n'

run 'last line' wrap -w 4
check 'terminates an unterminated final line' 0 'last\nline\n'

run '' wrap
check 'empty input prints nothing' 0 ''

run ' \n\t\n\n' wrap
check 'blank-only input prints nothing' 0 ''

_many='word'
_i=1
while [ "$_i" -lt 30 ]; do _many="$_many word"; _i=$((_i + 1)); done
run "$_many\n" wrap
check 'default width is 72' 0 'word word word word word word word word word word word word word word\nword word word word word word word word word word word word word word\nword word\n'

run 'a b c\n' wrap -w3
check 'accepts attached width argument' 0 'a b\nc\n'

printf 'alpha' >"$WORK/wrap-f1"
printf 'beta\n' >"$WORK/wrap-f2"
run '' wrap "$WORK/wrap-f1" "$WORK/wrap-f2"
check 'joins files as one input stream' 0 'alpha beta\n'

for _bad in 0 07 -3 +5 abc 5x ''; do
	run 'a\n' wrap -w "$_bad"
	check_error "rejects invalid width '$_bad'" 2 "linekit: wrap: invalid width: $_bad"
	_line2=$(sed -n '2p' "$WORK/err")
	[ "$_line2" = 'usage: linekit wrap [-w WIDTH] [FILE...]' ] || fail "invalid width '$_bad' prints usage" 'wrong second stderr line'
done

run '' wrap -w
check_error 'reports missing width argument' 2 'linekit: wrap: missing argument for -w'
_line2=$(sed -n '2p' "$WORK/err")
[ "$_line2" = 'usage: linekit wrap [-w WIDTH] [FILE...]' ] || fail 'missing width argument prints usage' 'wrong second stderr line'

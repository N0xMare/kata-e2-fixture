# wrap

run 'the quick brown fox jumps over the lazy dog\n' wrap -w 10
check 'A1 greedy width 10' 0 'the quick\nbrown fox\njumps over\nthe lazy\ndog\n'

run 'aaaa bbbbb\n' wrap -w 10
check 'A2 exact fit' 0 'aaaa bbbbb\n'

run 'aaaa bbbbb\n' wrap -w 9
check 'A3 boundary overflow' 0 'aaaa\nbbbbb\n'

run 'a supercalifragilistic b\n' wrap -w 5
check 'A4 long word stays whole' 0 'a\nsupercalifragilistic\nb\n'

run '  lots   of\t\tspace  \n' wrap
check 'A5 whitespace is collapsed' 0 'lots of space\n'

run '\n\none\ntwo\n\n \n\t\nthree\n\n\n' wrap
check 'A6 paragraphs separated once' 0 'one two\n\nthree\n'

run 'last line' wrap -w 4
check 'A7 unterminated input line' 0 'last\nline\n'

run '' wrap
check 'A8 empty input' 0 ''

run ' \n\t\n\n' wrap
check 'A9 blank input' 0 ''

_words=
_i=0
while [ "$_i" -lt 30 ]; do _words="$_words${_words:+ }word"; _i=$((_i + 1)); done
run "$_words\n" wrap
check 'A10 default width' 0 'word word word word word word word word word word word word word word\nword word word word word word word word word word word word word word\nword word\n'

run 'a b c\n' wrap -w3
check 'A11 attached option argument' 0 'a b\nc\n'

printf 'alpha' >"$WORK/f1"
printf 'beta\n' >"$WORK/f2"
run '' wrap "$WORK/f1" "$WORK/f2"
check 'A12 files form one stream' 0 'alpha beta\n'

for _bad in 0 07 -3 abc 5x ''; do
	# Empty width is passed as the argument following -w.
	run 'a\n' wrap -w "$_bad"
	check_error "A13 invalid width $_bad" 2 "linekit: wrap: invalid width: $_bad"
done

run '' wrap -w
check_error 'A14 missing width argument' 2 'linekit: wrap: missing argument for -w'
# end of t_wrap

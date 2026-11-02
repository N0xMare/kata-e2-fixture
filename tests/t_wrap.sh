# wrap

run 'the quick brown fox jumps over the lazy dog\n' wrap -w 10
check 'A1 greedy fill' 0 'the quick\nbrown fox\njumps over\nthe lazy\ndog\n'

run 'aaaa bbbbb\n' wrap -w 10
check 'A2 exact width' 0 'aaaa bbbbb\n'

run 'aaaa bbbbb\n' wrap -w 9
check 'A3 exceeding width' 0 'aaaa\nbbbbb\n'

run 'a supercalifragilistic b\n' wrap -w 5
check 'A4 long word remains intact' 0 'a\nsupercalifragilistic\nb\n'

run '  lots   of\t\tspace  \n' wrap
check 'A5 normalize whitespace' 0 'lots of space\n'

run '\n\none\ntwo\n\n \n\t\nthree\n\n\n' wrap
check 'A6 paragraphs' 0 'one two\n\nthree\n'

run 'last line' wrap -w 4
check 'A7 final unterminated line' 0 'last\nline\n'

run '' wrap
check 'A8 empty input' 0 ''

run ' \n\t\n\n' wrap
check 'A9 blank input' 0 ''

_many=
_i=0
while [ "$_i" -lt 30 ]; do _many="$_many${_many:+ }word"; _i=$((_i + 1)); done
run "$_many\n" wrap
check 'A10 default width' 0 'word word word word word word word word word word word word word word\nword word word word word word word word word word word word word word\nword word\n'

run 'a b c\n' wrap -w3
check 'A11 attached width option' 0 'a b\nc\n'

printf 'alpha' >"$WORK/wrap-f1"
printf 'beta\n' >"$WORK/wrap-f2"
run '' wrap "$WORK/wrap-f1" "$WORK/wrap-f2"
check 'A12 files form one stream' 0 'alpha beta\n'

for _width in 0 07 -3 abc 5x ''; do
	run 'a\n' wrap -w "$_width"
	check_error "A13 invalid width $_width" 2 "linekit: wrap: invalid width: $_width"
done

run '' wrap -w
check_error 'A14 missing width' 2 'linekit: wrap: missing argument for -w'

# end of t_wrap

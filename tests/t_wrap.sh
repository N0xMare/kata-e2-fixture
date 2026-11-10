# wrap

U='usage: linekit wrap [-w WIDTH] [FILE...]'

run 'the quick brown fox jumps over the lazy dog\n' wrap -w 10
check 'A1 fills greedily to the width' 0 'the quick\nbrown fox\njumps over\nthe lazy\ndog\n'

run 'aaaa bbbbb\n' wrap -w 10
check 'A2 a line of exactly the width fits' 0 'aaaa bbbbb\n'

run 'aaaa bbbbb\n' wrap -w 9
check 'A3 one byte over the width breaks' 0 'aaaa\nbbbbb\n'

run 'a supercalifragilistic b\n' wrap -w 5
check 'A4 a long word sits alone, unbroken' 0 'a\nsupercalifragilistic\nb\n'

run '  lots   of\t\tspace  \n' wrap
check 'A5 blanks are collapsed and trimmed' 0 'lots of space\n'

run '\n\none\ntwo\n\n \n\t\nthree\n\n\n' wrap
check 'A6 paragraphs are separated by one empty line' 0 'one two\n\nthree\n'

run 'last line' wrap -w 4
check 'A7 a final line without newline is terminated' 0 'last\nline\n'

run '' wrap
check 'A8 empty input prints nothing' 0 ''

run ' \n\t\n\n' wrap
check 'A9 blank-only input prints nothing' 0 ''

_w='word word word word word word word word word word word word word word'
run "$_w $_w word word\n" wrap
check 'A10 default width is 72' 0 "$_w\n$_w\nword word\n"

run 'a b c\n' wrap -w3
check 'A11 -wWIDTH is accepted' 0 'a b\nc\n'

printf 'alpha' >"$WORK/wrap-1"
printf 'beta\n' >"$WORK/wrap-2"
run '' wrap "$WORK/wrap-1" "$WORK/wrap-2"
check 'A12 files are one stream of words' 0 'alpha beta\n'

for _bad in 0 07 -3 +5 abc 5x ''; do
	run 'a\n' wrap -w "$_bad"
	check_error "A13 invalid width '$_bad'" 2 "linekit: wrap: invalid width: $_bad"
	_l2=$(sed -n 2p "$WORK/err")
	if [ "$_l2" = "$U" ]; then
		pass "A13 usage line follows for '$_bad'"
	else
		fail "A13 usage line follows for '$_bad'" "want second stderr line: $U"
	fi
done

run '' wrap -w
check_error 'A14 -w without an argument is a usage error' 2 'linekit: wrap: missing argument for -w'

run '' wrap -h
check '-h prints the usage line' 0 "$U\n"

run '' wrap -Z
check_error 'unknown option' 2 'linekit: wrap: unknown option: -Z'

run 'a b c\n' wrap -w 1
check 'width 1 puts each word on its own line' 0 'a\nb\nc\n'

run 'a\n\n\nb\n' wrap -w 100
check 'paragraphs stay separate' 0 'a\n\nb\n'

run 'a\nb\nc\n' wrap -w 5
check 'lines of a paragraph are joined' 0 'a b c\n'

run 'x y\n' wrap -w 3 -
check '- reads standard input' 0 'x y\n'

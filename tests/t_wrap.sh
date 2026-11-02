# wrap

run 'the quick brown fox jumps over the lazy dog\n' wrap -w 10
check 'wraps greedily at width 10' 0 'the quick\nbrown fox\njumps over\nthe lazy\ndog\n'

run 'aaaa bbbbb\n' wrap -w 10
check 'fits exactly at width 10' 0 'aaaa bbbbb\n'

run 'aaaa bbbbb\n' wrap -w 9
check 'breaks when the next word exceeds width' 0 'aaaa\nbbbbb\n'

run 'a supercalifragilistic b\n' wrap -w 5
check 'leaves an overlong word unbroken' 0 'a\nsupercalifragilistic\nb\n'

run '  lots   of\t\tspace  \n' wrap
check 'normalizes spaces, tabs, and indentation' 0 'lots of space\n'

run '\n\none\ntwo\n\n \n\t\nthree\n\n\n' wrap
check 'normalizes paragraph separators' 0 'one two\n\nthree\n'

run 'last line' wrap -w 4
check 'terminates an unterminated input line' 0 'last\nline\n'

run '' wrap
check 'empty input prints nothing' 0 ''

run ' \n\t\n\n' wrap
check 'blank-only input prints nothing' 0 ''

run 'word word word word word word word word word word word word word word word word word word word word word word word word word word word word word word\n' wrap
check 'wraps thirty default width words' 0 'word word word word word word word word word word word word word word\nword word word word word word word word word word word word word word\nword word\n'

run 'a b c\n' wrap -w3
check 'accepts attached option argument' 0 'a b\nc\n'

printf 'alpha' >"$WORK/f1"
printf 'beta\n' >"$WORK/f2"
run '' wrap "$WORK/f1" "$WORK/f2"
check 'joins multiple files as one stream' 0 'alpha beta\n'

for _bad_width in 0 07 -3 abc 5x ''; do
	run 'a\n' wrap -w "$_bad_width"
	check_error "rejects width '$_bad_width'" 2 "linekit: wrap: invalid width: $_bad_width"
done

run '' wrap -w
check_error 'reports missing width argument' 2 'linekit: wrap: missing argument for -w'

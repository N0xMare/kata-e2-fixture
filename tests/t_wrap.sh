# wrap

run 'the quick brown fox jumps over the lazy dog\n' wrap -w 10
check 'wraps words greedily' 0 'the quick\nbrown fox\njumps over\nthe lazy\ndog\n'

run 'aaaa bbbbb\n' wrap -w 10
check 'fits exact width' 0 'aaaa bbbbb\n'

run 'aaaa bbbbb\n' wrap -w 9
check 'breaks over width' 0 'aaaa\nbbbbb\n'

run 'a supercalifragilistic b\n' wrap -w 5
check 'leaves long words unbroken' 0 'a\nsupercalifragilistic\nb\n'

run '  lots   of\t\tspace  \n' wrap
check 'normalizes spaces and tabs' 0 'lots of space\n'

run '\n\none\ntwo\n\n \n\t\nthree\n\n\n' wrap
check 'separates paragraphs once' 0 'one two\n\nthree\n'

run 'last line' wrap -w 4
check 'handles unterminated input' 0 'last\nline\n'

run '' wrap
check 'empty input' 0 ''

run ' \n\t\n\n' wrap
check 'blank input' 0 ''

run 'word word word word word word word word word word word word word word word word word word word word word word word word word word word word word word\n' wrap
check 'fills default width' 0 'word word word word word word word word word word word word word word\nword word word word word word word word word word word word word word\nword word\n'

run 'a b c\n' wrap -w3
check 'accepts attached option argument' 0 'a b\nc\n'

printf 'alpha' >"$WORK/f1"
printf 'beta\n' >"$WORK/f2"
run '' wrap "$WORK/f1" "$WORK/f2"
check 'joins files as one stream' 0 'alpha beta\n'

for _width in 0 07 -3 abc 5x ''; do
	run 'a\n' wrap -w "$_width"
	check_error "rejects width $_width" 2 "linekit: wrap: invalid width: $_width"
	if [ "$(sed -n '2p' "$WORK/err")" = 'usage: linekit wrap [-w WIDTH] [FILE...]' ]; then
		pass "invalid width $_width prints usage"
	else
		fail "invalid width $_width prints usage" 'missing usage line on stderr'
	fi
done

run '' wrap -w
check_error 'reports missing width' 2 'linekit: wrap: missing argument for -w'
if [ "$(sed -n '2p' "$WORK/err")" = 'usage: linekit wrap [-w WIDTH] [FILE...]' ]; then
	pass 'missing width prints usage'
else
	fail 'missing width prints usage' 'missing usage line on stderr'
fi

run '' wrap -h
check 'help prints usage' 0 'usage: linekit wrap [-w WIDTH] [FILE...]\n'

run '' wrap -z
check_error 'unknown option' 2 'linekit: wrap: unknown option: -z'

run '' wrap "$WORK/no-such-file"
check_error 'unreadable file' 1 "linekit: wrap: $WORK/no-such-file: cannot read"

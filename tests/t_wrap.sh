# wrap

run 'the quick brown fox jumps over the lazy dog\n' wrap -w 10
check 'fills words greedily at width 10' 0 'the quick\nbrown fox\njumps over\nthe lazy\ndog\n'

run 'aaaa bbbbb\n' wrap -w 10
check 'fits a word when the joined line equals width' 0 'aaaa bbbbb\n'

run 'aaaa bbbbb\n' wrap -w 9
check 'starts a new line when the joined words exceed width' 0 'aaaa\nbbbbb\n'

run 'a supercalifragilistic b\n' wrap -w 5
check 'leaves a word longer than width unbroken' 0 'a\nsupercalifragilistic\nb\n'

run '  lots   of\t\tspace  \n' wrap
check 'normalizes indentation and whitespace between words' 0 'lots of space\n'

run '\n\none\ntwo\n\n \n\t\nthree\n\n\n' wrap
check 'joins wrapped lines and separates paragraphs once' 0 'one two\n\nthree\n'

run 'last line' wrap -w 4
check 'handles a final input line without newline' 0 'last\nline\n'

run '' wrap
check 'empty input prints nothing' 0 ''

run ' \n\t\n\n' wrap
check 'blank-only input prints nothing' 0 ''

_thirty_words='word word word word word word word word word word word word word word word word word word word word word word word word word word word word word word'
run "$_thirty_words\n" wrap
check 'default width fills thirty words over three lines' 0 'word word word word word word word word word word word word word word\nword word word word word word word word word word word word word word\nword word\n'

run 'a b c\n' wrap -w3
check 'accepts an attached width argument' 0 'a b\nc\n'

printf 'alpha' >"$WORK/wrap-1"
printf 'beta\n' >"$WORK/wrap-2"
run '' wrap "$WORK/wrap-1" "$WORK/wrap-2"
check 'continues a paragraph across files' 0 'alpha beta\n'

for _bad_width in 0 07 -3 abc 5x ''; do
	run 'a\n' wrap -w "$_bad_width"
	check_error "rejects invalid width '$_bad_width'" 2 "linekit: wrap: invalid width: $_bad_width"
	# Also require the usage line after the invalid-width diagnostic.
	if [ "$(sed -n '2p' "$WORK/err")" = 'usage: linekit wrap [-w WIDTH] [FILE...]' ]; then
		pass "invalid width '$_bad_width' prints usage"
	else
		fail "invalid width '$_bad_width' prints usage" 'usage line missing from stderr'
	fi
done

run '' wrap -w
check_error 'missing width argument is a usage error' 2 'linekit: wrap: missing argument for -w'

run '' wrap -x
check_error 'unknown option is a usage error' 2 'linekit: wrap: unknown option: -x'

run '' wrap -h
check '-h prints usage' 0 'usage: linekit wrap [-w WIDTH] [FILE...]\n'

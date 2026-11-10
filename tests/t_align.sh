# align

_usage='usage: linekit align [-H] [-s SEP] [FILE...]'

run 'a bb ccc\ndddd e f\n' align
check 'B1 left-aligned columns' 0 'a     bb  ccc\ndddd  e   f\n'

run 'x 5\ny 120\n' align
check 'B2 numeric column right-aligned' 0 'x    5\ny  120\n'

run 'x -1.5\ny 20\n' align
check 'B3 negative and decimal numbers' 0 'x  -1.5\ny    20\n'

run 'n 1\nm xyz\n' align
check 'B4 mixed column is left-aligned' 0 'n  1\nm  xyz\n'

run 'a b\n\n  \ncc d\n' align
check 'B5 blank lines stay empty' 0 'a   b\n\n\ncc  d\n'

run 'a b c\nd\n' align
check 'B6 short rows print their cells only' 0 'a  b  c\nd\n'

run 'item qty\napple 3\nfig 12\n' align -H
check 'B7 header with numeric column' 0 'item   qty\napple    3\nfig     12\n'

run 'a,,b\nccc,d,e\n' align -s ,
check 'B8 separator with empty cell' 0 'a       b\nccc  d  e\n'

run ' a : b \n' align -s :
check 'B9 cells are trimmed' 0 'a  b\n'

run 'a\n' align -s ab
check_error 'B10 long separator' 2 'linekit: align: invalid separator: ab'
if [ "$(sed -n 2p "$WORK/err")" = "$_usage" ]; then
	pass 'B10 usage line follows'
else
	fail 'B10 usage line follows' 'want usage on stderr line 2'
fi

run 'a\n' align -s ''
check_error 'empty separator' 2 'linekit: align: invalid separator: '

run '' align -s
check_error 'B11 -s without an argument' 2 'linekit: align: missing argument for -s'

run '' align
check 'B12 empty input' 0 ''

run '+5 1\n.5 2\n' align
check 'non-numeric forms left-align' 0 '+5  1\n.5  2\n'

run 'a 007\nb 1.5\nc -2\n' align
check '007 and -2 are numeric' 0 'a  007\nb  1.5\nc   -2\n'

run 'a 5.\nb 12\n' align
check '5. is not numeric' 0 'a  5.\nb  12\n'

run 'a 1e3\nb 12\n' align
check '1e3 is not numeric' 0 'a  1e3\nb  12\n'

run 'a 1,000\nb 12\n' align
check '1,000 is not numeric' 0 'a  1,000\nb  12\n'

run 'a b c\nd e f\n' align -s ' '
check '-s space is literal' 0 'a  b  c\nd  e  f\n'

run 'a  b\n' align -s ' '
check '-s space makes an empty cell' 0 'a    b\n'

run 'a.b.c\nxx.y.z\n' align -s .
check '-s . is literal' 0 'a   b  c\nxx  y  z\n'

run '7\n\n100\n' align
check 'leading padding kept' 0 '  7\n\n100\n'

run '\n\nh1 h2\nx 5\n' align -H
check 'header is the first non-blank row' 0 '\n\nh1  h2\nx    5\n'

run 'a\n' align -s '\'
check 'backslash separator is accepted' 0 'a\n'

run 'a\\b\n' align -s '\'
check 'backslash separator is literal' 0 'a  b\n'
# end of t_align

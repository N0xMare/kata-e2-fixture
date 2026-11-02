# align

run 'a bb ccc\ndddd e f\n' align
check 'B1 left aligned columns' 0 'a     bb  ccc\ndddd  e   f\n'

run 'x 5\ny 120\n' align
check 'B2 numeric right alignment' 0 'x    5\ny  120\n'

run 'x -1.5\ny 20\n' align
check 'B3 numeric decimals' 0 'x  -1.5\ny    20\n'

run 'n 1\nm xyz\n' align
check 'B4 mixed numeric column' 0 'n  1\nm  xyz\n'

run 'a b\n\n  \ncc d\n' align
check 'B5 blank rows preserved' 0 'a   b\n\n\ncc  d\n'

run 'a b c\nd\n' align
check 'B6 ragged rows' 0 'a  b  c\nd\n'

run 'item qty\napple 3\nfig 12\n' align -H
check 'B7 header ignored for numeric type' 0 'item   qty\napple    3\nfig     12\n'

run 'a,,b\nccc,d,e\n' align -s ,
check 'B8 literal separator' 0 'a       b\nccc  d  e\n'

run ' a : b \n' align -s :
check 'B9 trim separated cells' 0 'a  b\n'

run 'a\n' align -s ab
check_error 'B10 invalid separator' 2 'linekit: align: invalid separator: ab'

run '' align -s
check_error 'B11 missing separator' 2 'linekit: align: missing argument for -s'

run '' align
check 'B12 empty input' 0 ''

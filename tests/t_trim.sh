# trim

run '  a b  \n\tc\t\n' trim
check 'strips leading and trailing blanks' 0 'a b\nc\n'

run 'a  \t b\n' trim
check 'keeps inner blanks' 0 'a  \t b\n'

run ' \n\t\n' trim
check 'blank lines become empty lines' 0 '\n\n'

run '' trim
check 'no input prints nothing' 0 ''

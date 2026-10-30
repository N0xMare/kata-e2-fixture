# number

run 'a\nb\n' number
check 'numbers lines with a tab' 0 '1\ta\n2\tb\n'

run 'a\n\nb' number
check 'numbers empty lines and a final line without newline' 0 '1\ta\n2\t\n3\tb\n'

run 'a\nb\n' number -s :
check '-s sets the separator' 0 '1:a\n2:b\n'

run 'a\n' number -s=
check '-sSEP is accepted' 0 '1=a\n'

printf 'x\n' >"$WORK/number-1"
run 'y\n' number "$WORK/number-1" -
check 'numbers run on across files' 0 '1\tx\n2\ty\n'

run '' number -s
check_error '-s without an argument is a usage error' 2 'linekit: number: missing argument for -s'

run '' number
check 'no input prints nothing' 0 ''

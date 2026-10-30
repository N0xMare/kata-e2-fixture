# count

run '' count
check 'no input counts 0' 0 '0\n'

run 'a\nb\n' count
check 'counts lines' 0 '2\n'

run 'a\nb' count
check 'counts a final line without a newline' 0 '2\n'

run '\n\n\n' count
check 'counts empty lines' 0 '3\n'

printf 'a\nb\n' >"$WORK/count-1"
printf 'c' >"$WORK/count-2"
run '' count "$WORK/count-1" "$WORK/count-2"
check 'counts across files' 0 '3\n'

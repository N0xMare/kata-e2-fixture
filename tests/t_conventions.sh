# The conventions every command follows (README.md, "Conventions"). Every
# command `linekit --list` names is enrolled, so a new command is checked
# here without editing this file.

run '' --list
_commands=
while IFS= read -r _c; do
	_commands="$_commands $_c"
done <"$WORK/out"

printf 'x\n' >"$WORK/conv-file"

for _c in $_commands; do
	run '' "$_c" -h
	check_first "$_c -h prints its usage on stdout" 0 "usage: linekit $_c "

	run '' "$_c" -Z
	check_error "$_c rejects an unknown option" 2 "linekit: $_c: unknown option: -Z"

	run '' "$_c" "$WORK/no-such-file"
	check_error "$_c refuses a missing file" 1 "linekit: $_c: $WORK/no-such-file: cannot read"

	run '' "$_c" "$WORK"
	check_error "$_c refuses a directory" 1 "linekit: $_c: $WORK: cannot read"

	run 'x' "$_c"
	check_terminated "$_c ends a final line that lacked a newline"

	run '' "$_c" "$WORK/conv-file"
	check_terminated "$_c reads a FILE operand"

	run 'x\n' "$_c" -
	check_terminated "$_c reads - as standard input"
done

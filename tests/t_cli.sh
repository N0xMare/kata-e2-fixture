# The top-level command line: no command, unknown commands and options,
# --help, --list and --version.

run ''
check_error 'no command is a usage error' 2 'linekit: missing command'

run '' frobnicate
check_error 'an unknown command is a usage error' 2 'linekit: unknown command: frobnicate'

run '' --frobnicate
check_error 'an unknown option is a usage error' 2 'linekit: unknown option: --frobnicate'

run '' --help
check_first '--help prints the usage on stdout' 0 'usage: linekit COMMAND [OPTIONS] [FILE...]'

run '' --version
check '--version prints the version' 0 'linekit 0.3.0\n'

# --list names exactly the lib/cmd_*.sh files, in glob order.
_want=
for _f in "$LK_ROOT"/lib/cmd_*.sh; do
	_f=${_f##*/cmd_}
	_want="$_want${_f%.sh}\\n"
done
run '' --list
check '--list names every lib/cmd_*.sh' 0 "$_want"

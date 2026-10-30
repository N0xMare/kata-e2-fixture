# Shared helpers for linekit. Sourced by bin/linekit, so every function runs
# in the main shell and `exit` ends the whole command.

LK_VERSION=0.3.0

lk_usage() {
	printf 'usage: linekit COMMAND [OPTIONS] [FILE...]\n'
	printf '       linekit --list | --version | --help\n'
	printf 'commands:'
	for _c in $(lk_commands); do
		printf ' %s' "$_c"
	done
	printf '\n'
}

# lk_commands: every command, one per line: the NAME of each lib/cmd_NAME.sh.
lk_commands() {
	for _f in "$LK_ROOT"/lib/cmd_*.sh; do
		[ -f "$_f" ] || continue
		_f=${_f##*/cmd_}
		printf '%s\n' "${_f%.sh}"
	done
}

lk_is_command() {
	case $1 in
	'' | *[!a-z0-9_]*) return 1 ;;
	esac
	[ -f "$LK_ROOT/lib/cmd_$1.sh" ]
}

# lk_usage_error CMD MESSAGE: report a usage error, then CMD's usage, on
# stderr, and exit 2.
lk_usage_error() {
	printf 'linekit: %s: %s\n' "$1" "$2" >&2
	"usage_$1" >&2
	exit 2
}

# The two getopts failures, for an option string that starts with ':'.
lk_bad_option() { lk_usage_error "$1" "unknown option: -$2"; }
lk_missing_argument() { lk_usage_error "$1" "missing argument for -$2"; }

# lk_check_files CMD FILE...: exit 1 unless every FILE is readable and not a
# directory. `-` is standard input and always passes.
lk_check_files() {
	_cmd=$1
	shift
	for _f in "$@"; do
		[ "$_f" = - ] && continue
		if [ -d "$_f" ] || [ ! -r "$_f" ]; then
			printf 'linekit: %s: %s: cannot read\n' "$_cmd" "$_f" >&2
			exit 1
		fi
	done
}

lk_main() {
	if [ $# -eq 0 ]; then
		printf 'linekit: missing command\n' >&2
		lk_usage >&2
		exit 2
	fi
	case $1 in
	-h | --help)
		lk_usage
		exit 0
		;;
	--list)
		lk_commands
		exit 0
		;;
	--version)
		printf 'linekit %s\n' "$LK_VERSION"
		exit 0
		;;
	-*)
		printf 'linekit: unknown option: %s\n' "$1" >&2
		lk_usage >&2
		exit 2
		;;
	esac
	if ! lk_is_command "$1"; then
		printf 'linekit: unknown command: %s\n' "$1" >&2
		lk_usage >&2
		exit 2
	fi
	_cmd=$1
	shift
	"cmd_$_cmd" "$@"
}

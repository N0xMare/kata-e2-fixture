#!/bin/sh
# linekit's test runner:   sh tests/check.sh [SUITE...]
#
# Runs every tests/t_*.sh suite, or only the named ones (`t_trim` or
# `tests/t_trim.sh`), each in its own subshell. Prints one line per test, then
# the names of the failed tests (if any), then a one-line summary, so the last
# lines of the output always name what failed. Exits 0 only when every test
# passed, every suite ran to its end, and at least one test ran.
#
# The tree may be READ-ONLY while this runs. Suites write only under $WORK, a
# fresh directory under ${TMPDIR:-/tmp} that is removed at exit. They run
# linekit as `sh "$LINEKIT" ...` (through the helpers below) and use only
# POSIX utilities.

set -u

LK_TESTS=${0%/*}
[ "$LK_TESTS" = "$0" ] && LK_TESTS=.
LK_TESTS=$(CDPATH= cd -P -- "$LK_TESTS" && pwd) || exit 2
LK_ROOT=${LK_TESTS%/*}
LINEKIT=$LK_ROOT/bin/linekit

umask 077
if ! WORK=$(mktemp -d "${TMPDIR:-/tmp}/linekit-check.XXXXXX"); then
	printf 'check.sh: cannot create a work directory under %s\n' "${TMPDIR:-/tmp}" >&2
	exit 2
fi
trap 'rm -rf "$WORK"' EXIT
trap 'exit 130' HUP INT TERM
: >"$WORK/results"

# run STDIN [ARG...]: run linekit with ARGs. STDIN is a printf FORMAT for its
# standard input ('' for none). Sets $status; output lands in $WORK/out and
# $WORK/err.
run() {
	printf "$1" >"$WORK/in"
	shift
	sh "$LINEKIT" "$@" <"$WORK/in" >"$WORK/out" 2>"$WORK/err"
	status=$?
}

pass() {
	printf 'ok   %s: %s\n' "$SUITE" "$1"
	printf 'ok\n' >>"$WORK/results"
}

# fail NAME WHY: report a failed test with the last run's output, made
# visible by `sed -n l` (a tab shows as \t, every line end as $).
fail() {
	printf 'FAIL %s: %s\n' "$SUITE" "$1"
	printf '     %s\n' "$2"
	printf '     got status %s, stdout:\n' "$status"
	sed -n 'l' "$WORK/out" | sed 's/^/       /'
	printf '     stderr:\n'
	sed -n 'l' "$WORK/err" | sed 's/^/       /'
	printf 'fail %s: %s\n' "$SUITE" "$1" >>"$WORK/results"
}

# check NAME STATUS STDOUT: the last run exited STATUS and printed exactly
# STDOUT (a printf FORMAT) on stdout.
check() {
	printf "$3" >"$WORK/want"
	if [ "$status" -eq "$2" ] && cmp -s "$WORK/want" "$WORK/out"; then
		pass "$1"
	else
		fail "$1" "want status $2, stdout: $3"
	fi
}

# check_error NAME STATUS LINE: the last run exited STATUS, printed nothing on
# stdout, and its first stderr line is exactly LINE (a literal string).
check_error() {
	_line=
	IFS= read -r _line <"$WORK/err" || :
	if [ "$status" -eq "$2" ] && [ ! -s "$WORK/out" ] && [ "$_line" = "$3" ]; then
		pass "$1"
	else
		fail "$1" "want status $2, empty stdout, first stderr line: $3"
	fi
}

# check_first NAME STATUS PREFIX: the last run exited STATUS and the first
# stdout line starts with PREFIX (a literal string).
check_first() {
	_line=
	IFS= read -r _line <"$WORK/out" || :
	case $_line in
	"$3"*) [ "$status" -eq "$2" ] && pass "$1" && return ;;
	esac
	fail "$1" "want status $2, first stdout line starting: $3"
}

# check_terminated NAME: the last run exited 0 and its stdout is non-empty and
# ends with a newline.
check_terminated() {
	if [ "$status" -eq 0 ] && [ -s "$WORK/out" ] && [ -z "$(tail -c 1 "$WORK/out")" ]; then
		pass "$1"
	else
		fail "$1" "want status 0 and non-empty stdout ending in a newline"
	fi
}

[ $# -gt 0 ] || set -- "$LK_TESTS"/t_*.sh
for _suite in "$@"; do
	case $_suite in
	*/*) ;;
	*) _suite=$LK_TESTS/${_suite%.sh}.sh ;;
	esac
	if [ ! -f "$_suite" ]; then
		printf 'check.sh: no such suite: %s\n' "$_suite" >&2
		exit 2
	fi
	SUITE=${_suite##*/}
	SUITE=${SUITE%.sh}
	(
		. "$_suite"
		: >"$WORK/ended.$SUITE"
	)
	if [ ! -f "$WORK/ended.$SUITE" ]; then
		printf 'FAIL %s: the suite exited before its end\n' "$SUITE"
		printf 'fail %s: the suite exited before its end\n' "$SUITE" >>"$WORK/results"
	fi
done

passed=0
failed=0
while IFS= read -r _r; do
	case $_r in
	ok) passed=$((passed + 1)) ;;
	*)
		failed=$((failed + 1))
		[ "$failed" -eq 1 ] && printf 'failed tests:\n'
		if [ "$failed" -le 20 ]; then
			printf '  %s\n' "${_r#fail }"
		fi
		;;
	esac
done <"$WORK/results"
[ "$failed" -gt 20 ] && printf '  ... and %d more\n' "$((failed - 20))"

printf 'linekit tests: %d passed, %d failed, %d suites\n' "$passed" "$failed" "$#"
[ "$failed" -eq 0 ] && [ "$passed" -gt 0 ]

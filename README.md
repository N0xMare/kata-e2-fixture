# linekit

linekit is a small set of line-oriented text tools written in POSIX shell
and awk. It is a throwaway fixture repository for kata's evidence runs: a
small, dependency-free project with a fast test suite. It is not maintained
for any other use.

## Usage

```sh
sh bin/linekit COMMAND [OPTIONS] [FILE...]
sh bin/linekit --list | --version | --help
```

| command   | what it does                                                       |
|-----------|--------------------------------------------------------------------|
| `count`   | print the number of input lines                                    |
| `number`  | prefix each line with its number and a separator (`-s SEP`, default a tab; `-n START`, default 1) |
| `squeeze` | replace each run of blank lines with one empty line                |
| `trim`    | remove leading and trailing blanks (spaces and tabs) from each line |

## Conventions

Every command follows these rules. `tests/t_conventions.sh` checks them for
every command that `linekit --list` names.

- **Input.** With no FILE, or with `-` as a FILE, a command reads standard
  input. Several FILEs are read in order as one stream of lines. A final line
  that lacks a newline is still a line, and its output line ends with one.
- **Options** are parsed with `getopts`, so `-s :` and `-s:` are the same.
  `-h` prints the command's usage line (`usage: linekit NAME ...`) on
  standard output and exits 0.
- **Exit status.** 0 on success. 1 when a FILE cannot be read (a missing file
  or a directory): `linekit: NAME: FILE: cannot read` on standard error. 2 for
  a usage error (an unknown option, a missing or invalid option argument):
  `linekit: NAME: MESSAGE` and then the usage line on standard error. On an
  error nothing is printed on standard output. The helpers in
  `lib/common.sh` (`lk_bad_option`, `lk_missing_argument`, `lk_usage_error`,
  `lk_check_files`) produce exactly these messages.
- **Text** is ASCII; a blank is a space or a tab; widths and lengths count
  bytes.

## Layout

- `bin/linekit`: the entry point. It sources `lib/common.sh` and every
  `lib/cmd_*.sh`.
- `lib/cmd_NAME.sh`: one command, defining `usage_NAME` and `cmd_NAME`.
  Adding the file adds the command.
- `tests/check.sh`: the test runner. `tests/t_*.sh`: one suite per command,
  plus `t_cli.sh` and `t_conventions.sh`.

## Tests

```sh
sh tests/check.sh            # every suite
sh tests/check.sh t_trim     # one suite
```

It prints one line per test, then the names of the failed tests, then a
one-line summary, and exits 0 only when every test passed. The suite must
stay runnable in a constrained sandbox:

- The source tree may be **read-only**. A test writes only under `$WORK`, a
  fresh directory under `${TMPDIR:-/tmp}` that the runner creates and removes.
  `HOME` may point at `/tmp`.
- Run linekit through the `run` helper (it uses `sh "$LINEKIT"`); do not rely
  on the `#!` line or on `/bin/sh` existing.
- Use only POSIX shell and utilities that BusyBox also provides (`awk`, `sed`,
  `tr`, `cmp`, `tail`, ...). No network, no other interpreters, few processes:
  the whole suite should finish in a few seconds.
- A new suite is a new `tests/t_NAME.sh`; the runner finds it by name.

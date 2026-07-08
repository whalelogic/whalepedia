# Bash — Comprehensive Quick Reference Guide

> A production-grounded reference for Bash syntax, built-in commands, expansions, operators, and idiomatic patterns. Covers Bash 5.x.

---

#### See [Quick Index](#15-quick-index) for a concise list of common syntax and commands.

## Table of Contents

1. [Special Variables](#1-special-variables)
2. [Parameter Expansion](#2-parameter-expansion)
3. [Arithmetic Expansion](#3-arithmetic-expansion)
4. [String Operations](#4-string-operations)
5. [Arrays & Associative Arrays](#5-arrays--associative-arrays)
6. [Control Flow](#6-control-flow)
7. [Functions](#7-functions)
8. [I/O Redirection & Pipes](#8-io-redirection--pipes)
9. [Built-in Commands](#9-built-in-commands)
10. [File & String Test Operators](#10-file--string-test-operators)
11. [Pattern Matching & Globbing](#11-pattern-matching--globbing)
12. [Trap & Signals](#12-trap--signals)
13. [Process Substitution & Subshells](#13-process-substitution--subshells)
14. [Common Idiomatic Patterns](#14-common-idiomatic-patterns)
15. [Quick Index](#15-quick-index)

---

## 1. Special Variables

Bash pre-defines a set of read-only and settable variables that carry shell state. These do not require declaration and are available in every script and interactive session.

---

### `$?` — Exit Status of Last Command

Holds the exit code of the most recently executed foreground command or pipeline. `0` means success; any non-zero value indicates failure.

```bash
grep "pattern" file.txt
if [ $? -ne 0 ]; then
    echo "Pattern not found"
fi

# Idiomatic alternative — test directly:
if ! grep -q "pattern" file.txt; then
    echo "Pattern not found"
fi
```

---

### `$$` — PID of Current Shell

Contains the process ID of the currently running shell. Commonly used to create unique temporary filenames within a script.

```bash
TMPFILE="/tmp/work.$$.tmp"
trap 'rm -f "$TMPFILE"' EXIT
```

---

### `$!` — PID of Last Background Process

Contains the PID of the most recently launched background job. Used to wait on or kill specific background processes.

```bash
long_running_task &
BG_PID=$!
# ... do other work ...
wait "$BG_PID" || echo "Background task failed"
```

---

### `$0` — Script Name

Contains the name of the shell script as invoked. Useful for generating usage messages.

```bash
usage() {
    echo "Usage: $0 [OPTIONS] "
    exit 1
}
```

---

### `$#` — Argument Count

The number of positional parameters (arguments) passed to the script or function, not counting `$0`.

```bash
if [ $# -lt 2 ]; then
    echo "Error: expected at least 2 arguments, got $#" >&2
    exit 1
fi
```

---

### `$@` — All Positional Parameters (Separate Words)

Expands to all positional parameters as separate, individually quoted strings. Always prefer `"$@"` over `$*` when forwarding arguments to preserve quoting.

```bash
# Correctly forwards all arguments, even those containing spaces
run_with_logging() {
    echo "Running: $*"
    "$@"
}
```

---

### `$*` — All Positional Parameters (Single Word)

Expands to all positional parameters as a single word joined by the first character of `IFS`. Inside double quotes, `"$*"` produces one string; `"$@"` produces separate strings.

```bash
# Join args with a comma separator using IFS
IFS=","
echo "CSV: $*"
unset IFS
```

---

### `$_` — Last Argument of Previous Command

Set to the last argument of the previous command. Also set to the absolute path of the shell or script on startup.

```bash
mkdir -p /tmp/myapp/logs
cd "$_"   # cd /tmp/myapp/logs
```

---

### `$-` — Current Shell Option Flags

Contains the option flags set in the current shell (e.g., `i` for interactive, `e` for errexit).

```bash
# Check if running interactively
[[ $- == *i* ]] && echo "Interactive shell"
```

---

### `$LINENO` — Current Line Number

Expands to the line number in the script where it appears. Invaluable for error messages in large scripts.

```bash
die() {
    echo "Error at line $LINENO: $1" >&2
    exit 1
}
```

---

### `$BASH_VERSION` / `$BASH_VERSINFO`

`$BASH_VERSION` is a string like `5.2.15(1)-release`. `$BASH_VERSINFO` is an array with version components.

```bash
echo "$BASH_VERSION"
echo "Major: ${BASH_VERSINFO[0]}, Minor: ${BASH_VERSINFO[1]}"
```

---

### `$RANDOM`

Returns a pseudo-random integer between 0 and 32767 each time it is referenced. Not cryptographically secure.

```bash
echo $((RANDOM % 100))     # random number 0–99
```

---

### `$IFS` — Internal Field Separator

Controls how Bash splits words after unquoted parameter expansion. Default value is `<space><tab><newline>`. Changing it affects `read`, `for`, and unquoted expansions.

```bash
# Parse a colon-delimited string
IFS=":" read -ra parts <<< "/usr/local/bin:/usr/bin:/bin"
for p in "${parts[@]}"; do echo "$p"; done
```

---

### `$OLDPWD` / `$PWD`

`$PWD` is the current working directory. `$OLDPWD` is the directory before the most recent `cd`. Used by `cd -`.

```bash
pushd /tmp
echo "$OLDPWD"   # previous directory
cd -             # returns to $OLDPWD
```

---

### `$SECONDS`

Number of seconds elapsed since the shell was started. Can be assigned to reset the counter.

```bash
SECONDS=0
sleep 2
echo "Elapsed: ${SECONDS}s"
```

---

### `$PIPESTATUS`

An array holding the exit statuses of all commands in the most recently executed pipeline.

```bash
cat file.txt | grep "foo" | wc -l
echo "cat:${PIPESTATUS[0]} grep:${PIPESTATUS[1]} wc:${PIPESTATUS[2]}"
```

---

### `$BASH_SOURCE` / `$FUNCNAME` / `$BASH_LINENO`

Arrays used for stack inspection. `$BASH_SOURCE` is the call stack of source file names; `$FUNCNAME` is the call stack of function names; `$BASH_LINENO` is the line numbers of each call.

```bash
stack_trace() {
    local i
    for ((i=1; i<${#FUNCNAME[@]}; i++)); do
        echo "  ${BASH_SOURCE[$i]}:${BASH_LINENO[$((i-1))]} in ${FUNCNAME[$i]}"
    done
}
```

---

## 2. Parameter Expansion

Parameter expansion transforms variable values at substitution time without invoking subshells. All forms are wrapped in `${ }`.

---

### `${var:-default}` — Use Default if Unset or Empty

Returns `default` if `var` is unset or empty. Does not assign `var`.

```bash
NAME="${1:-world}"
echo "Hello, ${NAME}!"
```

---

### `${var:=default}` — Assign Default if Unset or Empty

Returns `default` and assigns it to `var` if `var` is unset or empty. Cannot be used on positional parameters.

```bash
: "${TIMEOUT:=30}"   # set TIMEOUT to 30 if not already set
echo "Timeout: $TIMEOUT"
```

---

### `${var:+alternate}` — Use Alternate if Set

Returns `alternate` if `var` is set and non-empty; otherwise returns nothing. The inverse of `:-`.

```bash
echo "Debug mode: ${DEBUG:+enabled}"
```

---

### `${var:?error_message}` — Error if Unset or Empty

If `var` is unset or empty, prints `error_message` to stderr and exits the script. Used to enforce required variables.

```bash
DB_HOST="${DB_HOST:?DB_HOST must be set}"
API_KEY="${API_KEY:?API_KEY is required}"
```

---

### `${#var}` — String Length

Returns the length of the string value of `var`.

```bash
str="hello world"
echo "${#str}"   # 11
```

---

### `${var:offset}` / `${var:offset:length}` — Substring

Extracts a substring starting at `offset`. If `offset` is negative (with a space), it counts from the end.

```bash
str="hello world"
echo "${str:6}"      # "world"
echo "${str:0:5}"    # "hello"
echo "${str: -5}"    # "world" (negative offset)
```

---

### `${var#pattern}` / `${var##pattern}` — Strip Prefix

Removes the shortest (`#`) or longest (`##`) match of `pattern` from the beginning of the value.

```bash
path="/usr/local/bin/bash"
echo "${path#/*/}"     # "local/bin/bash"  (shortest)
echo "${path##/*/}"    # "bash"            (longest)

# Common usage: strip directory from path
filename="${path##*/}"  # "bash"
```

---

### `${var%pattern}` / `${var%%pattern}` — Strip Suffix

Removes the shortest (`%`) or longest (`%%`) match of `pattern` from the end of the value.

```bash
file="archive.tar.gz"
echo "${file%.*}"    # "archive.tar"   (shortest)
echo "${file%%.*}"   # "archive"       (longest)
```

---

### `${var/pattern/replacement}` / `${var//pattern/replacement}` — Substitution

Replaces the first (`/`) or all (`//`) occurrences of `pattern` with `replacement`. Use `/#` to anchor to the start and `/%` to anchor to the end.

```bash
str="foo bar foo baz"
echo "${str/foo/qux}"    # "qux bar foo baz"
echo "${str//foo/qux}"   # "qux bar qux baz"
echo "${str/#foo/qux}"   # "qux bar foo baz" (prefix match)
```

---

### `${var^}` / `${var^^}` / `${var,}` / `${var,,}` — Case Modification

Changes the case of the value. `^` uppercases the first character; `^^` uppercases all. `,` lowercases the first; `,,` lowercases all.

```bash
str="hELLO wORLD"
echo "${str^}"    # "HELLO wORLD"
echo "${str^^}"   # "HELLO WORLD"
echo "${str,}"    # "hELLO wORLD"
echo "${str,,}"   # "hello world"
```

---

### `${!prefix*}` — Variable Name Expansion

Expands to the names of all variables whose names begin with `prefix`. Useful for namespace inspection.

```bash
APP_HOST="localhost"
APP_PORT="8080"
APP_DEBUG="true"

for var in "${!APP_@}"; do
    echo "$var = ${!var}"
done
```

---

### `${!var}` — Indirect Expansion

Treats the value of `var` as the name of another variable and expands that variable.

```bash
ENV="PRODUCTION"
PRODUCTION_HOST="prod.example.com"
STAGING_HOST="staging.example.com"

echo "${!ENV_HOST}"  # expands PRODUCTION_HOST → "prod.example.com"
```

---

## 3. Arithmetic Expansion

---

### `$(( expression ))` — Arithmetic Expansion

Evaluates an integer arithmetic expression and substitutes the result. Supports standard C-style operators.

| Operator | Description |
|---|---|
| `+` `-` `*` `/` | Addition, subtraction, multiplication, integer division |
| `%` | Modulo |
| `**` | Exponentiation |
| `++` `--` | Pre/post increment/decrement |
| `&` `\|` `^` `~` | Bitwise AND, OR, XOR, NOT |
| `<<` `>>` | Bitwise left/right shift |
| `&&` `\|\|` `!` | Logical AND, OR, NOT |
| `? :` | Ternary conditional |

```bash
x=10
y=3
echo $(( x + y ))    # 13
echo $(( x / y ))    # 3  (integer division)
echo $(( x % y ))    # 1
echo $(( x ** 2 ))   # 100
echo $(( x > 5 ? 1 : 0 ))  # 1
```

---

### `(( expression ))` — Arithmetic Conditional

Evaluates arithmetic and returns exit status: `0` (true) if the result is non-zero, `1` (false) if zero. Used directly in `if` and `while` conditions.

```bash
count=5
if (( count > 3 )); then
    echo "Count exceeds threshold"
fi

# Increment in a loop
for (( i=0; i<10; i++ )); do
    echo "$i"
done
```

---

### `let` — Arithmetic Assignment

Evaluates arithmetic expressions and assigns to variables. Each argument is a separate expression. Largely superseded by `(( ))`.

```bash
let "x = 5 + 3"
let "x *= 2"
let "x++"
echo "$x"   # 18
```

---

## 4. String Operations

---

### `printf` — Formatted Output

More powerful than `echo`. Supports format specifiers, does not append a newline unless explicitly given `\n`, and is consistent across shells.

| Specifier | Description |
|---|---|
| `%s` | String |
| `%d` | Integer |
| `%f` | Floating point |
| `%05d` | Zero-padded integer |
| `%-10s` | Left-aligned, 10 chars wide |
| `%x` `%X` | Lowercase/uppercase hex |
| `%q` | Shell-quoted string |
| `%b` | Interpret backslash escapes |

```bash
printf "%-10s %5d\n" "item" 42
printf "%05d\n" 7          # "00007"
printf "%q\n" "hello world"  # 'hello world'
printf "%.2f\n" 3.14159    # "3.14"
```

---

### Here Document (`<<EOF`) — Multiline String Input

Feeds a multiline block of text to a command as stdin. The delimiter (`EOF`) signals the end of input. Using `<<-EOF` strips leading tabs for indented scripts.

```bash
cat <<EOF
Server: ${HOSTNAME}
Port:   ${PORT}
Mode:   ${MODE}
EOF

# Indented version (strips leading tabs, not spaces)
cat <<-EOF
    This line has leading tabs stripped.
    ${VAR} is expanded.
EOF

# Quoted delimiter disables all expansion
cat <<'EOF'
Literal: $NO_EXPANSION, $(no subshell)
EOF
```

---

### Here String (`<<<`) — Single-Line stdin Injection

Feeds a single string to a command as stdin without creating a subshell (unlike echo piping).

```bash
read first last <<< "John Doe"
echo "$first"   # John

# Avoid a subshell for simple word splitting
IFS=":" read -ra fields <<< "a:b:c"
```

---

## 5. Arrays & Associative Arrays

---

### Indexed Array Declaration & Assignment

```bash
# Declare (optional but explicit)
declare -a fruits

# Literal assignment
fruits=("apple" "banana" "cherry")

# Index assignment
fruits[3]="date"
fruits+=("elderberry")   # append
```

---

### Indexed Array Access

```bash
echo "${fruits[0]}"        # first element
echo "${fruits[-1]}"       # last element
echo "${fruits[@]}"        # all elements (separate words)
echo "${fruits[*]}"        # all elements (single word, joined by IFS[0])
echo "${#fruits[@]}"       # element count
echo "${!fruits[@]}"       # all indices
echo "${fruits[@]:1:2}"    # slice: 2 elements starting at index 1
```

---

### Indexed Array Iteration

```bash
for fruit in "${fruits[@]}"; do
    echo "$fruit"
done

# Iterate with indices
for i in "${!fruits[@]}"; do
    printf "%d: %s\n" "$i" "${fruits[$i]}"
done
```

---

### Associative Array Declaration & Assignment

Associative arrays require explicit `declare -A`. Keys are arbitrary strings.

```bash
declare -A config

config["host"]="localhost"
config["port"]="5432"
config["db"]="myapp"

# Literal syntax
declare -A env_labels=(
    [production]="prod"
    [staging]="stg"
    [development]="dev"
)
```

---

### Associative Array Access

```bash
echo "${config[host]}"        # "localhost"
echo "${config[@]}"           # all values
echo "${!config[@]}"          # all keys
echo "${#config[@]}"          # key count

# Check key existence
if [[ -v config[host] ]]; then
    echo "host key exists"
fi
```

---

### `unset` — Remove Array Element or Variable

```bash
unset fruits[2]           # remove element at index 2
unset config              # destroy the entire array or variable
```

---

## 6. Control Flow

---

### `if` / `elif` / `else`

```bash
if [[ -f "$FILE" ]]; then
    echo "File exists"
elif [[ -d "$FILE" ]]; then
    echo "Is a directory"
else
    echo "Not found"
fi
```

---

### `case` — Pattern Matching Branch

Matches a word against a series of patterns. Patterns support glob metacharacters. Each clause ends with `;;`. Use `;&` to fall through and `;;&` to continue testing.

```bash
case "$1" in
    start|begin)
        echo "Starting service"
        ;;
    stop|end)
        echo "Stopping service"
        ;;
    restart)
        echo "Restarting"
        ;;
    --help|-h)
        usage
        ;;
    *)
        echo "Unknown command: $1" >&2
        exit 1
        ;;
esac
```

---

### `for` — Iterate Over a List

```bash
# List form
for user in alice bob charlie; do
    echo "Hello, $user"
done

# Glob expansion
for f in /etc/*.conf; do
    echo "Config: $f"
done

# C-style loop
for (( i=1; i<=5; i++ )); do
    printf "%d " "$i"
done
```

---

### `while` — Loop While Condition Is True

```bash
# Condition-based
count=0
while (( count < 5 )); do
    echo "$count"
    (( count++ ))
done

# Read lines from stdin or file
while IFS= read -r line; do
    echo ">> $line"
done < input.txt

# Read from a command
while IFS= read -r line; do
    echo "$line"
done < <(find /tmp -name "*.log")
```

---

### `until` — Loop Until Condition Is True

The logical inverse of `while`. Loops as long as the condition returns non-zero (false).

```bash
until ping -c1 -W1 "$HOST" &>/dev/null; do
    echo "Waiting for $HOST..."
    sleep 2
done
echo "$HOST is reachable"
```

---

### `select` — Interactive Menu

Displays a numbered menu from a list of words, prompts the user, and sets `$REPLY` to the raw input and the loop variable to the chosen item.

```bash
PS3="Choose an environment: "
select env in production staging development quit; do
    case "$env" in
        quit) break ;;
        "")   echo "Invalid selection" ;;
        *)    echo "Deploying to: $env"; break ;;
    esac
done
```

---

### `break` & `continue`

- **`break [n]`** — Exit from the innermost (or `n`th enclosing) loop.
- **`continue [n]`** — Skip to the next iteration of the innermost (or `n`th enclosing) loop.

```bash
for i in {1..10}; do
    (( i % 2 == 0 )) && continue   # skip even numbers
    (( i > 7 )) && break           # stop after 7
    echo "$i"
done
```

---

## 7. Functions

---

### Declaration Syntax

Both syntaxes are equivalent. The `function` keyword is Bash-specific; the `name()` form is POSIX-compatible.

```bash
# POSIX-compatible
greet() {
    echo "Hello, ${1:-stranger}"
}

# Bash keyword form
function cleanup {
    rm -f "$TMPFILE"
    echo "Cleaned up"
}
```

---

### `local` — Scoped Variables

Variables declared with `local` are scoped to the function and its children. Without `local`, all variables are global by default.

```bash
process_file() {
    local input="$1"
    local count=0
    # $input and $count are not visible outside this function
    while IFS= read -r _; do
        (( count++ ))
    done < "$input"
    echo "$count"
}
```

---

### Return Values & `return`

Functions return an exit status (0–255) via `return`. To return data, print to stdout and capture with command substitution.

```bash
to_uppercase() {
    echo "${1^^}"
}

is_even() {
    (( $1 % 2 == 0 ))   # returns 0 (true) or 1 (false)
}

result=$(to_uppercase "hello")   # "HELLO"
is_even 4 && echo "4 is even"
```

---

### `declare -f` / `declare -F` — Inspect Functions

```bash
declare -F           # list all defined function names
declare -f greet     # print the definition of 'greet'
```

---

## 8. I/O Redirection & Pipes

---

### Standard Redirections

| Syntax | Description |
|---|---|
| `> file` | Redirect stdout to file (truncate) |
| `>> file` | Redirect stdout to file (append) |
| `< file` | Redirect file to stdin |
| `2> file` | Redirect stderr to file |
| `2>> file` | Append stderr to file |
| `&> file` | Redirect both stdout and stderr to file |
| `&>> file` | Append both stdout and stderr to file |
| `2>&1` | Redirect stderr to wherever stdout currently points |
| `1>&2` | Redirect stdout to stderr |
| `> /dev/null` | Discard stdout |
| `&> /dev/null` | Discard all output |

```bash
# Suppress stdout, keep stderr visible
command > /dev/null

# Capture both stdout and stderr
output=$(command 2>&1)

# Redirect stderr to a log file, keep stdout on terminal
command 2>> error.log

# Order matters: redirect stderr to stdout AFTER stdout is redirected
command > out.txt 2>&1   # correct: both go to out.txt
command 2>&1 > out.txt   # wrong: stderr stays on terminal
```

---

### Pipelines

Connect commands so the stdout of each feeds the stdin of the next. Each command in a pipeline runs in a subshell by default (except the last, in Bash with `lastpipe` set).

```bash
# Basic pipeline
cat /var/log/syslog | grep "ERROR" | awk '{print $5}' | sort | uniq -c | sort -rn

# Pipeline exit status: set -o pipefail makes the pipeline fail on any command
set -o pipefail
cat file | process_data | write_output
```

---

### File Descriptor Manipulation

```bash
# Open fd 3 for reading from a file
exec 3< config.txt
read -r line > output.log
echo "log line" >&4
exec 4>&-    # close fd 4

# Duplicate stdout to fd 5, then redirect stdout to a log
exec 5>&1
exec > build.log
echo "This goes to build.log"
exec 1>&5    # restore stdout
exec 5>&-
```

---

### Named Pipes (`mkfifo`)

A FIFO allows two unrelated processes to communicate without a temporary file.

```bash
mkfifo /tmp/mypipe
producer > /tmp/mypipe &
consumer < /tmp/mypipe
rm /tmp/mypipe
```

---

## 9. Built-in Commands

---

### `echo`

Prints arguments to stdout followed by a newline. Use `-n` to suppress the newline and `-e` to interpret escape sequences. Prefer `printf` for portable, predictable output.

```bash
echo "Hello, world"
echo -n "No newline"
echo -e "Tab:\there\nNewline above"
```

---

### `read`

Reads a line from stdin and assigns words to variables. Without variable names, assigns the entire line to `$REPLY`.

```bash
# Basic read
read -r line

# Split into multiple variables
read -r first rest <<< "hello world foo"

# With a prompt
read -rp "Enter username: " username

# Silent input (passwords)
read -rsp "Password: " password; echo

# With timeout
read -rt 5 -p "Press Enter within 5 seconds: " || echo "Timed out"

# Read into an array
read -ra words <<< "one two three"

# Read fixed number of chars
read -rn 1 -p "Continue? [y/n] " answer
```

---

### `declare` / `typeset`

Declares variables with attributes. `typeset` is an alias.

| Flag | Effect |
|---|---|
| `-i` | Integer (arithmetic on assignment) |
| `-r` | Read-only |
| `-x` | Export to environment |
| `-a` | Indexed array |
| `-A` | Associative array |
| `-l` | Convert value to lowercase on assignment |
| `-u` | Convert value to uppercase on assignment |
| `-p` | Print declaration of named variable(s) |

```bash
declare -i counter=0
counter+=5          # treated as arithmetic, not string concat

declare -r MAX=100  # read-only; attempts to modify produce an error

declare -xl LOG_LEVEL   # exported, lowercased
LOG_LEVEL="DEBUG"   # stored as "debug", visible to child processes
```

---

### `export`

Marks variables and functions for export to the environment of child processes.

```bash
export PATH="$HOME/.local/bin:$PATH"
export -f my_function   # export a function
```

---

### `source` / `.` — Execute in Current Shell

Reads and executes commands from a file in the current shell environment. Variable assignments and function definitions take effect immediately.

```bash
source ~/.bashrc
. ./lib/helpers.sh   # POSIX form
```

---

### `eval`

Concatenates its arguments into a single string and executes it as a Bash command. Powerful but dangerous — avoid with untrusted input.

```bash
cmd="echo hello"
eval "$cmd"

# Dynamic variable names (prefer indirect expansion instead)
varname="MY_VAR"
eval "$varname='some value'"
```

---

### `exec`

Replaces the current shell process with the given command (no fork). With no command, modifies file descriptors for the current shell.

```bash
# Replace shell with a new process (PID is preserved)
exec python3 app.py

# Redirect all future stdout to a log file
exec > /var/log/app.log 2>&1
```

---

### `cd`

Changes the current working directory. `-` returns to `$OLDPWD`. `-P` resolves symlinks (physical path).

```bash
cd /var/log
cd -          # return to previous directory
cd ~          # go to $HOME
cd -P /link   # resolve symlinks to physical path
```

---

### `pushd` / `popd` / `dirs`

Manage a stack of directories. `pushd` changes directory and pushes the old directory onto the stack; `popd` removes the top entry and returns there.

```bash
pushd /etc
pushd /tmp
dirs       # show stack: /tmp /etc ~
popd       # return to /etc
popd       # return to ~
```

---

### `set` — Shell Options & Positional Parameters

Controls shell behavior via options, or replaces positional parameters.

| Option | Effect |
|---|---|
| `set -e` / `set -o errexit` | Exit on first unhandled error |
| `set -u` / `set -o nounset` | Error on unset variable reference |
| `set -o pipefail` | Pipeline fails if any command fails |
| `set -x` / `set -o xtrace` | Print commands before executing (debug) |
| `set -f` / `set -o noglob` | Disable glob expansion |
| `set -C` / `set -o noclobber` | Prevent `>` from overwriting existing files |
| `set --` | End of options; following args become `$1`, `$2`... |

```bash
# The recommended "safe scripting" header
set -euo pipefail

# Temporarily enable tracing
set -x
complex_operation
set +x   # disable tracing
```

---

### `shopt` — Bash-Specific Shell Options

Enables or disables Bash-specific behaviors not covered by `set`.

| Option | Effect |
|---|---|
| `extglob` | Extended glob patterns |
| `globstar` | `**` matches files and directories recursively |
| `nullglob` | Failed globs expand to empty string instead of literal |
| `failglob` | Failed globs produce an error |
| `nocaseglob` | Case-insensitive glob matching |
| `lastpipe` | Last command in pipeline runs in current shell |
| `dotglob` | Include dotfiles in glob patterns |

```bash
shopt -s globstar nullglob
for f in **/*.log; do
    compress "$f"
done
```

---

### `trap` — Signal & Event Handlers

Registers commands to run when the shell receives a signal or a special pseudo-signal. See [Section 12](#12-trap--signals) for full reference.

```bash
trap 'echo "Caught SIGINT"; exit 1' INT
trap 'cleanup' EXIT
```

---

### `wait`

Waits for background jobs to complete. Without arguments, waits for all background jobs. With a PID or job ID, waits for that specific job and returns its exit status.

```bash
job1 &
job2 &
wait          # wait for all

job3 &
PID=$!
wait "$PID"
echo "job3 exited with status $?"
```

---

### `jobs`

Lists background and suspended jobs in the current shell with their job IDs and statuses.

```bash
sleep 60 &
sleep 30 &
jobs          # [1]+ Running   sleep 60
              # [2]- Running   sleep 30
```

---

### `kill`

Sends a signal to a process by PID or job ID. Default signal is `SIGTERM` (15). Use `kill -l` to list all signal names.

```bash
kill "$PID"           # SIGTERM
kill -9 "$PID"        # SIGKILL (cannot be caught or ignored)
kill -HUP "$PID"      # SIGHUP (reload config)
kill %1               # send SIGTERM to job 1
```

---

### `getopts` — Parse Short Options

POSIX-compliant option parser for scripts. Handles short options (`-x`, `-f value`). The option string lists valid flags; `:` after a letter means it takes an argument (stored in `$OPTARG`).

```bash
usage() { echo "Usage: $0 [-v] [-f file] [-n count]"; }

verbose=false
file=""
count=1

while getopts ":vf:n:" opt; do
    case "$opt" in
        v) verbose=true ;;
        f) file="$OPTARG" ;;
        n) count="$OPTARG" ;;
        :) echo "Option -$OPTARG requires an argument" >&2; exit 1 ;;
        ?) echo "Unknown option: -$OPTARG" >&2; usage; exit 1 ;;
    esac
done
shift $(( OPTIND - 1 ))   # shift past processed options; $@ is now remaining args
```

---

### `type` — Command Type Lookup

Tells you whether a name is an alias, function, built-in, or external command.

```bash
type ls       # ls is /bin/ls
type cd       # cd is a shell builtin
type ll       # ll is aliased to 'ls -alF'
type -a python # show all matches in PATH
```

---

### `hash`

Maintains a cache of command paths to avoid repeated `$PATH` lookups. `hash -r` clears the cache (useful after installing new tools).

```bash
hash -r              # clear path cache
hash -t python3      # show cached path for python3
```

---

### `command`

Bypasses functions and aliases and invokes the actual command. With `-v`, prints the path to the command.

```bash
# Call the real 'ls', not an alias
command ls

# Check if a command exists
if command -v jq &>/dev/null; then
    echo "jq is installed"
fi
```

---

### `true` / `false`

Built-in commands that return exit status `0` and `1` respectively. Used as no-ops or loop conditions.

```bash
while true; do
    read -rp "Continue? [y/n]: " ans
    [[ "$ans" == "n" ]] && break
done
```

---

### `test` / `[` — Condition Evaluation

Evaluates conditional expressions. `[` is a synonym (requires closing `]`). Prefer `[[` for safety (see Section 10).

```bash
test -f /etc/hosts && echo "exists"
[ "$x" -gt 0 ] && echo "positive"
```

---

## 10. File & String Test Operators

Used inside `[ ]`, `[[ ]]`, or `if` statements. `[[ ]]` is preferred in Bash scripts for its richer syntax and safer quoting.

---

### File Tests

| Operator | True if |
|---|---|
| `-e file` | `file` exists |
| `-f file` | `file` exists and is a regular file |
| `-d file` | `file` exists and is a directory |
| `-s file` | `file` exists and is non-empty |
| `-r file` | `file` exists and is readable |
| `-w file` | `file` exists and is writable |
| `-x file` | `file` exists and is executable |
| `-L file` | `file` is a symbolic link |
| `-b file` | `file` is a block device |
| `-c file` | `file` is a character device |
| `-p file` | `file` is a named pipe (FIFO) |
| `-S file` | `file` is a socket |
| `-N file` | `file` has been modified since last read |
| `f1 -nt f2` | `f1` is newer than `f2` (modification time) |
| `f1 -ot f2` | `f1` is older than `f2` |
| `f1 -ef f2` | `f1` and `f2` are hard links to the same file |

```bash
[[ -f "$config" ]] || { echo "Config not found: $config" >&2; exit 1; }
[[ -d "$outdir" ]] || mkdir -p "$outdir"
[[ -x "$binary" ]] || chmod +x "$binary"
```

---

### String Tests

| Operator | True if |
|---|---|
| `-z str` | `str` is empty (zero length) |
| `-n str` | `str` is non-empty |
| `str1 = str2` | Strings are equal (use `==` in `[[`) |
| `str1 != str2` | Strings are not equal |
| `str1 < str2` | `str1` sorts before `str2` (lexicographic) |
| `str1 > str2` | `str1` sorts after `str2` |
| `str =~ regex` | `str` matches ERE `regex` (only in `[[`) |
| `-v varname` | Variable named `varname` is set (Bash 4.2+) |

```bash
[[ -z "$input" ]] && { echo "Input required" >&2; exit 1; }
[[ "$status" == "active" ]] && enable_service
[[ "$email" =~ ^[^@]+@[^@]+\.[^@]+$ ]] || echo "Invalid email"
```

---

### Integer Comparison Operators (inside `[ ]` and `(( ))`)

| `[ ]` form | `(( ))` form | Meaning |
|---|---|---|
| `-eq` | `==` | Equal |
| `-ne` | `!=` | Not equal |
| `-lt` | `<` | Less than |
| `-le` | `<=` | Less than or equal |
| `-gt` | `>` | Greater than |
| `-ge` | `>=` | Greater than or equal |

```bash
if [[ "$count" -ge 10 ]]; then echo "Reached limit"; fi
if (( count >= 10 )); then echo "Reached limit"; fi
```

---

### Combining Tests

```bash
# AND and OR in [[ ]]
[[ -f "$file" && -r "$file" ]] && process "$file"
[[ "$mode" == "debug" || "$VERBOSE" == "1" ]] && set -x

# Negation
[[ ! -d "$dir" ]] && mkdir "$dir"
```

---

## 11. Pattern Matching & Globbing

---

### Basic Glob Patterns

| Pattern | Matches |
|---|---|
| `*` | Any string of characters (excluding `/` in paths) |
| `?` | Any single character |
| `[abc]` | Any one character in the set |
| `[a-z]` | Any one character in the range |
| `[!abc]` | Any character NOT in the set |

```bash
ls *.log
ls report_202[0-9].txt
cp /etc/[a-z]*.conf /backup/
```

---

### Extended Globs (`shopt -s extglob`)

| Pattern | Matches |
|---|---|
| `?(pattern)` | Zero or one occurrence |
| `*(pattern)` | Zero or more occurrences |
| `+(pattern)` | One or more occurrences |
| `@(pattern)` | Exactly one occurrence |
| `!(pattern)` | Anything EXCEPT the pattern |

```bash
shopt -s extglob

ls !(*.log)              # all files except .log files
ls +(report|summary)_*  # files starting with "report_" or "summary_"
rm file_+([0-9]).txt     # files like file_123.txt
```

---

### Recursive Glob (`shopt -s globstar`)

`**` matches files and directories recursively at any depth.

```bash
shopt -s globstar
wc -l **/*.go          # count lines in all .go files recursively
cp **/*.conf /backup/  # copy all .conf files from any subdirectory
```

---

### Brace Expansion

Generates a list of strings from a pattern. Not glob — it does not require files to exist. Processed before other expansions.

```bash
echo {a,b,c}.txt           # a.txt b.txt c.txt
echo {1..5}                # 1 2 3 4 5
echo {a..e}                # a b c d e
echo {01..05}              # 01 02 03 04 05 (zero-padded)
echo {1..10..2}            # 1 3 5 7 9 (step)
mkdir -p project/{src,tests,docs,build}
cp file.conf{,.bak}        # copies file.conf to file.conf.bak
```

---

## 12. Trap & Signals

---

### `trap 'command' SIGNAL` — Register Signal Handlers

Registers `command` to run when the shell receives the specified signal or pseudo-signal. Multiple signals may share one handler.

```bash
# Cleanup on any exit
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

# Handle interruption gracefully
trap 'echo -e "\nInterrupted. Cleaning up..."; exit 130' INT TERM
```

---

### Pseudo-Signals

| Pseudo-signal | Fires when |
|---|---|
| `EXIT` | Shell exits (any reason) |
| `ERR` | Any command returns non-zero (respects `set -e`) |
| `DEBUG` | Before every command executes |
| `RETURN` | A function or sourced script returns |

```bash
# ERR trap for automatic error reporting
trap 'echo "Error on line $LINENO: exit status $?" >&2' ERR

# DEBUG trap for tracing (expensive — use sparingly)
trap 'echo "About to run: $BASH_COMMAND"' DEBUG
```

---

### Common Signal Numbers

| Signal | Number | Default action | Common use |
|---|---|---|---|
| `SIGHUP` | 1 | Terminate | Reload config |
| `SIGINT` | 2 | Terminate | Ctrl+C |
| `SIGQUIT` | 3 | Core dump | Ctrl+\ |
| `SIGKILL` | 9 | Terminate (uncatchable) | Force kill |
| `SIGTERM` | 15 | Terminate | Graceful shutdown |
| `SIGUSR1` | 10 | Terminate | User-defined |
| `SIGUSR2` | 12 | Terminate | User-defined |
| `SIGPIPE` | 13 | Terminate | Broken pipe |
| `SIGCHLD` | 17 | Ignore | Child status changed |

---

### `trap -` — Reset Signal to Default

```bash
trap - INT   # restore default SIGINT behavior (process termination)
trap -p INT  # print the current trap for INT
```

---

## 13. Process Substitution & Subshells

---

### `$( )` — Command Substitution

Executes a command in a subshell and substitutes its stdout. Nesting is supported. Trailing newlines are stripped.

```bash
today=$(date +%Y-%m-%d)
files=$(find . -name "*.go" | wc -l)
first_line=$(head -n1 < "$file")

# Nested
echo "Script dir: $(dirname "$(realpath "$0")")"
```

---

### `` ` ` `` — Legacy Command Substitution

Older form. Does not support nesting as cleanly; backslashes behave differently. Avoid in new scripts.

```bash
today=`date +%Y-%m-%d`   # avoid this; use $() instead
```

---

### `<( )` — Process Substitution (Input)

Runs a command and provides its output as a named file (typically a `/dev/fd/N` path). Lets you pass a command's output where a filename is expected.

```bash
# Diff the output of two commands without temp files
diff <(sort file1.txt) <(sort file2.txt)

# Read from two sources in a loop
while IFS= read -r line; do
    echo "$line"
done < <(generate_data)
```

---

### `>( )` — Process Substitution (Output)

Runs a command and provides a path that, when written to, feeds into the command's stdin.

```bash
# Tee output to both gzip and a plain log
tee >(gzip > output.gz) > output.log <<< "data"

# Send stdout to multiple processors
command > >(filter_a > a.out) > >(filter_b > b.out)
```

---

### `( )` — Subshell

Groups commands in a subshell. Variable assignments and `cd` inside do not affect the parent shell.

```bash
# Isolated environment
(
    cd /tmp
    export SOME_VAR="value"
    do_work
)
# Back in original directory; SOME_VAR not set here

# Run multiple commands and capture combined output
output=$( command1; command2; command3 )
```

---

### `{ }` — Command Grouping (Current Shell)

Groups commands in the **current** shell (unlike `( )`). Variable assignments are visible after the block. Requires a semicolon or newline before the closing `}`.

```bash
{ command1; command2; command3; } > output.txt

# Useful for grouping redirections
{
    echo "Header"
    cat data.txt
    echo "Footer"
} | mail -s "Report" user@example.com
```

---

## 14. Common Idiomatic Patterns

---

### Safe Script Header

The standard preamble for robust scripts. Fails on errors, unset variables, and failed pipes.

```bash
#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
```

---

### Require a Command to Exist

```bash
require_cmd() {
    command -v "$1" &>/dev/null || {
        echo "Error: required command '$1' not found" >&2
        exit 1
    }
}
require_cmd jq
require_cmd docker
```

---

### Idempotent Directory Creation

```bash
mkdir -p "${OUTPUT_DIR:?OUTPUT_DIR is not set}"
```

---

### Robust Temporary File Handling

```bash
TMPFILE=$(mktemp)
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPFILE" "$TMPDIR"' EXIT
```

---

### Retry Loop with Backoff

```bash
retry() {
    local max=$1; shift
    local delay=1
    local attempt=1
    until "$@"; do
        (( attempt++ ))
        (( attempt > max )) && { echo "Failed after $max attempts" >&2; return 1; }
        echo "Attempt $attempt failed. Retrying in ${delay}s..." >&2
        sleep "$delay"
        (( delay *= 2 ))
    done
}
retry 5 curl -fsSL "$URL" -o output.tar.gz
```

---

### Parallel Job Execution with Job Limit

```bash
MAX_JOBS=4
for item in "${items[@]}"; do
    process_item "$item" &
    while (( $(jobs -r | wc -l) >= MAX_JOBS )); do
        wait -n 2>/dev/null || true   # wait for any one job to finish
    done
done
wait   # drain remaining jobs
```

---

### Logging Helper

```bash
log()  { printf '[%s] INFO  %s\n' "$(date +%T)" "$*"; }
warn() { printf '[%s] WARN  %s\n' "$(date +%T)" "$*" >&2; }
die()  { printf '[%s] ERROR %s\n' "$(date +%T)" "$*" >&2; exit 1; }

log "Starting deployment"
warn "No backup found, proceeding anyway"
die "Database connection failed"
```

---

### Reading a Config File (Key=Value)

```bash
declare -A config
while IFS='=' read -r key value; do
    [[ "$key" =~ ^#|^$ ]] && continue   # skip comments and blanks
    config["${key// /}"]="${value// /}"
done < app.conf
echo "Host: ${config[host]}"
```

---

### Script Self-Reload on File Change

```bash
SCRIPT="$(realpath "$0")"
MTIME=$(stat -c %Y "$SCRIPT")
while true; do
    sleep 5
    NEW_MTIME=$(stat -c %Y "$SCRIPT")
    if [[ "$NEW_MTIME" != "$MTIME" ]]; then
        echo "Script changed, reloading..." >&2
        exec "$SCRIPT" "$@"
    fi
done
```

---

## 15. Quick Index

| Symbol | Kind | Summary |
|---|---|---|
| `$?` | variable | Exit status of last command |
| `$$` | variable | PID of current shell |
| `$!` | variable | PID of last background process |
| `$0` | variable | Script name |
| `$#` | variable | Argument count |
| `$@` | variable | All args as separate words |
| `$*` | variable | All args as single word |
| `$_` | variable | Last argument of previous command |
| `$-` | variable | Current shell option flags |
| `$LINENO` | variable | Current line number in script |
| `$RANDOM` | variable | Random integer 0–32767 |
| `$IFS` | variable | Internal field separator |
| `$SECONDS` | variable | Seconds since shell started |
| `$PIPESTATUS` | variable | Array of pipeline exit statuses |
| `$BASH_SOURCE` | variable | Array of call-stack source files |
| `$FUNCNAME` | variable | Array of call-stack function names |
| `${var:-default}` | expansion | Use default if unset or empty |
| `${var:=default}` | expansion | Assign default if unset or empty |
| `${var:+alt}` | expansion | Use alt if set |
| `${var:?msg}` | expansion | Error and exit if unset or empty |
| `${#var}` | expansion | String length |
| `${var:off:len}` | expansion | Substring extraction |
| `${var#pat}` | expansion | Strip shortest prefix |
| `${var##pat}` | expansion | Strip longest prefix |
| `${var%pat}` | expansion | Strip shortest suffix |
| `${var%%pat}` | expansion | Strip longest suffix |
| `${var/p/r}` | expansion | Replace first match |
| `${var//p/r}` | expansion | Replace all matches |
| `${var^^}` / `${var,,}` | expansion | Uppercase / lowercase |
| `${!prefix@}` | expansion | Variable names with prefix |
| `${!var}` | expansion | Indirect variable expansion |
| `$(( expr ))` | expansion | Arithmetic expansion |
| `(( expr ))` | statement | Arithmetic conditional |
| `let` | builtin | Arithmetic assignment |
| `printf` | builtin | Formatted output |
| `<<EOF` | syntax | Here document |
| `<<<` | syntax | Here string |
| `declare -a` | builtin | Declare indexed array |
| `declare -A` | builtin | Declare associative array |
| `declare -i` | builtin | Declare integer variable |
| `declare -r` | builtin | Declare read-only variable |
| `declare -x` | builtin | Export variable |
| `unset` | builtin | Remove variable or array element |
| `if / elif / else` | control | Conditional branch |
| `case` | control | Pattern-matching branch |
| `for` | control | List iteration |
| `while` | control | Loop while true |
| `until` | control | Loop until true |
| `select` | control | Interactive menu |
| `break` / `continue` | control | Loop flow control |
| `local` | builtin | Function-scoped variable |
| `return` | builtin | Exit function with status |
| `declare -f` | builtin | Inspect function definition |
| `>` / `>>` | redirect | Stdout to file |
| `2>` / `2>&1` | redirect | Stderr redirect |
| `&>` | redirect | Stdout + stderr to file |
| `|` | operator | Pipe stdout to next stdin |
| `exec N<` / `exec N>` | builtin | Open file descriptor |
| `mkfifo` | command | Create named pipe |
| `echo` | builtin | Print to stdout |
| `read` | builtin | Read from stdin |
| `export` | builtin | Export to child processes |
| `source` / `.` | builtin | Execute file in current shell |
| `eval` | builtin | Execute string as command |
| `exec` | builtin | Replace shell with command |
| `cd` | builtin | Change directory |
| `pushd` / `popd` | builtin | Directory stack |
| `dirs` | builtin | Show directory stack |
| `set -e` | option | Exit on error |
| `set -u` | option | Error on unset variable |
| `set -o pipefail` | option | Pipeline fails on any error |
| `set -x` | option | Trace commands |
| `shopt -s extglob` | option | Extended glob patterns |
| `shopt -s globstar` | option | Recursive `**` glob |
| `shopt -s nullglob` | option | Failed globs expand to empty |
| `trap` | builtin | Register signal/event handler |
| `wait` | builtin | Wait for background jobs |
| `jobs` | builtin | List background jobs |
| `kill` | builtin | Send signal to process |
| `getopts` | builtin | Parse short command options |
| `type` | builtin | Identify command type |
| `command` | builtin | Bypass aliases/functions |
| `hash` | builtin | Manage command path cache |
| `-e` / `-f` / `-d` | test op | File existence / type tests |
| `-r` / `-w` / `-x` | test op | File permission tests |
| `-z` / `-n` | test op | String empty / non-empty |
| `=~` | test op | Regex match (in `[[ ]]`) |
| `-eq` / `-ne` / `-lt` / `-gt` | test op | Integer comparisons |
| `-nt` / `-ot` / `-ef` | test op | File age / hardlink tests |
| `*` / `?` / `[...]` | glob | Basic glob patterns |
| `?(p)` / `*(p)` / `+(p)` / `!(p)` | glob | Extended glob patterns |
| `**` | glob | Recursive glob (globstar) |
| `{a,b,c}` | expansion | Brace expansion list |
| `{1..5}` | expansion | Brace expansion sequence |
| `$( )` | expansion | Command substitution |
| `<( )` | expansion | Process substitution (input) |
| `>( )` | expansion | Process substitution (output) |
| `( )` | syntax | Subshell grouping |
| `{ }` | syntax | Current-shell command grouping |
| `EXIT` trap | pseudo-signal | On any shell exit |
| `ERR` trap | pseudo-signal | On non-zero exit status |
| `DEBUG` trap | pseudo-signal | Before every command |
| `RETURN` trap | pseudo-signal | On function/source return |

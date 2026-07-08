# Basic Bash Script Writing Cheatsheet

Foundational reference for writing readable, correct, and safe shell scripts.

## Script Skeleton

```bash
#!/bin/bash
set -euo pipefail

# Description: what this script does
# Usage: ./script.sh arg1 arg2

main() {
    echo "Hello, $1"
}

main "$@"
```

```bash
chmod +x script.sh       # make executable
./script.sh               # run it
bash script.sh             # run without execute bit
```

## Shebang Options

```bash
#!/bin/bash              # bash-specific features allowed
#!/usr/bin/env bash        # portable, finds bash via PATH
#!/bin/sh                    # POSIX sh, avoid bashisms
```

## Strict Mode (Recommended for Every Script)

```bash
set -e            # exit immediately if a command fails
set -u            # error on unset variables
set -o pipefail    # pipeline fails if any stage fails, not just the last
set -x             # print each command before executing (debugging)

set -euo pipefail   # common combined form
```

## Variables

```bash
name="Alice"                  # no spaces around =
echo "$name"                    # always quote variable expansions
readonly PI=3.14159               # constant, cannot be reassigned
unset name                          # remove a variable

local var="value"                    # inside a function, scope to function only

# Default values
echo "${name:-default}"        # use default if unset or empty
echo "${name:=default}"        # assign default if unset or empty
echo "${name:?error message}"    # exit with error if unset

# Parameter expansion
echo "${#name}"                 # length of string
echo "${name:0:3}"                # substring: first 3 chars
echo "${name/Alice/Bob}"           # replace first match
echo "${name//a/A}"                 # replace all matches
echo "${name^^}"                     # uppercase
echo "${name,,}"                      # lowercase
```

## Arithmetic

```bash
count=5
count=$((count + 1))            # arithmetic expansion
((count++))                       # increment, C-style
((count += 5))                     # add and assign
result=$(( 10 / 3 ))                 # integer division
result=$(echo "10 / 3" | bc -l)       # floating point via bc
let "count = count + 1"                # alternate arithmetic syntax
```

## Command-Line Arguments

```bash
echo "$0"          # script name
echo "$1"           # first argument
echo "$2"            # second argument
echo "$#"             # number of arguments
echo "$@"              # all arguments as separate words
echo "$*"                # all arguments as a single string
shift                     # discard $1, shift others down

# Simple argument loop
for arg in "$@"; do
    echo "Argument: $arg"
done
```

## Parsing Flags with getopts

```bash
#!/bin/bash
while getopts "n:f:vh" opt; do
    case "$opt" in
        n) name="$OPTARG" ;;
        f) file="$OPTARG" ;;
        v) verbose=true ;;
        h) echo "Usage: $0 -n name -f file [-v]"; exit 0 ;;
        *) echo "Unknown option"; exit 1 ;;
    esac
done
shift $((OPTIND - 1))    # remove parsed options, leaving positional args
```

## Conditionals

```bash
if [ "$a" = "$b" ]; then
    echo "equal"
elif [ "$a" -gt "$b" ]; then
    echo "a is greater"
else
    echo "b is greater"
fi

# Prefer [[ ]] in bash (more features, safer word-splitting)
if [[ "$name" == "Alice" ]]; then
    echo "hi Alice"
fi

# One-liners
[ -f file.txt ] && echo "exists"
[ -z "$var" ] && echo "empty"
```

### Comparison Operators

| Test | String | Numeric |
|---|---|---|
| Equal | `=` or `==` | `-eq` |
| Not equal | `!=` | `-ne` |
| Greater than | (use `[[ ]] >`) | `-gt` |
| Less than | (use `[[ ]] <`) | `-lt` |
| Greater or equal | — | `-ge` |
| Less or equal | — | `-le` |

### File Test Operators

| Test | Meaning |
|---|---|
| `-e file` | Exists |
| `-f file` | Regular file |
| `-d file` | Directory |
| `-r file` | Readable |
| `-w file` | Writable |
| `-x file` | Executable |
| `-s file` | Exists and not empty |
| `-L file` | Symbolic link |

## Loops

```bash
# for loop over a list
for item in apple banana cherry; do
    echo "$item"
done

# for loop over files
for file in *.txt; do
    echo "Processing $file"
done

# C-style for loop
for ((i = 0; i < 10; i++)); do
    echo "$i"
done

# while loop
count=0
while [ "$count" -lt 5 ]; do
    echo "$count"
    ((count++))
done

# until loop
until [ "$count" -eq 0 ]; do
    ((count--))
done

# read loop over file lines
while IFS= read -r line; do
    echo "$line"
done < file.txt

# infinite loop with break
while true; do
    read -p "Continue? (y/n) " ans
    [ "$ans" = "n" ] && break
done
```

## Functions

```bash
greet() {
    local name="$1"
    echo "Hello, $name"
}
greet "World"

# Return values via exit status (0-255)
is_even() {
    (( $1 % 2 == 0 ))
}
if is_even 4; then
    echo "even"
fi

# "Return" a value via stdout + command substitution
get_date() {
    date +%Y-%m-%d
}
today=$(get_date)

# Functions with multiple named args via shift
deploy() {
    local env="$1"
    local version="$2"
    echo "Deploying $version to $env"
}
deploy "production" "1.2.3"
```

## Arrays

```bash
fruits=("apple" "banana" "cherry")
echo "${fruits[0]}"              # first element
echo "${fruits[@]}"                # all elements
echo "${#fruits[@]}"                 # array length
fruits+=("date")                       # append element

for fruit in "${fruits[@]}"; do
    echo "$fruit"
done

# Associative arrays (bash 4+)
declare -A capitals
capitals[France]="Paris"
capitals[Japan]="Tokyo"
echo "${capitals[France]}"
for country in "${!capitals[@]}"; do
    echo "$country -> ${capitals[$country]}"
done
```

## Case Statements

```bash
case "$1" in
    start)
        echo "Starting..."
        ;;
    stop)
        echo "Stopping..."
        ;;
    restart|reload)
        echo "Restarting..."
        ;;
    *)
        echo "Usage: $0 {start|stop|restart}"
        exit 1
        ;;
esac
```

## Error Handling

```bash
command || { echo "command failed" >&2; exit 1; }

trap 'echo "Error on line $LINENO"' ERR
trap 'cleanup' EXIT              # run cleanup function on any exit
trap 'echo "Interrupted"; exit 1' INT TERM

cleanup() {
    rm -f "$tmpfile"
}

set -e
command_that_might_fail || {
    echo "Handling failure gracefully"
    exit 1
}
```

## Command Substitution

```bash
current_dir=$(pwd)              # preferred syntax
current_dir=`pwd`                # older backtick syntax, avoid in new code
files=$(ls *.txt)
count=$(echo "$files" | wc -l)
```

## Working with Temp Files

```bash
tmpfile=$(mktemp)
trap 'rm -f "$tmpfile"' EXIT
echo "data" > "$tmpfile"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
```

## String Checks and Manipulation

```bash
[[ -z "$var" ]] && echo "empty"
[[ -n "$var" ]] && echo "not empty"
[[ "$str" == *"substring"* ]] && echo "contains substring"
[[ "$str" =~ ^[0-9]+$ ]] && echo "is numeric"     # regex match

# Trim whitespace
trimmed="$(echo "$str" | xargs)"
```

## Exit Codes

```bash
exit 0        # success
exit 1         # general error
exit 2          # misuse of shell command
echo $?          # check exit code of last command

# Custom exit codes for scripts
if [ ! -f "$file" ]; then
    echo "File not found" >&2
    exit 66      # EX_NOINPUT, conventional BSD exit code
fi
```

## Debugging

```bash
bash -x script.sh          # trace execution
set -x                        # enable tracing mid-script
set +x                         # disable tracing
bash -n script.sh                # syntax check only, don't execute
shellcheck script.sh               # static analysis (install separately)
```

## Practical Full Example

```bash
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_NAME="$(basename "$0")"
LOG_FILE="/tmp/${SCRIPT_NAME}.log"

usage() {
    echo "Usage: $SCRIPT_NAME -s source -d dest [-v]"
    exit 1
}

verbose=false
while getopts "s:d:v" opt; do
    case "$opt" in
        s) source="$OPTARG" ;;
        d) dest="$OPTARG" ;;
        v) verbose=true ;;
        *) usage ;;
    esac
done

[[ -z "${source:-}" || -z "${dest:-}" ]] && usage

log() {
    $verbose && echo "[$(date +%T)] $*" | tee -a "$LOG_FILE"
}

log "Starting sync from $source to $dest"

if [ ! -d "$source" ]; then
    echo "Error: source directory does not exist" >&2
    exit 1
fi

mkdir -p "$dest"
cp -r "$source"/* "$dest"/

log "Done."
```

## Best Practices Summary

- Always quote variable expansions: `"$var"`, not `$var`.
- Use `set -euo pipefail` at the top of every script.
- Prefer `[[ ]]` over `[ ]` in bash scripts.
- Use `local` for function-scoped variables.
- Use `$(...)` instead of backticks for command substitution.
- Clean up temp files with `trap ... EXIT`.
- Validate arguments before using them (`usage` on bad input).
- Run `shellcheck` on scripts before deploying them.

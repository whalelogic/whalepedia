#!/usr/bin/env bash
set -euo pipefail

TMPFILE="/tmp/bash-demo.$$.tmp"
cleanup() {
  rm -f "$TMPFILE"
}
trap cleanup EXIT

echo "Bash version: $BASH_VERSION"
echo "Script name: $0"
echo "PID: $$"
echo "Arg count: $#"
printf 'All args quoted with "$@":'
printf ' [%s]' "$@"
printf '\n'
echo

target_name="${1:-world}"
greeting="${GREETING:-hello}"
echo "${greeting^}, ${target_name}!"
echo "Lowercase greeting: ${greeting,,}"
echo "Name length: ${#target_name}"
echo

readonly max_jobs=4
readonly default_jobs=3
jobs_to_run="${2:-$default_jobs}"
if [[ ! "$jobs_to_run" =~ ^[1-9][0-9]*$ ]]; then
  echo "Invalid jobs value '${jobs_to_run}' (expected a positive integer), defaulting to ${default_jobs}"
  jobs_to_run=$default_jobs
fi
if (( jobs_to_run > max_jobs )); then
  echo "Requested jobs exceed max (${max_jobs}), capping to max"
  jobs_to_run=$max_jobs
fi
echo "Jobs to run: $jobs_to_run"
echo

fruits=("apple" "banana" "cherry")
declare -A ports=(
  [http]=80
  [https]=443
  [ssh]=22
)
echo "First fruit: ${fruits[0]}"
echo "All fruits: ${fruits[*]}"
echo "HTTPS port: ${ports[https]}"
echo

sum=0
for ((i=1; i<=jobs_to_run; i++)); do
  sum=$((sum + i))
done
echo "Arithmetic sum 1..${jobs_to_run} = ${sum}"

is_even() {
  local value=$1
  (( value % 2 == 0 ))
}

if is_even "$sum"; then
  echo "sum is even"
else
  echo "sum is odd"
fi
echo

printf '%s\n' "${fruits[@]}" > "$TMPFILE"
echo "Wrote fruits to $TMPFILE"
echo "Raw vs sorted fruits with process substitution:"
paste <(cat "$TMPFILE") <(sort "$TMPFILE")
echo

echo "Pipeline demo:"
printf 'alpha\nbeta\ngamma\n' | grep -E 'a$' | wc -l
echo "PIPESTATUS: ${PIPESTATUS[*]}"
echo

case "$target_name" in
  admin|root) echo "Privileged name detected" ;;
  *) echo "Standard name path" ;;
esac

echo "glob demo (./*.md in current directory):"
shopt -s nullglob
md_files=(./*.md)
if ((${#md_files[@]} == 0)); then
  echo "No markdown files in current directory"
else
  printf '  %s\n' "${md_files[@]}"
fi
echo

echo "Timing demo using SECONDS"
SECONDS=0
sleep 1
echo "Elapsed: ${SECONDS}s"

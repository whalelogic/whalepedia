# Functional Patterns with Pipes Cheatsheet

Unix pipes let you compose small, single-purpose tools into larger pipelines —
a functional-programming style applied at the shell level: each command is a
pure(ish) transformation from stdin to stdout, and `|` is function composition.

## The Core Idea

```bash
command1 | command2 | command3
```

Each command reads from stdin, transforms, writes to stdout. No shared state,
no side effects beyond input/output — this is essentially `compose(f, g, h)`.

## Basic Pipe Composition

```bash
cat file.txt | grep "error" | wc -l              # count matching lines
ls -la | grep "^d"                                 # filter for directories
ps aux | grep nginx | grep -v grep                 # find process, exclude grep itself
history | grep ssh | tail -5                        # last 5 ssh commands used
```

## Map: Transform Each Line

```bash
cat names.txt | tr 'a-z' 'A-Z'                # uppercase every line
cat file.txt | sed 's/^/> /'                   # prefix each line
cat numbers.txt | awk '{ print $1 * 2 }'        # double each number
cat urls.txt | xargs -I{} echo "Fetching: {}"   # transform each item
find . -name "*.txt" | xargs -I{} basename {}   # map basename over results
```

## Filter: Keep Matching Elements

```bash
cat file.txt | grep "pattern"                    # keep matching lines
cat file.txt | grep -v "pattern"                  # keep non-matching lines
ls -la | awk '$5 > 1000'                          # keep files over 1000 bytes
cat access.log | awk '$9 == 404'                   # keep 404 responses only
find . -type f | grep -v node_modules              # exclude a directory
```

## Reduce: Fold to a Single Value

```bash
cat numbers.txt | paste -sd+ | bc                 # sum via string join + calculator
cat numbers.txt | awk '{ s += $1 } END { print s }'  # sum via awk accumulator
cat file.txt | wc -l                                # reduce to line count
cat file.txt | wc -c                                # reduce to byte count
du -sh */ | sort -rh | head -1                        # reduce to single largest item
```

## Sort / Group / Aggregate (map-reduce style)

```bash
cat access.log | awk '{ print $1 }' | sort | uniq -c | sort -rn
# ^ map: extract IP -> group: sort+uniq -> reduce: count, sorted descending

cat file.txt | tr ' ' '\n' | sort | uniq -c | sort -rn | head -10
# word frequency count: classic map-reduce word count pipeline

ls -la | awk '{ print $3 }' | sort | uniq -c
# group files by owner
```

## Composition with xargs (Apply Function to Each Item)

```bash
find . -name "*.log" | xargs rm                    # apply rm to each result
find . -name "*.jpg" | xargs -I{} convert {} {}.png # apply transformation
echo "a b c" | xargs -n1                             # split into separate invocations
cat urls.txt | xargs -n1 -P4 curl -O                  # parallel map, 4 at a time
find . -name "*.txt" | xargs grep -l "TODO"            # apply grep to each file
```

### xargs Key Flags

| Flag | Meaning |
|---|---|
| `-I{}` | Replace `{}` with each input item |
| `-n N` | Pass N arguments per invocation |
| `-P N` | Run N processes in parallel |
| `-0` | Use null-delimited input (pairs with `find -print0`) |
| `-t` | Print command before executing |
| `-r` | Don't run if input is empty |

## Process Substitution (Functional-Style Composition)

```bash
diff <(sort file1.txt) <(sort file2.txt)          # compose sort into diff's input
comm <(sort a.txt) <(sort b.txt)                    # compare sorted streams
paste <(cut -f1 a.tsv) <(cut -f2 b.tsv)              # combine outputs of two pipelines
while read -r line; do echo "$line"; done < <(find . -name "*.txt")
```

## tee: Fan-Out / Side Effects Without Breaking the Pipe

```bash
cat file.txt | tee output.txt | grep "error"       # save full output AND filter it
command | tee -a log.txt                             # append instead of overwrite
command | tee file1.txt file2.txt                     # write to multiple files
curl -s url | tee response.json | jq '.status'          # inspect while saving raw response
```

## Currying-Like Patterns with Functions and Aliases

```bash
# Define reusable "partial application" style shell functions
uppercase() { tr 'a-z' 'A-Z'; }
count_lines() { wc -l; }

cat file.txt | uppercase | count_lines

# Compose functions into a named pipeline
process() { grep "$1" | sort | uniq -c | sort -rn; }
cat access.log | process "GET"
```

## Lazy Evaluation Analogue: Streaming with head/tail

```bash
yes | head -5                       # infinite stream, take first 5 (like `take 5`)
seq 1 1000000 | head -3              # short-circuit large computation
tail -f log.txt | grep "ERROR"        # continuous stream filter
```

## Parallel Map with GNU parallel

```bash
cat urls.txt | parallel -j4 curl -O {}          # 4-way parallel map
find . -name "*.jpg" | parallel convert {} {.}.png
seq 1 10 | parallel echo "Processing {}"
```

## Function Composition Chains (Real Examples)

```bash
# Top 5 most frequent words in a file
cat book.txt | tr -cs 'A-Za-z' '\n' | tr 'A-Z' 'a-z' | sort | uniq -c | sort -rn | head -5

# Unique visitor IPs from an access log, sorted by hit count
awk '{ print $1 }' access.log | sort | uniq -c | sort -rn

# Disk usage of top-level dirs, sorted descending, human-readable
du -sh */ 2>/dev/null | sort -rh

# Find all TODO comments across a codebase, grouped by file
grep -rn "TODO" --include="*.py" . | cut -d: -f1 | sort | uniq -c | sort -rn

# Extract, transform, and load into a new file (ETL in one line)
cat raw.csv | awk -F, '{ print $1","$3 }' | sort -t, -k2 -n > sorted_subset.csv
```

## Named Pipes (FIFOs) for More Complex Composition

```bash
mkfifo mypipe
command1 > mypipe &
command2 < mypipe
rm mypipe
```

## Error Handling in Pipelines

```bash
set -o pipefail                     # make pipeline fail if ANY command fails
command1 | command2 | command3
echo $?                              # exit code reflects first failure, not just last

command1 || echo "command1 failed"   # fallback on failure
command1 && command2                  # run command2 only if command1 succeeds
```

## Short-Circuiting and Conditionals as Pipeline Guards

```bash
grep -q "pattern" file && echo "found" || echo "not found"
test -f file.txt && cat file.txt | wc -l
[ -s file.txt ] && echo "not empty"
```

## Combining Everything: A Realistic Pipeline

```bash
find /var/log -name "*.log" -mtime -1 \
  | xargs cat \
  | grep "ERROR" \
  | awk '{ print $1, $2 }' \
  | sort \
  | uniq -c \
  | sort -rn \
  | head -20
```

This reads as a functional pipeline: gather recent logs → concatenate →
filter errors → extract timestamp fields → group and count → take the top 20.

## Principles for Writing Good Pipelines

- Keep each stage doing one thing (single responsibility, like a pure function).
- Prefer `sort | uniq -c` over manual counting logic — it's the shell's `groupBy`.
- Use `xargs -P` or `parallel` for embarrassingly parallel maps.
- Use `tee` when you need a side effect (logging) without breaking the chain.
- Use `set -o pipefail` in scripts so failures don't silently disappear.
- Process substitution (`<(...)`) lets you feed pipeline output where a file
  is expected, avoiding temp files.

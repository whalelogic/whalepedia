# AWK Cheatsheet

AWK is a pattern-scanning and text-processing language built around the idea of
`pattern { action }` pairs applied to each line of input.

## Basic Invocation

```bash
awk 'pattern { action }' file.txt
awk -F: '{ print $1 }' /etc/passwd      # set field separator
awk -f script.awk file.txt              # run script from file
echo "a b c" | awk '{ print $2 }'       # read from stdin
awk 'BEGIN { print "start" }'           # run once before input
awk 'END { print "done" }'              # run once after input
```

## Core Concepts

| Concept | Meaning |
|---|---|
| `$0` | Entire current line |
| `$1, $2, ...` | Field 1, field 2, etc. |
| `NF` | Number of fields in current record |
| `NR` | Current record (line) number, cumulative across files |
| `FNR` | Record number within current file |
| `FS` | Input field separator (default: whitespace) |
| `OFS` | Output field separator (default: space) |
| `RS` | Input record separator (default: newline) |
| `ORS` | Output record separator (default: newline) |
| `FILENAME` | Name of current input file |

## Field Separators

```bash
awk -F: '{ print $1 }' /etc/passwd          # colon-delimited
awk -F',' '{ print $2 }' data.csv           # comma-delimited
awk -F'[,;]' '{ print $1 }' data.csv        # multiple separators (regex)
awk 'BEGIN { FS = "\t" } { print $3 }' f    # tab-delimited, set in BEGIN
awk 'BEGIN { OFS = "," } { $1=$1; print }'  # re-join fields with new OFS
```

## Printing and Formatting

```bash
awk '{ print $1, $3 }' file            # print fields 1 and 3
awk '{ print $1 "-" $3 }' file         # concatenate without OFS
awk '{ printf "%-10s %5d\n", $1, $2 }' file   # formatted output
awk '{ print NR, $0 }' file            # number each line
awk '{ print toupper($1) }' file       # uppercase field
awk '{ print length($0) }' file        # line length
```

## Patterns and Conditions

```bash
awk '/error/ { print }' log.txt              # lines matching regex
awk '!/error/ { print }' log.txt              # lines NOT matching
awk '$3 > 100 { print }' file                 # numeric comparison
awk '$1 == "root" { print }' file             # string comparison
awk 'NR == 1' file                            # first line only
awk 'NR > 1' file                             # skip header
awk 'NR % 2 == 0' file                        # even lines
awk 'length($0) > 80' file                    # long lines
awk '/start/,/end/' file                      # range pattern
```

## Combining Conditions

```bash
awk '$1 == "GET" && $9 == 200 { print $7 }' access.log
awk '$1 ~ /^192\./ || $1 ~ /^10\./ { print }' hosts.txt
awk '!($1 == "root") { print }' file
```

## Built-in Variables and Arithmetic

```bash
awk '{ sum += $1 } END { print sum }' numbers.txt        # running sum
awk '{ sum += $1; count++ } END { print sum/count }' f   # average
awk '{ if ($1 > max) max = $1 } END { print max }' f     # max value
awk 'BEGIN { srand(); print int(rand()*100) }'           # random number
```

## Arrays (Associative)

```bash
awk '{ count[$1]++ } END { for (k in count) print k, count[k] }' file
awk '{ sum[$1] += $2 } END { for (k in sum) print k, sum[k] }' sales.csv
awk '{ seen[$0]++; if (seen[$0] == 1) print }' file   # uniq without sort
```

## String Functions

| Function | Description |
|---|---|
| `length(s)` | Length of string |
| `substr(s, m, n)` | Substring starting at m, length n |
| `index(s, t)` | Position of t in s (0 if not found) |
| `split(s, arr, sep)` | Split s into arr by sep |
| `sub(re, repl, target)` | Replace first match |
| `gsub(re, repl, target)` | Replace all matches |
| `match(s, re)` | Set RSTART/RLENGTH |
| `sprintf(fmt, ...)` | Format string |
| `tolower(s)` / `toupper(s)` | Case conversion |
| `gensub(re, repl, how, target)` | GNU awk only, non-destructive gsub |

```bash
awk '{ gsub(/foo/, "bar"); print }' file
awk '{ n = split($0, parts, ":"); print parts[1] }' file
awk '{ print substr($0, 1, 10) }' file
```

## Math Functions

```bash
awk '{ print sqrt($1) }' file
awk '{ print int($1) }' file
awk '{ print $1 % 2 }' file
awk 'BEGIN { print exp(1), log(10), sin(0), cos(0), atan2(1,1) }'
```

## Control Flow

```bash
awk '{
  if ($1 > 10) {
    print "big"
  } else if ($1 > 5) {
    print "medium"
  } else {
    print "small"
  }
}' file

awk '{ for (i = 1; i <= NF; i++) print $i }' file

awk '{
  i = 1
  while (i <= NF) {
    print $i
    i++
  }
}' file
```

## Multiple Files

```bash
awk 'FNR == 1 { print "---" FILENAME "---" } { print }' a.txt b.txt
awk 'FNR==NR { seen[$1]=1; next } !($1 in seen)' file1 file2  # diff-like
```

## Practical One-Liners

```bash
awk '{ print $NF }' file                       # last field
awk '{ print $(NF-1) }' file                    # second-to-last field
awk '{ total += $1 } END { print total }' file  # sum column 1
awk 'BEGIN{OFS="\t"} {print $1,$2}' file        # reformat as TSV
awk '!seen[$0]++' file                          # remove duplicate lines
awk 'length > max { max = length; line = $0 } END { print line }' f  # longest line
awk '{ print $1 | "sort" }' file                # pipe output to another command
awk -v n=5 '{ print $n }' file                  # pass shell variable in
```

## Using awk -v and Shell Variables

```bash
threshold=100
awk -v t="$threshold" '$2 > t { print }' file
```

## Multi-line AWK Scripts

```awk
#!/usr/bin/awk -f
BEGIN {
    FS = ","
    print "Report"
}
{
    total += $3
}
END {
    printf "Total: %.2f\n", total
}
```

Run with: `awk -f script.awk data.csv` or make it executable with a shebang.

## Common Gotchas

- Uninitialized numeric variables default to `0`; string variables default to `""`.
- `==` compares numerically if both sides look numeric, otherwise as strings.
- Regex literals use `/.../`, not quotes.
- `$0` changes if you modify `$1..$NF` and print again unless `OFS` is respected.
- `next` skips remaining actions for the current record.
- `nextfile` skips to the next input file (GNU awk).

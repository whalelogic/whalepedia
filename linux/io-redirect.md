# Input & Output Redirection Cheatsheet

Every process has three standard streams: stdin (0), stdout (1), and stderr
(2). Redirection lets you control where data comes from and goes to.

## The Three Standard Streams

| Stream | Number | Default |
|---|---|---|
| stdin | 0 | Keyboard input |
| stdout | 1 | Terminal display |
| stderr | 2 | Terminal display |

## Basic Output Redirection

```bash
command > file.txt          # redirect stdout, overwrite file
command >> file.txt         # redirect stdout, append to file
command 1> file.txt          # explicit stdout redirect (same as >)
command 2> error.log         # redirect stderr only
command 2>> error.log        # append stderr
command > out.txt 2> err.txt # separate files for stdout and stderr
```

## Combining stdout and stderr

```bash
command > combined.txt 2>&1     # both streams into one file (order matters!)
command &> combined.txt          # bash shorthand for the above
command &>> combined.txt         # append both streams
command 2>&1 | tee log.txt        # merge streams and also print to terminal
```

> **Order matters:** `2>&1 > file` sends stderr to the terminal (current
> stdout) then redirects stdout to file. `> file 2>&1` redirects stdout to
> file, then points stderr at wherever stdout now points (the file). Always
> put `2>&1` **after** the stdout redirect if you want both in one file.

## Discarding Output

```bash
command > /dev/null                 # discard stdout
command 2> /dev/null                # discard stderr
command > /dev/null 2>&1            # discard everything (silent mode)
command &> /dev/null                 # bash shorthand for discarding everything
```

## Input Redirection

```bash
command < file.txt                   # feed file as stdin
command < file.txt > output.txt      # input from file, output to file
mysql -u user -p database < dump.sql  # common real-world example
wc -l < file.txt                       # count lines without printing filename
```

## Here Documents (Multi-line stdin)

```bash
cat << EOF
Line one
Line two
EOF

cat << 'EOF'            # quoted delimiter disables variable expansion
$HOME will not expand
EOF

mysql -u root -p << SQL
SELECT * FROM users;
SQL

ssh user@host << 'REMOTE'
echo "Running on remote host"
hostname
REMOTE
```

## Here Strings (Single-line stdin)

```bash
grep "pattern" <<< "$variable"
cat <<< "quick one-liner input"
bc <<< "5 + 3"
```

## Pipes (Chaining stdout to stdin)

```bash
command1 | command2                  # stdout of command1 -> stdin of command2
command1 | command2 | command3        # chain multiple commands
command 2>&1 | less                    # pipe both streams into a pager
```

## Process Substitution

```bash
diff <(command1) <(command2)          # treat command output as a file
command < <(other_command)             # feed a command's output as stdin
tee >(command1) >(command2) < input.txt  # fan out to multiple commands
```

## File Descriptor Manipulation

```bash
exec 3> file.txt        # open fd 3 for writing
echo "data" >&3          # write to fd 3
exec 3>&-                # close fd 3

exec 4< file.txt          # open fd 4 for reading
read line <&4               # read a line from fd 4
exec 4<&-                    # close fd 4

command 3>&1 1>&2 2>&3       # swap stdout and stderr
```

## Appending vs Overwriting Reference

| Operator | Stream | Behavior |
|---|---|---|
| `>` | stdout | Overwrite |
| `>>` | stdout | Append |
| `2>` | stderr | Overwrite |
| `2>>` | stderr | Append |
| `&>` | both | Overwrite |
| `&>>` | both | Append |
| `<` | stdin | Read from file |
| `<<` | stdin | Heredoc |
| `<<<` | stdin | Herestring |

## Redirecting Within Scripts

```bash
#!/bin/bash
exec > script.log 2>&1        # redirect ALL script output to a log file from here on
echo "This goes to script.log"

exec > >(tee -a script.log) 2>&1   # log to file AND still print to terminal
```

## Reading Input in Scripts

```bash
read -p "Enter your name: " name        # prompt and read into variable
read -s -p "Password: " pass             # silent input (no echo), for secrets
read -t 10 -p "Answer (10s): " answer     # timeout after 10 seconds
read -a arr -p "Enter values: "            # read into an array
IFS=, read -r a b c <<< "1,2,3"             # custom delimiter split

while read -r line; do
    echo "Processing: $line"
done < input.txt

while IFS=, read -r col1 col2 col3; do
    echo "$col1 - $col2 - $col3"
done < data.csv
```

## Checking if Input is a Terminal or a Pipe

```bash
if [ -t 0 ]; then
    echo "stdin is a terminal (interactive)"
else
    echo "stdin is a pipe or file (non-interactive)"
fi
```

Useful in scripts that behave differently when piped versus run interactively.

## Redirecting to Multiple Destinations

```bash
command | tee file1.txt file2.txt > /dev/null    # write to two files, suppress terminal output
command | tee -a log.txt                          # append via tee
command | tee /dev/tty | wc -l                      # show output AND count lines
```

## Null Device and Special Files

```bash
> file.txt                    # truncate a file to zero length (no command needed)
cat /dev/null > file.txt       # alternate way to empty a file
command < /dev/null             # provide empty input (prevents hanging on stdin)
yes | command                    # provide infinite "y" input to a prompt
```

## Common Patterns

```bash
# Silence a noisy command but keep errors visible
long_running_command > /dev/null

# Log everything a script does, including errors
./script.sh > script.log 2>&1

# Send errors to a separate error log while showing normal output
./script.sh 2> errors.log

# Feed a variable into a command that expects a file
grep "foo" <<< "$content"

# Combine multiple files as one stdin stream
cat file1.txt file2.txt | sort | uniq

# Redirect to a command needing sudo (this common mistake fails):
echo "text" > /etc/protected_file        # fails: permission denied even with sudo before echo
# Correct approach:
echo "text" | sudo tee /etc/protected_file > /dev/null
```

## Why `sudo command > file` Fails

The shell (not `sudo`) performs the redirection, and the shell runs as your
unprivileged user. `sudo` only elevates the command itself, so writing to a
root-owned file still fails. Use `sudo tee` instead:

```bash
echo "new value" | sudo tee /etc/sysctl.conf > /dev/null
echo "new value" | sudo tee -a /etc/sysctl.conf > /dev/null   # append version
```

## Quick Reference Table

| Goal | Command |
|---|---|
| Save output, discard errors | `cmd > out.txt 2>/dev/null` |
| Save errors only | `cmd 2> err.txt` |
| Save both to one file | `cmd > all.txt 2>&1` |
| Silence everything | `cmd > /dev/null 2>&1` |
| Show and save output | `cmd \| tee out.txt` |
| Feed a string as input | `cmd <<< "$string"` |
| Feed a multi-line block | `cmd << EOF ... EOF` |
| Read file line by line | `while read -r line; do ...; done < file` |
| Write to root-owned file | `echo "x" \| sudo tee file` |

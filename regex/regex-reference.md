# Regex Reference Table

A comprehensive reference for Regular Expressions, covering patterns, syntax, and common use cases.


## Metacharacters

| Symbol | Description |
|--------|-------------|
| `.` | Matches any character except newline |
| `^` | Matches start of string |
| `$` | Matches end of string |
| `*` | Matches 0 or more repetitions |
| `+` | Matches 1 or more repetitions |
| `?` | Matches 0 or 1 occurrence |
| `{n,m}` | Matches between n and m occurrences |
| `( )` | Groups patterns |
| `[ ]` | Defines a character class |
| `\\` | Escapes a special character |


## Functions

| Function | Description |
|----------|-------------|
| `re.findall()` | Returns a list of all matches | 
| `re.search()`  | Returns a Match object if there is a match anywhere in the string |
| `re.split()`   | Returns a list where the string has been split at each match |
| `re.sub()`     | Replaces either one or more matches with a string
| `re.compile()` | Compiles a regex pattern for reuse |
| `re.escape()` | Escapes all special characters in string | ⛑️
| `re.purge()` | Clears the regex cache | 


## Special Sequences

| Symbol | Description |
|--------|-------------|
| `\d` | Matches any digit (0-9) |
| `\D` | Matches any non-digit |
| `\s` | Matches any whitespace character |
| `\S` | Matches any non-whitespace character |
| `\w` | Matches any alphanumeric character |
| `\W` | Matches any non-alphanumeric character |
| `\b` | Matches a word boundary |
| `\B` | Matches a non-word boundary |
| `\A` | Matches the start of a string |
| `\Z` | Matches the end of a string |

## Character Sets

| Pattern | Description |
|---------|-------------|
| `[abc]` | Matches any character in the set |
| `[^abc]` | Matches any character not in the set |
| `[a-z]` | Matches any character in the specified range |
| `[0-9]` | Matches any digit |
| `[a-zA-Z]` | Matches any letter |

## Matching Methods

| Method | Description |
|--------|-------------|
| `re.match()` | Matches pattern at the start of a string |
| `re.fullmatch()` | Matches pattern against entire string |
| `re.search()` | Searches for first occurrence of pattern |
| `re.findall()` | Finds all occurrences of pattern |
| `re.finditer()` | Returns iterator with match objects |
| `re.split()` | Splits string by occurrences of pattern |
| `re.sub()` | Replaces occurrences of pattern |
| `re.subn()` | Replaces occurrences of pattern and returns count |


## Flags

| Flag | Description |
|------|-------------|
| `re.IGNORECASE (re.I)` | Case-insensitive matching |
| `re.MULTILINE (re.M)` | Enables multi-line matching |
| `re.DOTALL (re.S)` | Allows `.` to match newline characters |
| `re.VERBOSE (re.X)` | Allows for readable regex with comments |
| `re.ASCII (re.A)` | Makes `\w`, `\d`, and `\s` match ASCII-only |
| `re.LOCALE (re.L)` | Uses locale-dependent character sets |


## Common Regex Patterns

| Category | Pattern / Syntax | Description | Example / Match |
|----------|-----------------|-------------|-----------------|
| **Anchors** | `^` | Start of line/string | `^Hello` matches "Hello" at start |
| **Anchors** | `$` | End of line/string | `world$` matches "world" at end |
| **Anchors** | `\b` | Word boundary | `\bcat\b` matches "cat" but not "category" |
| **Anchors** | `\B` | Not a word boundary | `\Bcat` matches "category" |
| **Character Classes** | `.` | Any character (except newline) | `a.b` matches "aab", "axb", "a0b" |
| **Character Classes** | `[abc]` | Any character in the set | `[aeiou]` matches any vowel |
| **Character Classes** | `[^abc]` | Any character NOT in the set | `[^0-9]` matches any non-digit |
| **Character Classes** | `[a-z]` | Range of characters (lowercase) | `[f-h]` matches "f", "g", or "h" |
| **Character Classes** | `\d` | Digit (0-9) | `\d\d` matches "42" |
| **Character Classes** | `\D` | Non-digit | `\D` matches "A", "!", " " |
| **Character Classes** | `\w` | Word character (a-z, A-Z, 0-9, _) | `\w+` matches "word_123" |
| **Character Classes** | `\W` | Non-word character | `\W` matches "@", "#", "$" |
| **Character Classes** | `\s` | Whitespace (space, tab, newline) | `\s` matches " " or "\t" |
| **Character Classes** | `\S` | Non-whitespace | `\S+` matches "hello" |
| **Quantifiers** | `*` | 0 or more times | `a*` matches "", "a", "aaaa" |
| **Quantifiers** | `+` | 1 or more times | `a+` matches "a", "aaaa" |
| **Quantifiers** | `?` | 0 or 1 time | `colou?r` matches "color" or "colour" |
| **Quantifiers** | `{n}` | Exactly n times | `\d{3}` matches "123" |
| **Quantifiers** | `{n,}` | n or more times | `\d{2,}` matches "12", "12345" |
| **Quantifiers** | `{n,m}` | Between n and m times | `\d{2,4}` matches "12", "123", "1234" |
| **Quantifiers** | `*?` | Lazy (matches as few as possible) | `".*?"` matches smallest quoted string |
| **Quantifiers** | `+?` | Lazy (matches as few as possible) | `a+?` matches just one "a" in "aaaa" |
| **Groups & Logic** | `(abc)` | Capture group | `(ha)+` matches "hahaha" |
| **Groups & Logic** | `(?:abc)` | Non-capturing group | `(?:abc)+` matches but doesn't save "abc" |
| **Groups & Logic** | `a|b` | Alternation (OR) | `cat|dog` matches "cat" or "dog" |
| **Groups & Logic** | `\1` | Backreference to group 1 | `(\w) \1` matches "a a" or "b b" |
| **Lookarounds** | `(?=abc)` | Positive Lookahead | `\d(?=px)` matches 1 in "1px" |
| **Lookarounds** | `(?!abc)` | Negative Lookahead | `\d(?!px)` matches 1 in "1pt" |
| **Lookarounds** | `(?<=abc)` | Positive Lookbehind | `(?<=\$)\d` matches 5 in "$5" |
| **Lookarounds** | `(?<!abc)` | Negative Lookbehind | `(?<!\$)\d` matches 5 in "€5" |
| **Escaped Chars** | `\n` | Newline | Match a line break |
| **Escaped Chars** | `\t` | Tab | Match a tab character |
| **Escaped Chars** | `\\` | Literal backslash | Match "\" |
| **Escaped Chars** | `\.` | Literal dot | Match "." |
| **Common Patterns** | `^\d+$` | Only digits | "12345" |
| **Common Patterns** | `^[a-zA-Z]+$` | Only letters | "HelloWorld" |
| **Common Patterns** | `^[a-z0-9_-]{3,16}$` | Username (3-16 chars) | "my_user-123" |
| **Common Patterns** | `^#?([a-f0-9]{6}|[a-f0-9]{3})$` | Hex Color | "#ffffff" or "#fff" |
| **Common Patterns** | `\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b` | Basic Email | "test@example.com" |
| **Common Patterns** | `^(\d{4})-(\d{2})-(\d{2})$` | ISO Date (YYYY-MM-DD) | "2026-05-03" |
| **Common Patterns** | `https?://[^\s/$.?#].[^\s]*` | Basic URL | "https://google.com" |
| **Common Patterns** | `\d{1,3}(\.\d{1,3}){3}` | IPv4 Address | "192.168.1.1" |
| **Common Patterns** | `^\+?[1-9]\d{1,14}$` | E.164 Phone Number | "+15551234567" |
| **Common Patterns** | `(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}` | Strong Password (min 8) | "Pass1234!" |
| **Common Patterns** | `<([a-z]+)>(.*?)<\/\1>` | HTML/XML Tag matching | `<div>content</div>` |
| **Common Patterns** | `(\d{3})-(\d{2})-(\d{4})` | US Social Security (SSN) | "123-45-6789" |
| **Common Patterns** | `\b\d{4}-\d{4}-\d{4}-\d{4}\b` | Credit Card Number | "1234-5678-9012-3456" |
| **Common Patterns** | `\s{2,}` | Two or more spaces | Match redundant whitespace |
| **Common Patterns** | `^$|^\s+$` | Empty or whitespace line | Find blank lines |
| **Common Patterns** | `(?m)^//.*$` | Single line comment (multiline) | `// this is a comment` |
| **Common Patterns** | `(?s)/\*.*?\*/` | Multi-line comment (dotall) | `/* comment */` |
| **Common Patterns** | `[^\x00-\x7F]` | Non-ASCII characters | Match Unicode characters |


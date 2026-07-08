# The Deep Regex Guide
> Regular expressions — from mechanical truth to expressive mastery, with Go throughout.

---

## Table of Contents

1. [What a Regex Engine Actually Does](#1-what-a-regex-engine-actually-does)
2. [Engine Types: NFA vs DFA](#2-engine-types-nfa-vs-dfa)
3. [Go's RE2 Engine](#3-gos-re2-engine)
4. [Syntax Reference](#4-syntax-reference)
5. [Anchors and Boundaries](#5-anchors-and-boundaries)
6. [Quantifiers — Greedy, Lazy, Possessive](#6-quantifiers--greedy-lazy-possessive)
7. [Groups — Capturing, Non-Capturing, Named](#7-groups--capturing-non-capturing-named)
8. [Lookahead and Lookbehind](#8-lookahead-and-lookbehind)
9. [Character Classes In Depth](#9-character-classes-in-depth)
10. [Unicode and Go](#10-unicode-and-go)
11. [Flags and Modes](#11-flags-and-modes)
12. [Backtracking and Catastrophic Complexity](#12-backtracking-and-catastrophic-complexity)
13. [Go's `regexp` Package — Full API](#13-gos-regexp-package--full-api)
14. [Compiling and Caching Patterns](#14-compiling-and-caching-patterns)
15. [Submatch Extraction](#15-submatch-extraction)
16. [Find vs Match vs Replace](#16-find-vs-match-vs-replace)
17. [Streaming and Reader-Based Matching](#17-streaming-and-reader-based-matching)
18. [Named Groups and Structured Extraction](#18-named-groups-and-structured-extraction)
19. [Replace with a Function](#19-replace-with-a-function)
20. [Building Patterns Programmatically](#20-building-patterns-programmatically)
21. [Testing Regex in Go](#21-testing-regex-in-go)
22. [Performance: Benchmarking and Optimization](#22-performance-benchmarking-and-optimization)
23. [Common Patterns and Pitfalls](#23-common-patterns-and-pitfalls)
24. [Regex vs Parser: Knowing the Limit](#24-regex-vs-parser-knowing-the-limit)
25. [POSIX Mode in Go](#25-posix-mode-in-go)
26. [Related Tools and Ecosystem](#26-related-tools-and-ecosystem)

---

## 1. What a Regex Engine Actually Does

A regular expression is a finite description of a (possibly infinite) set of strings — a **formal language** belonging to the class of *regular languages* in the Chomsky hierarchy. The engine's job is to decide whether a string is a member of that language, and if so, where.

Under the hood, every regex engine performs one of two operations:

- **Membership test** — does this string match?
- **Search** — find the first (or all) positions where a match begins

Before any matching occurs, the pattern is compiled into an internal representation. Most engines go through these stages:

```
Pattern string
    │
    ▼
Lexer/Tokenizer     → token stream
    │
    ▼
Parser              → abstract syntax tree (AST)
    │
    ▼
Compiler            → NFA or DFA bytecode / graph
    │
    ▼
Executor            → runs against input string
```

This compilation is not free — it's the reason you should **always pre-compile** patterns you use more than once.

### The Thompson Construction

Ken Thompson's 1968 paper introduced the algorithm that converts a regex AST directly into an NFA. Each operator maps to a small NFA fragment:

| Operator | NFA fragment |
|---|---|
| Literal `a` | single transition on character `a` |
| Concatenation `ab` | chain two fragments |
| Alternation `a\|b` | epsilon-split into two fragments |
| Kleene star `a*` | loop with epsilon transitions |

Thompson's construction guarantees **O(n·m)** worst-case matching time where `n` is the pattern length and `m` is the input length — no backtracking required.

---

## 2. Engine Types: NFA vs DFA

Understanding this distinction is the single most important conceptual lever in regex.

### NFA (Non-deterministic Finite Automaton)

Most regex engines you interact with — PCRE, Python `re`, Java `java.util.regex`, Perl — are NFA-based with backtracking. The engine explores one possible path through the NFA at a time. If it fails, it *backtracks* and tries another.

**Pros:** Can implement backreferences, lookaheads, conditionals, possessive quantifiers.  
**Cons:** Worst-case exponential time on pathological inputs.

### DFA (Deterministic Finite Automaton)

A DFA has at most one transition per state per input character. It processes input left-to-right in a single pass and **never backtracks**.

**Pros:** O(n) time always. Immune to catastrophic backtracking.  
**Cons:** Cannot express backreferences or complex lookarounds. DFA state space can explode exponentially with the pattern.

### Hybrid / Lazy DFA

Go's RE2 engine (and Rust's `regex` crate) use a *lazy DFA*: they simulate NFA execution using a set-of-states approach (the "powerset construction"), but build DFA states on demand and cache them. This gives:

- **O(n·m) time guarantee** — inputs cannot cause exponential blowup
- Support for most practical regex features (no backreferences)
- Memory-bounded operation

---

## 3. Go's RE2 Engine

Go's `regexp` package is built on **RE2**, a regex engine developed at Google by Russ Cox. RE2's defining property is its **linear time guarantee** on all inputs.

### What RE2 Deliberately Excludes

RE2 refuses to implement features that would require backtracking and thus allow quadratic or exponential runtime:

| Feature | PCRE | RE2/Go |
|---|---|---|
| Backreferences `\1` | ✅ | ❌ |
| Lookahead `(?=...)` | ✅ | ✅ (limited) |
| Lookbehind `(?<=...)` | ✅ | ❌ |
| Atomic groups `(?>...)` | ✅ | ❌ |
| Conditional `(?(cond)yes\|no)` | ✅ | ❌ |
| Possessive quantifiers `a++` | ✅ | ❌ |

> **Go's lookahead support:** RE2 does support `(?i)` flags and some assertions, but does **not** support lookaheads or lookbehinds of the `(?=...)` / `(?<=...)` form. If you need those, restructure your pattern or use `strings` + `regexp` together.

### Why This Matters in Production

A single malicious or malformed input can DoS a PCRE-based service. RE2 makes that impossible. This is a deliberate engineering tradeoff: Go gives up expressiveness for **security and predictability**.

---

## 4. Syntax Reference

Go uses RE2 syntax. The authoritative reference is `go doc regexp/syntax`.

### Literals and Escapes

```
.           any character except newline (unless (?s) flag)
\.          literal dot
\n          newline
\t          tab
\r          carriage return
\\          literal backslash
\xFF        hex byte
\x{10FFFF}  Unicode code point
```

### Alternation and Grouping

```
a|b         match a or b
(abc)       capturing group
(?:abc)     non-capturing group
(?P<name>abc)  named capturing group
```

### Repetition

```
a*          zero or more (greedy)
a+          one or more (greedy)
a?          zero or one (greedy)
a{n}        exactly n
a{n,}       n or more
a{n,m}      between n and m (inclusive)
a*?         zero or more (lazy)
a+?         one or more (lazy)
a??         zero or one (lazy)
```

### Assertions

```
^           start of text (or line in (?m) mode)
$           end of text (or line in (?m) mode)
\A          start of text (always)
\z          end of text (always)
\b          word boundary
\B          non-word boundary
```

### Character Classes

```
[abc]       a, b, or c
[^abc]      not a, b, or c
[a-z]       a through z
[a-zA-Z0-9] alphanumeric

\d          digit            [0-9]
\D          non-digit        [^0-9]
\w          word char        [0-9A-Za-z_]
\W          non-word char
\s          whitespace       [\t\n\f\r ]
\S          non-whitespace
```

### Perl Character Classes (RE2)

```
[:alpha:]   [A-Za-z]
[:digit:]   [0-9]
[:alnum:]   [A-Za-z0-9]
[:space:]   whitespace
[:upper:]   [A-Z]
[:lower:]   [a-z]
[:punct:]   punctuation
[:print:]   printable characters
```

---

## 5. Anchors and Boundaries

Anchors are **zero-width assertions** — they match a *position*, not a character. This is a conceptually important distinction.

### `^` and `$` vs `\A` and `\z`

In Go:

```go
// ^ and $ respect the (?m) multiline flag
re := regexp.MustCompile(`(?m)^\d+`)

// \A and \z are absolute — always start/end of full input
re := regexp.MustCompile(`\A\d+\z`)
```

Use `\A` and `\z` when validating whole-string inputs (email, UUID, etc.) to prevent partial matches, even in multiline mode.

### Word Boundaries `\b`

`\b` matches the position between a `\w` character and a `\W` character (or string start/end). It's implemented as a zero-width assertion.

```go
re := regexp.MustCompile(`\bfoo\b`)
re.MatchString("foo")       // true
re.MatchString("foobar")    // false
re.MatchString("a foo b")   // true
re.MatchString("foo!")      // true  — '!' is \W
```

**Gotcha:** `\b` operates on ASCII word characters only in RE2. For Unicode word boundaries, you need to be explicit with Unicode categories.

---

## 6. Quantifiers — Greedy, Lazy, Possessive

### Greedy (default)

Greedy quantifiers match **as much as possible**, then backtrack if necessary.

```
Input:  <a>hello</a><b>world</b>
Pattern: <.+>
Match:  <a>hello</a><b>world</b>   ← entire string, greedy
```

### Lazy (`?` suffix)

Lazy quantifiers match **as little as possible**.

```
Input:  <a>hello</a><b>world</b>
Pattern: <.+?>
Match:  <a>   ← stops at first >
```

```go
re := regexp.MustCompile(`<.+?>`)
fmt.Println(re.FindAllString("<a>hello</a><b>world</b>", -1))
// [<a> </a> <b> </b>]
```

### Why "Lazy" Isn't Always the Answer

Lazy quantifiers still backtrack in NFA engines. They just bias toward less consumption. In Go's RE2, the result is correct and bounded, but structurally it's still the same NFA simulation.

The *correct* approach for well-defined delimiters is to use **negated character classes**, which are always unambiguous:

```
Instead of:  <.+?>
Use:         <[^>]+>
```

`[^>]+` means "one or more characters that are not `>`" — this cannot over-match under any interpretation.

### Possessive Quantifiers

Possessive quantifiers (`a++`, `a*+`, `a?+`) are **not available in Go/RE2**. They exist in PCRE and prevent the engine from giving back characters once consumed, eliminating backtracking for that subexpression. If you're coming from Java or PCRE and relying on possessive quantifiers, restructure using negated classes or atomic groups — neither of which RE2 supports, but negated classes achieve the same semantic result.

---

## 7. Groups — Capturing, Non-Capturing, Named

### Capturing Groups `(...)`

Capturing groups record the substring matched by the group. They are numbered left-to-right by their opening parenthesis.

```go
re := regexp.MustCompile(`(\d{4})-(\d{2})-(\d{2})`)
match := re.FindStringSubmatch("date: 2024-03-15")
// match[0] = "2024-03-15"  (full match)
// match[1] = "2024"
// match[2] = "03"
// match[3] = "15"
```

### Non-Capturing Groups `(?:...)`

Use when you need grouping for alternation or quantification but don't need the submatch value. Cheaper — the engine doesn't record the match.

```go
re := regexp.MustCompile(`(?:https?|ftp)://(\S+)`)
// Group 1 is the URL path, not the scheme
```

### Named Groups `(?P<name>...)`

Go uses Python-style named groups with `(?P<name>...)`. Named groups are accessible by name via `SubexpNames()`.

```go
re := regexp.MustCompile(`(?P<year>\d{4})-(?P<month>\d{2})-(?P<day>\d{2})`)

match := re.FindStringSubmatch("2024-03-15")
names := re.SubexpNames()

result := map[string]string{}
for i, name := range names {
    if i != 0 && name != "" {
        result[name] = match[i]
    }
}
// result["year"]  = "2024"
// result["month"] = "03"
// result["day"]   = "15"
```

---

## 8. Lookahead and Lookbehind

> **RE2/Go does not support lookaheads or lookbehinds.** This section explains them conceptually and shows how to work around their absence in Go.

### What They Are

Lookaheads and lookbehinds are zero-width assertions that check context without consuming input.

| Syntax | Type | Meaning |
|---|---|---|
| `(?=...)` | Positive lookahead | followed by |
| `(?!...)` | Negative lookahead | not followed by |
| `(?<=...)` | Positive lookbehind | preceded by |
| `(?<!...)` | Negative lookbehind | not preceded by |

Example (PCRE, not Go): Match a number only if followed by `px`:
```
\d+(?=px)
```

### Workarounds in Go

**Pattern 1 — Capture what you need inside the group:**

Instead of `\d+(?=px)`, capture both and extract:

```go
re := regexp.MustCompile(`(\d+)px`)
match := re.FindStringSubmatch("24px")
fmt.Println(match[1]) // "24"
```

**Pattern 2 — Negative lookahead via post-processing:**

"Match word not followed by `ing`" — run the match, then filter:

```go
re := regexp.MustCompile(`\b\w+\b`)
words := re.FindAllString(input, -1)
for _, w := range words {
    if !strings.HasSuffix(w, "ing") {
        // process w
    }
}
```

**Pattern 3 — Split and recombine:**

For complex boundary cases, split on the delimiter and work with the parts separately. Regex doesn't have to do everything.

---

## 9. Character Classes In Depth

### Subtraction and Intersection (Not in RE2)

Some engines (Java, .NET) support character class subtraction `[a-z&&[^aeiou]]`. RE2/Go does not. Use explicit ranges instead:

```
Consonants: [b-df-hj-np-tv-z]
```

### The Dot `.` and Its Flags

By default, `.` does not match `\n`. This trips people up constantly when trying to match multiline content with `.+`.

```go
// Wrong — won't cross newlines:
re := regexp.MustCompile(`start.+end`)

// Correct — (?s) makes . match \n too:
re := regexp.MustCompile(`(?s)start.+end`)
```

### Ranges and Collation

Character ranges like `[a-z]` in RE2 are **byte/codepoint ranges**, not locale-aware collation ranges. `[a-z]` matches ASCII lowercase only. For Unicode letters, use `\p{L}` (see next section).

### Negated Classes and the Empty String

`[^x]+` can match the empty string only in quantifiers that allow zero matches (`[^x]*`). With `+`, it requires at least one non-`x` character. Be deliberate about which you use.

---

## 10. Unicode and Go

Go strings are UTF-8. RE2 is fully Unicode-aware, and Go's `regexp` package operates on **runes** (Unicode code points), not bytes, by default.

### Unicode Categories `\p{}`

```go
re := regexp.MustCompile(`\p{L}+`)     // one or more Unicode letters
re := regexp.MustCompile(`\p{N}+`)     // one or more Unicode numbers
re := regexp.MustCompile(`\p{Z}+`)     // Unicode separators (spaces)
re := regexp.MustCompile(`\p{Han}`)    // Chinese/Japanese/Korean Han characters
re := regexp.MustCompile(`\p{Latin}`)  // Latin script characters
```

Full list of supported categories: [Unicode categories in RE2](https://github.com/google/re2/wiki/Syntax)

### Common Unicode Classes

| Class | Description |
|---|---|
| `\p{L}` | Any letter |
| `\p{Lu}` | Uppercase letter |
| `\p{Ll}` | Lowercase letter |
| `\p{N}` | Any number |
| `\p{Nd}` | Decimal digit |
| `\p{P}` | Punctuation |
| `\p{S}` | Symbol |
| `\p{Z}` | Separator |
| `\p{C}` | Control character |

### Byte vs Rune Operations

```go
// FindAll operates on runes (Unicode-correct):
re := regexp.MustCompile(`\p{Han}+`)
re.FindAllString("Hello 世界 World", -1)  // ["世界"]

// For raw byte-level matching, use FindAll ([]byte variant):
re.FindAll([]byte(input), -1)
```

### Case Folding

Go's `(?i)` flag uses Unicode case folding, not just ASCII lowercasing. This means `(?i)strasse` matches `Straße` (German sharp S).

---

## 11. Flags and Modes

Flags in Go RE2 are set **inline** using `(?flags)` or `(?flags:pattern)` syntax. There's no separate flags argument like in Python.

| Flag | Meaning |
|---|---|
| `i` | Case-insensitive matching |
| `m` | Multiline: `^`/`$` match start/end of each line |
| `s` | `.` matches `\n` |
| `U` | Swap greedy/lazy defaults (ungreedy mode) |

### Global Flag Syntax

```go
// Applies to entire pattern:
re := regexp.MustCompile(`(?im)^\w+`)

// Applies to subexpression only:
re := regexp.MustCompile(`(?i:hello) world`)
// "hello" is case-insensitive; "world" is not
```

### The `U` (Ungreedy) Flag

With `(?U)`, quantifiers default to lazy and adding `?` makes them greedy — the inverse of normal behavior. This lets you write `<.+>` and have it behave like `<.+?>` without modifying every quantifier.

```go
re := regexp.MustCompile(`(?U)<.+>`)
re.FindString("<a>hello</a>")  // "<a>"
```

---

## 12. Backtracking and Catastrophic Complexity

Even though Go/RE2 is immune to catastrophic backtracking, you need to understand this for when you work with other engines, use `regexp/syntax` to analyze patterns, or reason about algorithmic complexity.

### ReDoS (Regular Expression Denial of Service)

The canonical catastrophic pattern is:

```
(a+)+b
```

Against input `aaaaaaaaaaaac`, a backtracking engine explores exponential paths:

```
(a)(aaaaaaaaaa) → fail
(aa)(aaaaaaaaa) → fail
(aaa)(aaaaaaaa) → fail
... 2^n possibilities
```

### The General Rule for Catastrophic Patterns

Catastrophic backtracking occurs when:

1. There are **multiple ways** for the engine to partition a string among quantified subexpressions
2. The pattern can **fail** after trying many partitions
3. The subexpressions **overlap** in what they can match

Classic examples:

```
(a|a)+          ← alternation with identical branches
(a*)*           ← nested quantifiers over same chars
(\w|\w)+        ← overlapping word char classes
```

### Safe Equivalents

```
(a|a)+   →  a+
(a*)*    →  a*
(\w|\w)+ →  \w+
```

### Analyzing Patterns with `regexp/syntax`

Go exposes the parser and AST for analysis:

```go
import "regexp/syntax"

prog, err := syntax.Parse(`(a+)+b`, syntax.Perl)
if err != nil {
    log.Fatal(err)
}
fmt.Println(prog.String()) // prints the parsed AST
```

You can walk the AST to detect nested quantifiers programmatically — useful for building a regex linter or validator.

---

## 13. Go's `regexp` Package — Full API

### Compilation

```go
// Panics on bad pattern — use in init() or package-level vars
re := regexp.MustCompile(`\d+`)

// Returns error — use in functions with user-supplied patterns
re, err := regexp.Compile(`\d+`)

// POSIX leftmost-longest semantics
re := regexp.MustCompilePOSIX(`\d+`)
```

### The Method Matrix

Go's API is organized along three axes, giving you a combinatorial method set:

| Axis | Options |
|---|---|
| **Operation** | `Match`, `Find`, `FindAll`, `FindIndex`, `FindAllIndex`, `FindString`, `FindAllString`, `FindStringIndex`, `FindAllStringIndex`, `FindSubmatch`, `FindAllSubmatch`, `FindStringSubmatch`, `FindAllStringSubmatch`, `FindStringSubmatchIndex`, `FindAllStringSubmatchIndex` |
| **Input type** | `string` variant or `[]byte` variant |
| **Count** | Single result or `All` (pass `n = -1` for all) |

```go
re := regexp.MustCompile(`\b\w+\b`)

// First match as string
re.FindString("hello world")          // "hello"

// All matches as []string
re.FindAllString("hello world", -1)   // ["hello", "world"]

// First match byte indices [start, end)
re.FindStringIndex("hello world")     // [0, 5]

// All submatch groups of first match
re.FindStringSubmatch(`(\w+)\s(\w+)`) // see §15
```

### Test Methods

```go
re.MatchString("input")          // bool
re.Match([]byte("input"))        // bool

// Package-level (compiles inline — don't use in loops)
regexp.MatchString(`\d+`, "123") // bool, error
```

---

## 14. Compiling and Caching Patterns

### Package-Level Variables (Recommended)

```go
var (
    reEmail = regexp.MustCompile(`\A[\w.+-]+@[\w-]+\.[a-z]{2,}\z`)
    reUUID  = regexp.MustCompile(`(?i)\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z`)
    reIP    = regexp.MustCompile(`\A(?:\d{1,3}\.){3}\d{1,3}\z`)
)
```

`MustCompile` panics on startup if the pattern is invalid — which is exactly what you want for hardcoded patterns. You catch the bug at program start, not at runtime.

### Dynamic Pattern Caching

When patterns are constructed at runtime (e.g., from config or user input), use a cache:

```go
import (
    "regexp"
    "sync"
)

type regexpCache struct {
    mu    sync.RWMutex
    cache map[string]*regexp.Regexp
}

func (c *regexpCache) Get(pattern string) (*regexp.Regexp, error) {
    c.mu.RLock()
    if re, ok := c.cache[pattern]; ok {
        c.mu.RUnlock()
        return re, nil
    }
    c.mu.RUnlock()

    re, err := regexp.Compile(pattern)
    if err != nil {
        return nil, err
    }

    c.mu.Lock()
    c.cache[pattern] = re
    c.mu.Unlock()
    return re, nil
}

var globalCache = &regexpCache{cache: make(map[string]*regexp.Regexp)}
```

For production use, consider `sync.Map` or an LRU cache (e.g., `github.com/hashicorp/golang-lru`) to bound memory.

### The Cost of `regexp.MustCompile` in a Hot Path

```go
// BAD — compiles on every call
func isEmail(s string) bool {
    return regexp.MustCompile(`\A[\w.+-]+@[\w-]+\.[a-z]{2,}\z`).MatchString(s)
}

// GOOD — compile once
var reEmail = regexp.MustCompile(`\A[\w.+-]+@[\w-]+\.[a-z]{2,}\z`)

func isEmail(s string) bool {
    return reEmail.MatchString(s)
}
```

---

## 15. Submatch Extraction

`FindStringSubmatch` returns a `[]string` where:

- Index `0` is the full match
- Index `n` is the nth capturing group (left to right by opening `(`)

```go
re := regexp.MustCompile(`(\w+)@(\w+)\.(\w+)`)
m := re.FindStringSubmatch("contact: user@example.com")
// m[0] = "user@example.com"
// m[1] = "user"
// m[2] = "example"
// m[3] = "com"
```

### Handling Non-Matching Optional Groups

When a group is part of an alternation or has a `?` quantifier, it may not participate in the match. Its slot will be an empty string:

```go
re := regexp.MustCompile(`(\d+)(px|em|rem)?`)
m := re.FindStringSubmatch("42")
// m[0] = "42"
// m[1] = "42"
// m[2] = ""    ← group 2 didn't match
```

For index-based detection (vs empty-string detection), use `FindStringSubmatchIndex`:

```go
idx := re.FindStringSubmatchIndex("42")
// idx = [0,2, 0,2, -1,-1]
// -1,-1 means group 2 did not participate
```

---

## 16. Find vs Match vs Replace

### Find — locate substrings

```go
re.FindString(s)                   // first match, as string
re.FindAllString(s, n)             // all matches
re.FindStringIndex(s)              // [start, end) of first match
re.FindAllStringIndex(s, n)        // all positions
re.FindStringSubmatch(s)           // first match + groups
re.FindAllStringSubmatch(s, n)     // all matches + groups
```

### Match — boolean test only

```go
re.MatchString(s)   // true/false
```

Prefer this over `FindString` when you only need a boolean — it can short-circuit earlier.

### Replace — transform strings

```go
// Replace all matches with a literal string
re.ReplaceAllString(s, "replacement")

// Replace with backreferences
re := regexp.MustCompile(`(\w+)\s(\w+)`)
re.ReplaceAllString("John Smith", "$2, $1")  // "Smith, John"

// Named backreferences
re := regexp.MustCompile(`(?P<first>\w+)\s(?P<last>\w+)`)
re.ReplaceAllString("John Smith", "${last}, ${first}")  // "Smith, John"

// Replace with a function (see §19)
re.ReplaceAllStringFunc(s, func(match string) string { ... })
```

### Split

```go
re := regexp.MustCompile(`\s+`)
re.Split("hello   world\tfoo", -1)   // ["hello", "world", "foo"]
re.Split("a,b,,c", 3)                // ["a", "b", "c"] — max 3 pieces
```

---

## 17. Streaming and Reader-Based Matching

`regexp.Regexp` has a method for matching against an `io.RuneReader`:

```go
func (re *Regexp) MatchReader(r io.RuneReader) bool
```

This is useful for large inputs or streams where you don't want to load the entire content into memory. Note: it only tells you *whether* a match exists, not where — there's no `FindReader` equivalent. For streaming search, you typically need to buffer and scan.

### Practical Streaming Scan

```go
func scanLines(r io.Reader, re *regexp.Regexp) []string {
    var results []string
    scanner := bufio.NewScanner(r)
    for scanner.Scan() {
        line := scanner.Text()
        if re.MatchString(line) {
            results = append(results, line)
        }
    }
    return results
}
```

For gigabyte-scale logs, process line by line — never read the whole file into a `[]byte`.

---

## 18. Named Groups and Structured Extraction

Named groups shine when extracting structured data from text. Here's a production-grade pattern for parsing log lines:

```go
var reLogLine = regexp.MustCompile(
    `(?P<timestamp>\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z)\s+` +
    `(?P<level>DEBUG|INFO|WARN|ERROR)\s+` +
    `(?P<caller>[^\s]+)\s+` +
    `(?P<message>.+)`,
)

type LogEntry struct {
    Timestamp string
    Level     string
    Caller    string
    Message   string
}

func parseLogLine(line string) (*LogEntry, bool) {
    m := reLogLine.FindStringSubmatch(line)
    if m == nil {
        return nil, false
    }

    names := reLogLine.SubexpNames()
    fields := make(map[string]string, len(names))
    for i, name := range names {
        if i != 0 && name != "" {
            fields[name] = m[i]
        }
    }

    return &LogEntry{
        Timestamp: fields["timestamp"],
        Level:     fields["level"],
        Caller:    fields["caller"],
        Message:   fields["message"],
    }, true
}
```

### Helper: Named Submatch Map

This utility is so commonly needed it's worth having in your toolbox:

```go
func namedMatches(re *regexp.Regexp, s string) map[string]string {
    m := re.FindStringSubmatch(s)
    if m == nil {
        return nil
    }
    result := make(map[string]string)
    for i, name := range re.SubexpNames() {
        if i != 0 && name != "" {
            result[name] = m[i]
        }
    }
    return result
}
```

---

## 19. Replace with a Function

`ReplaceAllStringFunc` is one of the most powerful and underused tools in Go's regex API. It lets you apply arbitrary transformation logic to each match:

```go
// Convert all hex colors to uppercase
re := regexp.MustCompile(`#[0-9a-fA-F]{6}`)
result := re.ReplaceAllStringFunc(input, strings.ToUpper)
```

```go
// Expand environment variables in a template
re := regexp.MustCompile(`\$\{(\w+)\}`)
result := re.ReplaceAllStringFunc(template, func(match string) string {
    key := match[2 : len(match)-1]  // strip ${ and }
    if val, ok := os.LookupEnv(key); ok {
        return val
    }
    return match  // leave unchanged if not found
})
```

```go
// Obfuscate credit card numbers
re := regexp.MustCompile(`\b(\d{4})[ -]?(\d{4})[ -]?(\d{4})[ -]?(\d{4})\b`)
result := re.ReplaceAllStringFunc(input, func(match string) string {
    // keep first 4 and last 4, mask the middle
    m := re.FindStringSubmatch(match)
    return m[1] + "-XXXX-XXXX-" + m[4]
})
```

> **Note:** `ReplaceAllStringFunc` does not give you access to submatch groups — the function receives the entire match string only. To access groups within the function, call `FindStringSubmatch` on the `match` argument with the same pattern.

### `ReplaceAllLiteralString`

If your replacement string contains `$` characters (like in a file path or dollar amount), use the `Literal` variant to prevent `$1`-style backreference expansion:

```go
re.ReplaceAllLiteralString(input, "price: $5.00")
// Without Literal, $5 would try to expand group 5
```

---

## 20. Building Patterns Programmatically

Sometimes a regex needs to be constructed from data. Do this carefully.

### Escaping User Input with `regexp.QuoteMeta`

```go
// User wants to find a literal string — could contain regex metacharacters
userInput := "price: $5.00 (or $10.00)"
escaped := regexp.QuoteMeta(userInput)
// "price: \$5\.00 \(or \$10\.00\)"

re := regexp.MustCompile(escaped)
```

**Always use `QuoteMeta` when interpolating user-controlled strings into patterns.** Failing to do so is a security vulnerability — at minimum it allows unexpected matches; in PCRE engines it enables ReDoS.

### Combining Patterns

```go
// Match any of a set of keywords
keywords := []string{"error", "fatal", "panic"}
escaped := make([]string, len(keywords))
for i, kw := range keywords {
    escaped[i] = regexp.QuoteMeta(kw)
}
pattern := `(?i)\b(` + strings.Join(escaped, `|`) + `)\b`
re := regexp.MustCompile(pattern)
```

### Building Complex Validators

```go
const (
    reYear   = `(?P<year>\d{4})`
    reMonth  = `(?P<month>0[1-9]|1[0-2])`
    reDay    = `(?P<day>0[1-9]|[12]\d|3[01])`
    reSep    = `[-/.]`
)

var reDate = regexp.MustCompile(`\A` + reYear + reSep + reMonth + reSep + reDay + `\z`)
```

This compositional approach makes complex patterns readable and maintainable.

---

## 21. Testing Regex in Go

### Table-Driven Tests

Regex correctness is best verified with table-driven tests covering true positives, true negatives, and edge cases:

```go
func TestEmailRegex(t *testing.T) {
    tests := []struct {
        input string
        want  bool
    }{
        {"user@example.com", true},
        {"user.name+tag@example.co.uk", true},
        {"user@", false},
        {"@example.com", false},
        {"user @example.com", false},  // space
        {"user@example", false},       // no TLD
        {"", false},
    }

    for _, tt := range tests {
        t.Run(tt.input, func(t *testing.T) {
            got := reEmail.MatchString(tt.input)
            if got != tt.want {
                t.Errorf("MatchString(%q) = %v, want %v", tt.input, got, tt.want)
            }
        })
    }
}
```

### Testing Submatches

```go
func TestDateParsing(t *testing.T) {
    m := reDate.FindStringSubmatch("2024-03-15")
    require.NotNil(t, m)

    named := namedMatches(reDate, "2024-03-15")
    assert.Equal(t, "2024", named["year"])
    assert.Equal(t, "03", named["month"])
    assert.Equal(t, "15", named["day"])
}
```

### Fuzz Testing Regex

Go 1.18+ fuzz testing is extremely valuable for regex — it finds edge cases you'd never think to write:

```go
func FuzzParseLogLine(f *testing.F) {
    f.Add("2024-01-01T00:00:00Z INFO main.go:42 hello world")
    f.Fuzz(func(t *testing.T, s string) {
        // Should never panic, regardless of input
        parseLogLine(s)
    })
}
```

---

## 22. Performance: Benchmarking and Optimization

### Benchmark Template

```go
var reWords = regexp.MustCompile(`\b\w+\b`)
var corpus = strings.Repeat("the quick brown fox jumps over the lazy dog ", 1000)

func BenchmarkFindAllWords(b *testing.B) {
    for b.Loop() {
        reWords.FindAllString(corpus, -1)
    }
}
```

Run with: `go test -bench=. -benchmem -benchtime=5s`

### Optimization Techniques

**1. Anchor early when possible**

```go
// Slower — must try at every position:
regexp.MustCompile(`\d{4}-\d{2}-\d{2}`)

// Faster for full-string validation:
regexp.MustCompile(`\A\d{4}-\d{2}-\d{2}\z`)
```

**2. Prefer `MatchString` over `FindString` for boolean checks**

```go
// Unnecessary work — allocates a string
re.FindString(s) != ""

// Correct — short-circuits, no allocation
re.MatchString(s)
```

**3. Use `[]byte` variants for []byte inputs**

Avoid converting `[]byte` to `string` and back:

```go
re.Match(data)          // takes []byte directly
re.FindAll(data, -1)    // returns [][]byte
```

**4. Minimize group count**

Every capturing group requires the engine to record indices. Use `(?:...)` for grouping without capture when you don't need the submatch.

**5. Profile before optimizing**

```go
import _ "net/http/pprof"
// go tool pprof http://localhost:6060/debug/pprof/profile
```

Regex is rarely the bottleneck unless it's compiled in a hot path or applied to very large inputs.

### When Regex Is Too Slow

For high-throughput scenarios, consider:

- `strings.Contains` / `strings.Index` for literal search (Boyer-Moore under the hood)
- `bytes.IndexByte` for single-byte search
- `strings.Fields` / `strings.Split` for delimiter-based tokenization
- Aho-Corasick for multi-pattern literal search (`cloudflare/ahocorasick`)
- SIMD-accelerated search libraries for bulk text processing

---

## 23. Common Patterns and Pitfalls

### Validated Patterns

```go
// Email (pragmatic, not RFC 5321 complete)
var reEmail = regexp.MustCompile(`\A[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}\z`)

// UUID v4
var reUUID = regexp.MustCompile(`(?i)\A[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}\z`)

// IPv4 address
var reIPv4 = regexp.MustCompile(`\A(?:(?:25[0-5]|2[0-4]\d|[01]?\d\d?)\.){3}(?:25[0-5]|2[0-4]\d|[01]?\d\d?)\z`)

// IPv6 (simplified)
var reIPv6 = regexp.MustCompile(`(?i)\A[0-9a-f:]+\z`)

// Semantic version
var reSemVer = regexp.MustCompile(`\Av?(?P<major>\d+)\.(?P<minor>\d+)\.(?P<patch>\d+)(?:-(?P<pre>[0-9A-Za-z.-]+))?(?:\+(?P<build>[0-9A-Za-z.-]+))?\z`)

// ISO 8601 date
var reISO8601 = regexp.MustCompile(`\A\d{4}-(?:0[1-9]|1[0-2])-(?:0[1-9]|[12]\d|3[01])(?:T(?:[01]\d|2[0-3]):[0-5]\d:[0-5]\d(?:Z|[+-][01]\d:[0-5]\d))?\z`)

// Slug
var reSlug = regexp.MustCompile(`\A[a-z0-9]+(?:-[a-z0-9]+)*\z`)

// Go import path
var reImportPath = regexp.MustCompile(`\A[a-zA-Z0-9_.\-/]+\z`)
```

### Common Pitfalls

**Pitfall 1 — Partial matching by default**

`MatchString` returns true if the pattern matches *anywhere* in the string. Always use `\A...\z` for full-string validation.

```go
reYear := regexp.MustCompile(`\d{4}`)
reYear.MatchString("abc1234def")  // true! matched "1234" inside
```

**Pitfall 2 — `FindAll` with `n=0`**

Passing `n=0` to `FindAll` returns nil — it means "return 0 results." Use `-1` for "return all."

```go
re.FindAllString(s, 0)   // nil — common bug
re.FindAllString(s, -1)  // all matches — correct
```

**Pitfall 3 — Forgetting that `$` matches before `\n`**

In default mode, `$` matches at end-of-string OR just before a trailing `\n`. Use `\z` to match only at the absolute end.

```go
re := regexp.MustCompile(`\d+$`)
re.MatchString("123\n")  // true in many engines — $ matched before \n
```

**Pitfall 4 — `ReplaceAllString` backreference injection**

If replacement strings come from user input, use `ReplaceAllLiteralString` or escape `$` characters:

```go
userReplacement := strings.ReplaceAll(userInput, "$", "$$")
```

**Pitfall 5 — Empty pattern matches**

Patterns that can match the empty string (like `\d*`) produce matches everywhere:

```go
re := regexp.MustCompile(`\d*`)
re.FindAllString("a1b", -1)
// ["", "1", "", ""]  ← empty matches between/after chars
```

---

## 24. Regex vs Parser: Knowing the Limit

Regex is for **regular languages**. Many common text formats are **not regular** — they have recursive or nested structure that requires a proper parser.

### Things Regex Cannot Reliably Do

| Task | Why regex fails | Use instead |
|---|---|---|
| Parse HTML/XML | Arbitrary nesting depth | `golang.org/x/net/html`, `encoding/xml` |
| Parse JSON | Nested structures | `encoding/json` |
| Parse Go source | Recursive grammar | `go/parser`, `go/ast` |
| Balanced brackets | Requires a stack | Push-down automaton |
| Validate email (RFC 5321) | Grammar is context-free | Dedicated library |
| Extract SQL subqueries | Nested structure | SQL parser |

### The Balancing Act

You can use regex effectively for:

- Identifying lines that *contain* JSON (grep-style)
- Extracting simple top-level fields from predictably structured strings
- Pre-filtering before passing to a proper parser
- Post-processing parser output

The principle: **use regex for lexing, parsers for structure.**

---

## 25. POSIX Mode in Go

Go provides POSIX ERE (Extended Regular Expressions) semantics via `regexp.CompilePOSIX` and `regexp.MustCompilePOSIX`.

### POSIX Leftmost-Longest Semantics

POSIX specifies that when multiple matches are possible at the same start position, the **longest** one wins. Each subgroup also matches as long as possible. This differs from RE2's leftmost-first semantics.

```go
re    := regexp.MustCompile(`a(b|bb)`)
rePOX := regexp.MustCompilePOSIX(`a(b|bb)`)

re.FindStringSubmatch("abb")    // ["ab", "b"]   ← leftmost-first: takes b
rePOX.FindStringSubmatch("abb") // ["abb", "bb"] ← leftmost-longest: takes bb
```

### When to Use POSIX Mode

- When you need strict POSIX compliance (e.g., implementing POSIX-compatible tools in Go)
- When interoperating with systems that use POSIX ERE (awk, sed, grep without -P)
- When you explicitly want longest-match semantics for lexer tokenization

### POSIX Restrictions

POSIX mode additionally disallows some RE2-isms:

- Named groups `(?P<name>...)` are not valid in POSIX ERE (use numbered groups)
- Non-greedy quantifiers `*?` are not part of POSIX ERE

---

## 26. Related Tools and Ecosystem

### `regexp/syntax` — Pattern Introspection

The standard library's `regexp/syntax` package exposes the full parser, AST, and compiler. Use it to:

- Validate patterns before storing them
- Build regex linters
- Generate descriptive error messages
- Analyze pattern complexity

```go
import "regexp/syntax"

_, err := syntax.Parse(pattern, syntax.RE2)
if err != nil {
    fmt.Println("invalid pattern:", err)
}
```

### `dlclark/regexp2` — PCRE-Compatible Engine in Go

If you genuinely need lookaheads, lookbehinds, or backreferences, `github.com/dlclark/regexp2` is a pure-Go port of .NET's regex engine (which is PCRE-compatible). Use it knowing you've opted out of the linear-time guarantee.

```go
import "github.com/dlclark/regexp2"

re := regexp2.MustCompile(`(?<=@)\w+`, 0)
m, _ := re.FindStringMatch("user@example.com")
fmt.Println(m.String())  // "example"
```

### `google/re2` — C++ RE2 via CGo

`github.com/google/re2/go/re2` provides Go bindings to the C++ RE2 library. Useful when you need the same semantics as Go's built-in but want the performance of the native C++ implementation for very high-throughput workloads.

### Regex Testing and Visualization Tools

| Tool | Use |
|---|---|
| [regex101.com](https://regex101.com) | Interactive tester with Go (RE2) flavor |
| [regexr.com](https://regexr.com) | Visual match highlighting |
| [debuggex.com](https://debuggex.com) | NFA/DFA railroad diagram visualization |
| [recheck.github.io](https://makenowjust-labs.github.io/recheck/) | ReDoS vulnerability analyzer |

Select the **Golang** flavor on regex101 to use RE2 semantics specifically.

### `grep` and `ripgrep` with RE2

`ripgrep` (`rg`) defaults to Rust's `regex` crate which shares RE2 semantics. It's the fastest grep-compatible tool and uses the same linear-time guarantee. Patterns you develop in Go's `regexp` package will behave identically in `rg`.

```sh
# Same RE2 syntax as Go:
rg '(?P<year>\d{4})-(?P<month>\d{2})' logs/

# -o prints only the match:
rg -o '\bERROR\b.*' app.log

# Use Go-compatible patterns with --engine re2 in newer builds:
rg --engine re2 '\p{Han}+' data.txt
```

### `awk` and `sed` (POSIX ERE)

`awk` and POSIX `sed` use POSIX ERE — a subset of RE2 without lookaheads, named groups, or non-greedy quantifiers. Useful for quick CLI text processing:

```sh
# awk — print lines where field 3 matches a date
awk '$3 ~ /^[0-9]{4}-[0-9]{2}-[0-9]{2}$/' logfile

# sed — replace all version strings
sed -E 's/v[0-9]+\.[0-9]+\.[0-9]+/VERSIONSTRING/g' file.txt
```

### Linters and Static Analysis

- **`go vet`** — catches `regexp.MustCompile` called with invalid patterns
- **`staticcheck`** — detects redundant regex escapes, inefficient patterns
- **`revive`** — configurable linter with regex-related rules
- Custom AST analysis via `regexp/syntax` can be embedded in `analysis.Analyzer` passes for organization-specific regex standards

---

*Built for RE2 / Go `regexp`. All patterns tested against Go 1.22+. For PCRE-specific features, see `dlclark/regexp2`.*

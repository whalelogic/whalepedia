# PowerShell Strings

PowerShell uses .NET `System.String` plus shell operators for practical text processing.

## Common String Methods and Operators

| Method / Operator | Purpose | Example |
| --- | --- | --- |
| `.Length` | String length | `$s.Length` |
| `.Contains()` | Substring check | `$s.Contains('api')` |
| `.StartsWith()` / `.EndsWith()` | Prefix/suffix checks | `$s.StartsWith('pre')` |
| `.Substring()` | Extract section | `$s.Substring(0, 5)` |
| `.Split()` / `-split` | Split into array | `$s -split ','` |
| `.Replace()` / `-replace` | Replacement (`-replace` supports regex) | `$s -replace '-', ' '` |
| `.Trim()` / `.TrimStart()` / `.TrimEnd()` | Trim whitespace/chars | `$s.Trim()` |
| `.ToUpper()` / `.ToLower()` | Case conversion | `$s.ToLower()` |
| `.IndexOf()` / `.LastIndexOf()` | Find position | `$s.IndexOf('/')` |
| `-match` | Regex test and captures | `$s -match '\w+'` |

## Examples

```powershell
$raw = ' whale-pedia '
$clean = $raw.Trim() -replace '-', ' '
$parts = $clean -split ' '
```

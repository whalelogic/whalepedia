# PowerShell Functions

PowerShell functions support advanced cmdlet-style behavior and pipeline input.

## Function Patterns

| Pattern | Purpose | Example |
| --- | --- | --- |
| `function Name {}` | Basic reusable function | `function Get-User { ... }` |
| `param(...)` | Typed parameter definition | `param([string]$Name)` |
| `[CmdletBinding()]` | Enable advanced function features | `[CmdletBinding()] param(...)` |
| Pipeline blocks | Structured pipeline handling | `begin { } process { } end { }` |
| `return` / output stream | Emit values to pipeline | `return $result` |

## Common Built-in Cmdlets for Function Workflows

| Cmdlet | Purpose | Example |
| --- | --- | --- |
| `Write-Output` / `Write-Host` | Emit output | `Write-Output $value` |
| `Write-Error` / `Throw` | Signal errors | `Throw "Invalid input"` |
| `Get-Command` | Inspect available commands | `Get-Command Get-*` |
| `ForEach-Object` / `Where-Object` | Functional-style pipeline transforms | `$items | ForEach-Object { ... }` |
| `Measure-Command` | Profile function execution time | `Measure-Command { Invoke-Task }` |

## Examples

```powershell
function Get-Greeting {
  [CmdletBinding()]
  param([Parameter(Mandatory)] [string]$Name)
  "Hello, $Name"
}
```

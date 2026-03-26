---
name: powershell
description: >
  Standards and best practices for PowerShell script development.
  Use this skill whenever writing, reviewing, scaffolding, or refactoring any
  PowerShell code — including .ps1 scripts, .psm1 modules, Pester tests, or
  any task involving PowerShell functions, error handling, CBH documentation,
  parameter design, naming conventions, security, compliance, or code quality.
  Also use when the user asks to create a new PowerShell project, review existing
  scripts for standards compliance, or generate boilerplate/templates.
---

# PowerShell Development Standards

## Script Tiers

Apply standards based on the script's purpose:

| Tier | Examples | Apply |
|------|----------|-------|
| **Quick** | One-off tasks, personal automation | Core Standards |
| **Shared/Reusable** | Scripts used by others or across projects | Core + Testing |
| **Production** | Deployed scripts, CI/CD, regulated environments | Core + Testing + Production |

When context is unclear, default to Core Standards and ask if testing or production requirements apply.

---

## Core Standards

Always apply these regardless of script tier.

### 1. Comment-Based Help (CBH)
- Include CBH at the top of every script and reusable function
- Quick scripts: `.SYNOPSIS` and `.EXAMPLE` are sufficient
- Shared/production scripts: include `.SYNOPSIS`, `.DESCRIPTION`, `.PARAMETER`, `.EXAMPLE`, `.NOTES`
- Use proper CBH keywords: `.SYNOPSIS`, `.DESCRIPTION`, `.PARAMETER`, `.EXAMPLE`, `.NOTES`

### 2. Parameter Splatting
- Use splatting when a command has more than two parameters
- Use descriptive hashtable variable names ending in `Params` or `Splat`
- Format splatting with proper indentation

### 3. Error Handling
- Use `try-catch-finally` blocks for error-prone operations
- Set `$ErrorActionPreference = 'Stop'` at script level when appropriate
- Provide meaningful error messages

### 4. Naming Conventions
- Use approved PowerShell verbs (`Get-Verb` for list)
- Use PascalCase for function names: `Get-UserData`
- Use PascalCase for variables: `$UserList`
- Use UPPER_CASE for constants: `$MAX_RETRIES`
- Use descriptive names, avoid abbreviations
- Always use full command names (no aliases like `gps` instead of `Get-Process`)
- Always use full parameter names (avoid abbreviated parameters)

### 5. Code Formatting
- Use 4-space indentation (no tabs)
- Place opening braces on same line as statement (One True Brace Style)
- Closing braces on their own line
- Place `catch`, `finally`, `elseif`, and `while` (in do-while) on their own line
- Use blank lines to separate logical sections
- Limit lines to 115 characters
- Use consistent spacing around operators
- Avoid unnecessary spaces inside parentheses or square brackets
- End each file with a single blank line
- Surround function definitions with two blank lines

### 6. Functions and Modules
- Keep functions focused on single responsibility
- Always start functions with `[CmdletBinding()]`
- Use explicit `param()`, `begin`, `process`, `end` block order
- Include proper parameter attributes: `[Parameter(Mandatory)]`
- Return objects, not formatted text
- Use pipeline-friendly functions
- Avoid using semicolons as line terminators

#### Begin/Process/End Block Usage
```powershell
function Get-Something {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)]
        [string[]]$InputObject
    )

    begin {
        # One-time initialization, connections, result arrays
        $Results = @()
    }

    process {
        # Runs for each pipeline input
        foreach ($Item in $InputObject) {
            $Results += Process-Item $Item
        }
    }

    end {
        # Cleanup, close connections, return results
        $Results
    }
}
```

### 7. Path Usage
- Prefer `$PSScriptRoot` for script-relative paths
- Avoid relative paths like `./README.md` and `~` for home folder
- Sanitize file paths and validate user input

### 8. Security
- Never hardcode credentials or sensitive data
- Use `SecureString` or the SecretManagement module for passwords
- Use least privilege principle

### 9. Performance
- Use `Where-Object` efficiently (avoid unnecessary filtering)
- Prefer `ForEach-Object` over `foreach` for large pipeline datasets
- Use `StringBuilder` for string concatenation in loops
- Avoid `Write-Host` in functions (use `Write-Output` or `Write-Information`)

---

## Production & Shared Scripts

Apply these in addition to Core Standards when the script is shared, reusable, or deployed.

### Testing (Shared/Production)
- Write Pester tests for all exported functions
- Target 80% code coverage for production scripts
- Test both success and failure scenarios
- Use mock objects for external dependencies

```powershell
Invoke-Pester -Path ./Tests -CodeCoverage ./Scripts/*.ps1 -CoveragePercentTarget 80
```

### Documentation (Shared/Production)
- Maintain a README.md with setup and usage instructions
- Document all configuration requirements and examples

### Code Quality (Shared/Production)
- Run `Invoke-ScriptAnalyzer` and address all Error/Warning level issues
- Use `.vscode/settings.json` for consistent formatting

```powershell
Invoke-ScriptAnalyzer -Path ./Scripts -Recurse -Settings PSGallery -Severity Error,Warning
```

### Compliance (Production — when applicable)
Apply only when the script handles regulated data or runs in a regulated environment:
- SOX: audit trails for financial data access and modifications
- HIPAA: secure handling and logging for healthcare information
- GDPR: data retention, deletion, and access controls for personal data

### Enterprise Integration (Production — when applicable)
- Structured logging with correlation IDs
- Integration with enterprise monitoring and alerting
- Centralized configuration and secrets management
- Change management and deployment pipeline compliance

---

## Project Structure (Shared/Production)

```
ProjectName/
├── Scripts/          # Main PowerShell scripts
├── Modules/          # Custom PowerShell modules
├── Tests/            # Pester tests
├── Docs/             # Documentation
├── Config/           # Configuration files
└── README.md
```

---

## Example Commands

### Code Analysis
```powershell
Invoke-ScriptAnalyzer -Path ./Scripts -Recurse -Settings PSGallery -Severity Error,Warning
```

### Running Tests
```powershell
Invoke-Pester -Path ./Tests -CodeCoverage ./Scripts/*.ps1 -CoveragePercentTarget 80
```

### Building Documentation
```powershell
# PlatyPS — for modules with external help
New-ExternalHelp -Path ./Docs -OutputPath ./en-US
```

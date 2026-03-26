#Requires -Version 5.1
<#
.SYNOPSIS
    Uninstalls claude-skills by removing symlinks from ~/.claude/skills/
.DESCRIPTION
    Removes symlinks created by install.ps1. Only removes symlinks — non-symlink
    items at the same path are skipped with a warning.
#>

[CmdletBinding()]
param ()

$SkillsSrc = Join-Path $PSScriptRoot 'skills'
$SkillsDest = Join-Path $HOME '.claude\skills'

foreach ($SkillDir in Get-ChildItem -Path $SkillsSrc -Directory) {
    $Target = Join-Path $SkillsDest $SkillDir.Name

    if (Test-Path $Target) {
        $Item = Get-Item $Target
        if ($Item.LinkType -eq 'SymbolicLink') {
            Remove-Item $Target
            Write-Host "Removed: $($SkillDir.Name)"
        }
        else {
            Write-Warning "Skipping '$($SkillDir.Name)': $Target exists but is not a symlink"
        }
    }
}

Write-Host "Done. Restart Claude to apply changes."

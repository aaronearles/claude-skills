#Requires -Version 5.1
<#
.SYNOPSIS
    Installs claude-skills by symlinking skill directories into ~/.claude/skills/
.DESCRIPTION
    Creates symlinks from each skills/<name>/ directory into $HOME\.claude\skills\
    so Claude Code picks them up automatically. Run once per machine, or re-run
    after adding new skills.
.NOTES
    Symlink creation requires one of:
      - Windows Developer Mode enabled (Settings > System > For developers), OR
      - PowerShell run as Administrator
#>

[CmdletBinding()]
param ()

# Check symlink permission: Developer Mode or elevated session required
$devMode = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock' -ErrorAction SilentlyContinue).AllowDevelopmentWithoutDevLicense -eq 1
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $devMode -and -not $isAdmin) {
    Write-Error "Symlink creation requires either Windows Developer Mode or an elevated (Administrator) PowerShell session.`nEnable Developer Mode: Settings > System > For developers"
    exit 1
}

$SkillsSrc = Join-Path $PSScriptRoot 'skills'
$SkillsDest = Join-Path $HOME '.claude\skills'

if (-not (Test-Path $SkillsDest)) {
    New-Item -ItemType Directory -Path $SkillsDest | Out-Null
}

foreach ($SkillDir in Get-ChildItem -Path $SkillsSrc -Directory) {
    $Target = Join-Path $SkillsDest $SkillDir.Name

    if (Test-Path $Target) {
        $Item = Get-Item $Target
        if ($Item.LinkType -eq 'SymbolicLink') {
            Remove-Item $Target
        }
        else {
            Write-Warning "Skipping '$($SkillDir.Name)': $Target exists and is not a symlink"
            continue
        }
    }

    New-Item -ItemType SymbolicLink -Path $Target -Target $SkillDir.FullName | Out-Null
    Write-Host "Linked: $($SkillDir.Name)"
}

Write-Host "Done. Restart Claude to pick up changes."

# Inject Update-Skills function into PowerShell profile
$FunctionBlock = @'

# BEGIN claude-skills
function Update-Skills {
    $SkillLink = Get-ChildItem -Path "$HOME\.claude\skills" -Directory | Select-Object -First 1
    if (-not $SkillLink) {
        Write-Error 'update-skills: no skills found in ~/.claude/skills/'
        return
    }
    $Target = (Get-Item $SkillLink.FullName).Target
    $Repo = git -C $Target rev-parse --show-toplevel 2>$null
    if (-not $Repo) {
        Write-Error "update-skills: could not locate git repo from $Target"
        return
    }
    git -C $Repo pull
}
Set-Alias -Name update-skills -Value Update-Skills -Scope Global
# END claude-skills
'@

if (-not (Test-Path $PROFILE)) {
    New-Item -ItemType File -Path $PROFILE -Force | Out-Null
}

$ProfileContent = Get-Content $PROFILE -Raw -ErrorAction SilentlyContinue
if ($ProfileContent -notmatch '# BEGIN claude-skills') {
    Add-Content -Path $PROFILE -Value $FunctionBlock
    Write-Host "Added update-skills to $PROFILE"
    Write-Host "Restart your shell or run '. `$PROFILE' to use update-skills."
} else {
    Write-Host "update-skills already present in $PROFILE — skipping"
}

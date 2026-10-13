# Installs Claude Code-style memory for the GitHub Copilot app (Windows).
#   powershell -ExecutionPolicy Bypass -File .\install.ps1
# Safe to re-run: existing memories are never touched; skills are refreshed.
$ErrorActionPreference = 'Stop'
$kit = $PSScriptRoot

# 1. Global memory root (per-project folders are created by the agent on first write).
$memRoot = Join-Path $HOME '.copilot-memory\projects'
New-Item -ItemType Directory -Force -Path $memRoot | Out-Null
Write-Host "Memory root: $memRoot"

# 2. Personal skills: /remember and /consolidate-memory.
$skillsDir = Join-Path $HOME '.copilot\skills'
foreach ($name in 'remember', 'consolidate-memory') {
    $dst = Join-Path $skillsDir $name
    New-Item -ItemType Directory -Force -Path $dst | Out-Null
    Copy-Item -Force (Join-Path $kit "skills\$name\SKILL.md") (Join-Path $dst 'SKILL.md')
    Write-Host "Skill installed: $dst"
}

# 3. App instructions go into the app's settings UI; put them on the clipboard.
Get-Content -Raw -Encoding UTF8 (Join-Path $kit 'app-instructions.md') | Set-Clipboard
Write-Host ''
Write-Host 'App instructions copied to the clipboard. Now in the GitHub Copilot app:'
Write-Host '  Settings -> Sessions -> Instructions -> App instructions -> paste -> save.'
Write-Host 'If App instructions already has text, append the memory rules below it.'

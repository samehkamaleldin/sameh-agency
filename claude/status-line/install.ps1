#!/usr/bin/env pwsh
# Claude Statusline — Windows installer (PowerShell)
# Usage:
#   irm https://raw.githubusercontent.com/samehkamaleldin/sameh-statusline/main/install.ps1 | iex
#
# What it does:
#   1. Downloads statusline.py to %USERPROFILE%\.claude\
#   2. Adds the statusLine entry to %USERPROFILE%\.claude\settings.json (preserves existing settings)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
# GitHub requires TLS 1.2+ (matters on Windows PowerShell 5.1).
try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch {}

$RepoRaw      = 'https://raw.githubusercontent.com/samehkamaleldin/sameh-statusline/main'
# Match Claude Code's config location: it uses os.homedir() == %USERPROFILE% on
# Windows, which can differ from PowerShell 5.1's $HOME (HOMEDRIVE+HOMEPATH) on
# roaming/enterprise profiles. Fall back to $HOME on non-Windows pwsh.
$HomeDir      = if ($env:USERPROFILE) { $env:USERPROFILE } else { $HOME }
$InstallDir   = Join-Path $HomeDir '.claude'
$ScriptName   = 'statusline.py'
$ScriptPath   = Join-Path $InstallDir $ScriptName
$SettingsFile = Join-Path $InstallDir 'settings.json'

function Write-Info($m) { Write-Host "[info]  $m" -ForegroundColor Blue }
function Write-Ok($m)   { Write-Host "[ok]    $m" -ForegroundColor Green }
function Write-Fail($m) { Write-Host "[error] $m" -ForegroundColor Red }

# -- Preflight: find a Python 3.10+ interpreter -------------------------------
$python = $null
foreach ($cand in @(
        @{ Exe = 'py';      Pre = @('-3') },
        @{ Exe = 'python';  Pre = @() },
        @{ Exe = 'python3'; Pre = @() })) {
    if (-not (Get-Command $cand.Exe -ErrorAction SilentlyContinue)) { continue }
    # A <3.10 interpreter exits non-zero on purpose; PowerShell 7.4+ turns a
    # non-zero native exit into a terminating error (ErrorActionPreference=Stop),
    # so probe inside try/catch and just fall through to the next candidate.
    $ok = $false
    try {
        $checkArgs = @($cand.Pre) + @('-c', 'import sys; sys.exit(0 if sys.version_info >= (3, 10) else 1)')
        & $cand.Exe @checkArgs 2>$null
        $ok = ($LASTEXITCODE -eq 0)
    } catch {
        $ok = $false
    }
    if ($ok) { $python = $cand; break }
}

if (-not $python) {
    Write-Fail 'Python 3.10+ is required but was not found (tried: py -3, python, python3).'
    Write-Fail 'Install it from https://www.python.org/downloads/ or run: winget install Python.Python.3.12'
    throw 'Python 3.10+ not found.'
}

$PythonCmd = (@($python.Exe) + $python.Pre) -join ' '
Write-Ok "Found Python: $PythonCmd"

# -- Download -----------------------------------------------------------------
New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null
Write-Info 'Downloading statusline.py ...'
Invoke-WebRequest -Uri "$RepoRaw/$ScriptName" -OutFile $ScriptPath -UseBasicParsing
Write-Ok "Installed $ScriptPath"

# -- Configure settings.json --------------------------------------------------
# Forward slashes need no JSON/shell escaping and Python reads them fine on Windows.
$CmdPath       = $ScriptPath -replace '\\', '/'
$StatusLineCmd = "$PythonCmd `"$CmdPath`""

if (Test-Path $SettingsFile) {
    try {
        $raw = Get-Content -Raw -Path $SettingsFile
        $settings = if ([string]::IsNullOrWhiteSpace($raw)) { [pscustomobject]@{} } else { $raw | ConvertFrom-Json }
    } catch {
        throw "Could not parse $SettingsFile as JSON. Fix or remove it, then re-run."
    }
    if ($settings.PSObject.Properties.Name -contains 'statusLine') {
        Write-Info 'statusLine already configured — updating command.'
    } else {
        Write-Info 'Adding statusLine to existing settings.json ...'
    }
} else {
    Write-Info 'Creating settings.json ...'
    $settings = [pscustomobject]@{ '$schema' = 'https://json.schemastore.org/claude-code-settings.json' }
}

$statusLine = [pscustomobject]@{ type = 'command'; command = $StatusLineCmd }
$settings | Add-Member -NotePropertyName 'statusLine' -NotePropertyValue $statusLine -Force

# Write UTF-8 without a BOM so Claude Code parses it cleanly across PowerShell versions.
$json = $settings | ConvertTo-Json -Depth 32
[System.IO.File]::WriteAllText($SettingsFile, $json + "`n")
Write-Ok "Configured $SettingsFile"

# -- Done ---------------------------------------------------------------------
Write-Host ''
Write-Ok 'Claude Statusline installed!'
Write-Info 'Restart Claude Code to see your new status bar.'
Write-Info 'Requires a Nerd Font (Hack, FiraCode, JetBrains Mono, ...) set as your terminal font.'
Write-Host ''

param(
    [string[]]$Paths = @(
        'resources/[local]/**/*.lua',
        'resources/[qbx]/**/*.lua',
        'resources/[standalone]/**/*.lua'
    ),
    [switch]$Strict
)

$ErrorActionPreference = 'Stop'

function Fail($msg){ Write-Host $msg -ForegroundColor Red; exit 1 }

if (-not (Get-Command luacheck -ErrorAction SilentlyContinue)) {
    Fail "luacheck not found. Run scripts/install-lua.ps1 first."
}

$severity = if ($Strict) { '--std=max' } else { '--std=lua54' }
$exit = 0

foreach ($glob in $Paths) {
    Write-Host "Linting $glob" -ForegroundColor Cyan
    $files = Get-ChildItem -Path $glob -Recurse -ErrorAction SilentlyContinue
    if ($files) {
        luacheck $files.FullName --codes $severity --no-color | Out-Host
        if ($LASTEXITCODE -ne 0) { $exit = $LASTEXITCODE }
    }
}

exit $exit



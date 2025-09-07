# Windows Lua toolchain installer (Lua + LuaRocks + luacheck)
param(
    [switch]$Force
)

$ErrorActionPreference = 'Stop'

function Test-Command {
    param([string]$Name)
    try { return $null -ne (Get-Command $Name -ErrorAction Stop) } catch { return $false }
}

function Ensure-InPath {
    param([string]$PathToAdd)
    if (-not [string]::IsNullOrWhiteSpace($PathToAdd)) {
        $envPath = [System.Environment]::GetEnvironmentVariable('PATH', 'User')
        if ($envPath -notlike "*${PathToAdd}*") {
            [System.Environment]::SetEnvironmentVariable('PATH', "$envPath;$PathToAdd", 'User')
            Write-Host "Added to PATH for current user: $PathToAdd" -ForegroundColor Yellow
        }
    }
}

Write-Host "==> Installing/validating Lua toolchain (Windows)" -ForegroundColor Cyan

# 1) Lua
if ($Force -or -not (Test-Command lua)) {
    Write-Host "Installing Lua (preferred: winget)" -ForegroundColor Cyan
    if (Test-Command winget) {
        winget install -e --id Lua.Lua --accept-source-agreements --accept-package-agreements | Out-Host
    } elseif (Test-Command choco) {
        choco install -y lua | Out-Host
    } elseif (Test-Command scoop) {
        scoop install lua | Out-Host
    } else {
        Write-Warning "No package manager found (winget/choco/scoop). Please install Lua manually from https://www.lua.org/download.html or install winget."
    }
} else {
    Write-Host "Lua already installed: $(lua -v)" -ForegroundColor Green
}

# 2) LuaRocks
if ($Force -or -not (Test-Command luarocks)) {
    Write-Host "Installing LuaRocks" -ForegroundColor Cyan
    if (Test-Command winget) {
        winget install -e --id LuaRocks.LuaRocks --accept-source-agreements --accept-package-agreements | Out-Host
    } elseif (Test-Command choco) {
        choco install -y luarocks | Out-Host
    } elseif (Test-Command scoop) {
        scoop install luarocks | Out-Host
    } else {
        Write-Warning "No package manager found for LuaRocks. Install manually from https://luarocks.org/#quick-start."
    }
} else {
    Write-Host "LuaRocks already installed: $(luarocks --version | Select-Object -First 1)" -ForegroundColor Green
}

# 3) luacheck (Lua linter)
if ($Force -or -not (Test-Command luacheck)) {
    Write-Host "Installing luacheck via LuaRocks" -ForegroundColor Cyan
    try {
        luarocks install luacheck | Out-Host
    } catch {
        Write-Warning "Failed to install luacheck via luarocks. Ensure LuaRocks is on PATH."
    }
    # Common install paths (best-effort add to PATH)
    $common = @(
        "$env:ProgramFiles\\LuaRocks",
        "$env:ProgramFiles(x86)\\LuaRocks",
        "$env:LOCALAPPDATA\\luarocks\\bin"
    )
    $common | ForEach-Object { Ensure-InPath $_ }
}

Write-Host "==> Toolchain ready" -ForegroundColor Green
Write-Host "lua:    " -NoNewline; if (Test-Command lua) { lua -v }
Write-Host "luarocks: " -NoNewline; if (Test-Command luarocks) { (luarocks --version | Select-Object -First 1) }
Write-Host "luacheck: " -NoNewline; if (Test-Command luacheck) { luacheck --version }

Write-Host "Tip: If scripts do not run, enable: Set-ExecutionPolicy -Scope CurrentUser RemoteSigned -Force" -ForegroundColor Yellow

 
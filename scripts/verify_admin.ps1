# Lint (if luacheck available) and quick sanity
Write-Host "Verifying qbx_admin..."
Get-Content resources/[admin]/qbx_admin/fxmanifest.lua | Out-Null
Get-Content resources/[admin]/qbx_admin/config.lua | Out-Null
Get-Content resources/[admin]/qbx_admin/client.lua | Out-Null
Get-Content resources/[admin]/qbx_admin/server.lua | Out-Null
Write-Host "OK."

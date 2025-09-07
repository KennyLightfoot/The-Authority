# Backup script for Qbox deployment updates
Write-Host "📦 Creating backup of current deployment..." -ForegroundColor Yellow

$backupName = "qbox_backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
$backupPath = "backups/$backupName"

New-Item -ItemType Directory -Path "backups" -Force | Out-Null
Copy-Item -Path "txData/Qbox_BD27E6.base" -Destination "$backupPath" -Recurse

Write-Host "✅ Backup created: $backupPath" -ForegroundColor Green
Write-Host "💡 To restore: Copy the backup back to txData/" -ForegroundColor Cyan

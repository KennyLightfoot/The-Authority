fx_version 'cerulean'
game 'gta5'

name 'audit_logs'
description 'Audit logging to DB + Discord webhook'
version '0.1.0'
lua54 'yes'

server_scripts {
  '@oxmysql/lib/MySQL.lua',
  'server.lua',
}

provide 'audit_logs'



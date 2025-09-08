fx_version 'cerulean'
game 'gta5'

name 'qbx_admin'
description 'Lightweight admin menu for QBX/QBCore using ox_lib'
author 'The Authority RP'
version '1.0.0'

lua54 'yes'

shared_scripts {
  '@ox_lib/init.lua',
  'config.lua'
}

client_scripts {
  'client.lua'
}

server_scripts {
  '@oxmysql/lib/MySQL.lua',
  'server.lua'
}

dependencies {
  'ox_lib',
  'qbx_core'
}


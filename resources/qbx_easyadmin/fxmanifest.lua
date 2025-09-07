fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'QBX EasyAdmin Integration'
author 'you'
description 'EasyAdmin <-> QBX admin utilities with ox_lib UI and Discord audits'
version '1.0.0'

dependency 'ox_lib'
dependency 'qbx_core'

shared_scripts {
  '@ox_lib/init.lua',
}

client_scripts {
  'client.lua',
}

server_scripts {
  'server.lua',
}



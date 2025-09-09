fx_version 'cerulean'
game 'gta5'

name 'authority_security'
author 'The Authority Team'
description 'Server-authoritative security helpers (price registry, validation utils)'
version '0.1.0'

lua54 'yes'

server_scripts {
  'price_registry.lua',
  'server/tokens.lua',
  'server/wallet.lua',
  'server/inventory.lua',
  'server/prices_export.lua',
}



fx_version 'cerulean'
game 'gta5'

name 'apartments'
description 'Simple apartment system for The Authority'
author 'The Authority Development Team'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client/apartments.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/apartments.lua'
}

dependencies {
    'ox_lib',
    'oxmysql',
    'qbx_core',
    'ox_inventory'
}


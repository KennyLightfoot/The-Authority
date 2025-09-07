fx_version 'cerulean'
game 'gta5'

name 'qb-delivery'
description 'Simple delivery job placeholder for The Authority'
author 'The Authority Development Team'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}

dependencies {
    'ox_lib',
    'qbx_core'
}






fx_version 'cerulean'
game 'gta5'

name 'core'
description 'Core helper functions for The Authority'
author 'The Authority Development Team'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua'
}

server_scripts {
    'server/payment_and_keys.lua'
}

dependencies {
    'ox_lib',
    'Renewed-Banking',
    'qbx_vehiclekeys',
    'qbx_core'
}


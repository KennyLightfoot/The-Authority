fx_version 'cerulean'
game 'gta5'

name 'QBX Admin Integration'
description 'QBX framework integration for EasyAdmin'
version '1.0.0'
author 'The Authority Server'

server_scripts {
    'server/main.lua'
}

client_scripts {
    'client/main.lua'
}

dependencies {
    'qbx_core',
    'ox_lib',
    'EasyAdmin'
}

-- Ensure this loads after EasyAdmin
load_after 'EasyAdmin'

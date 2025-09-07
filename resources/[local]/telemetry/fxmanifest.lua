fx_version 'cerulean'
game 'gta5'

lua54 'yes'

name 'authority_telemetry'
description 'Telemetry and audit logging for The Authority'
version '0.1.0'

server_only 'yes'

dependencies {
    'oxmysql'
}

server_scripts {
    'server.lua'
}



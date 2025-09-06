fx_version 'cerulean'
game 'gta5'

name 'discord_perms'
description 'Discord role to ACE permissions mapping for The Authority'
author 'The Authority Development Team'
version '1.0.0'

shared_scripts {
    'config.lua'
}

server_scripts {
    'server/discord_perms.lua'
}

dependencies {
    'Badger_Discord_API'
}




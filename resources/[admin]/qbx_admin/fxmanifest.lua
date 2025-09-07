fx_version 'cerulean'
game 'gta5'

name 'qbx_admin'
author 'Your Team'
description 'Neutral, txAdmin-first admin actions for QBX + optional EasyAdmin bridges'
version '1.0.0'

lua54 'yes'

dependencies {
    'qbx_core',
    'ox_lib'
}

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
}

client_scripts {
    'client.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua',
}

fx_version 'cerulean'
game 'gta5'

lua54 'yes'

shared_scripts {
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
	'qbx_core',
	'ox_lib'
}



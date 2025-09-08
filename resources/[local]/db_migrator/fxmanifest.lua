fx_version 'cerulean'
game 'gta5'

name 'db_migrator'
description 'Database migration system for The Authority'
author 'The Authority Development Team'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/migrator.lua'
}

files {
    'migrations/*.sql',
}

dependencies {
    'oxmysql',
    'ox_lib'
}


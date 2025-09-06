fx_version 'cerulean'
game 'gta5'

name 'qa_tools'
description 'QA and testing tools for The Authority'
author 'The Authority Development Team'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua'
}

client_scripts {
    'client/qa_client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/qa_server.lua'
}

dependencies {
    'ox_lib',
    'oxmysql',
    'core'
}


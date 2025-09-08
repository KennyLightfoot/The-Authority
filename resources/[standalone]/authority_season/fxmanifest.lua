fx_version 'cerulean'
game 'gta5'

lua54 'yes'

shared_scripts {
  '@ox_lib/init.lua',
  'shared/config.lua'
}

client_scripts {
  'client/season_ui.lua'
}

server_scripts {
  '@oxmysql/lib/MySQL.lua',
  'server/resistance_pass.lua',
  'server/season_events.lua'
}

dependencies { 'ox_lib' }

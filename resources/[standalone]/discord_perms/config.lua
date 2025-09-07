Config = {}

-- Discord Bot Configuration
Config.DiscordToken = GetConvar('discord_token', 'changeme')
Config.GuildId = GetConvar('discord_guild_id', '000000000000')

-- Role to ACE Group Mappings
Config.RoleMapping = {
    -- Discord Role ID -> ACE Group Name
    ['1413879523799203850'] = 'owner',      -- Owner role
    ['1413516441856114688'] = 'admin',      -- Admin role  
    ['1413879908278734898'] = 'moderator',  -- Moderator role
    ['1413880943357333614'] = 'helper',     -- Helper role
    ['1413880991486971914'] = 'vip',        -- VIP role
    ['1413881018628177930'] = 'donator',    -- Donator role
    ['1413632937353678979'] = 'bot',        -- Authority Bot role
}

-- Default permissions for each group
Config.Permissions = {
    owner = {
        -- Server Management
        'command',
        'command.restart',
        'command.stop', 
        'command.start',
        'command.refresh',
        'command.refreshall',
        
        -- Player Management
        'easyadmin.kick',
        'easyadmin.ban',
        'easyadmin.unban',
        'easyadmin.spectate',
        'easyadmin.teleport',
        'easyadmin.noclip',
        'easyadmin.freeze',
        'easyadmin.godmode',
        'easyadmin.invisible',
        'easyadmin.armor',
        'easyadmin.heal',
        'easyadmin.weapon',
        'easyadmin.vehicle',
        'easyadmin.weather',
        'easyadmin.time',
        
        -- Advanced Admin
        'easyadmin.players',
        'easyadmin.banlist',
        'easyadmin.offlineban',
        'easyadmin.offlineunban',
        'easyadmin.whitelist',
        'easyadmin.blacklist',
        
        -- Economy & Jobs
        'easyadmin.givemoney',
        'easyadmin.giveitem',
        'easyadmin.removeitem',
        'easyadmin.setjob',
        'easyadmin.setgang',
        
        -- Vehicle Management
        'easyadmin.spawnvehicle',
        'easyadmin.deletevehicle',
        'easyadmin.fixvehicle',
        'easyadmin.flipvehicle',
        
        -- Discord Integration
        'discord.permissions',
        'discord.roles',
        
        -- QA Tools
        'qa.base',
        'qa.test',
        'qa.debug'
    },
    admin = {
        -- Player Management
        'easyadmin.kick',
        'easyadmin.ban',
        'easyadmin.unban',
        'easyadmin.spectate',
        'easyadmin.teleport',
        'easyadmin.noclip',
        'easyadmin.freeze',
        'easyadmin.godmode',
        'easyadmin.invisible',
        'easyadmin.armor',
        'easyadmin.heal',
        'easyadmin.weapon',
        
        -- Player Information
        'easyadmin.players',
        'easyadmin.banlist',
        'easyadmin.offlineban',
        'easyadmin.offlineunban',
        
        -- Economy & Jobs
        'easyadmin.givemoney',
        'easyadmin.giveitem',
        'easyadmin.removeitem',
        'easyadmin.setjob',
        'easyadmin.setgang',
        
        -- Vehicle Management
        'easyadmin.spawnvehicle',
        'easyadmin.deletevehicle',
        'easyadmin.fixvehicle',
        'easyadmin.flipvehicle',
        
        -- World Control
        'easyadmin.weather',
        'easyadmin.time',
        
        -- Discord Integration
        'discord.permissions',
        
        -- QA Tools
        'qa.base',
        'qa.test'
    },
    moderator = {
        -- Basic Player Management
        'easyadmin.kick',
        'easyadmin.spectate',
        'easyadmin.teleport',
        'easyadmin.freeze',
        'easyadmin.armor',
        'easyadmin.heal',
        
        -- Player Information
        'easyadmin.players',
        
        -- Basic Economy
        'easyadmin.givemoney',
        'easyadmin.giveitem',
        
        -- Vehicle Help
        'easyadmin.fixvehicle',
        'easyadmin.flipvehicle',
        
        -- QA Tools
        'qa.base'
    },
    helper = {
        -- Support Tools
        'easyadmin.spectate',
        'easyadmin.teleport',
        'easyadmin.armor',
        'easyadmin.heal',
        
        -- Player Information
        'easyadmin.players',
        
        -- Vehicle Help
        'easyadmin.fixvehicle',
        'easyadmin.flipvehicle',
        
        -- Basic QA
        'qa.base'
    },
    vip = {
        -- VIP Commands
        'vip.teleport',
        'vip.vehicle',
        'vip.weapon',
        'vip.armor',
        'vip.heal',
        
        -- Priority Features
        'priority.queue',
        'priority.spawn',
        
        -- Special Items
        'vip.items',
        'vip.clothing'
    },
    donator = {
        -- Donator Perks
        'donator.vehicle',
        'donator.weapon',
        'donator.items',
        'donator.clothing',
        'donator.teleport',
        
        -- Special Features
        'donator.spawn',
        'donator.queue'
    },
    bot = {
        -- Bot specific permissions
        'discord.bot',
        'command.say',
        'command.announce'
    }
}

-- Auto-assign permissions when roles are detected
Config.AutoAssignPermissions = true

-- Debug mode
Config.Debug = false


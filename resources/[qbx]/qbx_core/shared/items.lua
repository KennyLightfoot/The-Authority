---@deprecated This file is deprecated and will be removed in the future. Please add your items directly in ox_inventory/data/items.lua file. Currently items placed in here will be converted at next server restart.
---@type table<string, Item>
return {
    ['weapon_pistol'] = {
        name = 'weapon_pistol',
        label = 'Pistol',
        weight = 1000,
        type = 'weapon',
        ammotype = 'AMMO_PISTOL',
        image = 'weapon_pistol.png',
        unique = true,
        useable = false,
        description = 'Standard issue pistol',
    },
    ['weapon_smg'] = {
        name = 'weapon_smg',
        label = 'SMG',
        weight = 1000,
        type = 'weapon',
        ammotype = 'AMMO_SMG',
        image = 'weapon_smg.png',
        unique = true,
        useable = false,
        description = 'Compact submachine gun',
    }
}

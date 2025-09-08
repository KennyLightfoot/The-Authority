local zones = {}

-- Load all heat zones from database on resource start
CreateThread(function()
    local result = MySQL.query.await('SELECT zone_name, zone_type, geometry, heat_level FROM heat_zones')
    zones = result or {}
    TriggerClientEvent(CLIENT.HEAT_ZONES_INIT, -1, zones)
end)

-- Handle heat updates from clients
RegisterNetEvent(EVENTS.ZONE_HEAT_APPLY, function(zoneName, newHeat)
    if type(zoneName) ~= 'string' or type(newHeat) ~= 'number' then return end

    MySQL.update.await('UPDATE heat_zones SET heat_level = ? WHERE zone_name = ?', {newHeat, zoneName})

    for i, z in ipairs(zones) do
        if z.zone_name == zoneName then
            z.heat_level = newHeat
            break
        end
    end

    TriggerClientEvent(CLIENT.HEAT_UPDATE, -1, zoneName, newHeat)
end)

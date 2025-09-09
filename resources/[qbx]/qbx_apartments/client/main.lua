-- Minimal bridge that proxies qbx_apartments spawn UI to local apartments

RegisterNetEvent('apartments:client:setupSpawnUI', function(citizenId)
    -- Your local apartments uses 'apartments:client:showSelection'
    TriggerEvent('apartments:client:showSelection')
end)

-- When qbx_core falls back to spawnNoApartments, provide a default behavior
RegisterNetEvent('qbx_core:client:spawnNoApartments', function()
    TriggerEvent('apartments:client:showSelection')
end)



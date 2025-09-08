local zones = {}
local activeZone = nil

RegisterNetEvent(CLIENT.HEAT_ZONES_INIT, function(serverZones)
  zones = serverZones or {}
end)

RegisterNetEvent(CLIENT.HEAT_UPDATE, function(zoneName, value)
  if not zoneName then return end
  for i, z in ipairs(zones) do
    if z.zone_name == zoneName then
      z.heat_level = value
      break
    end
  end
  -- Simple screen effect intensity based on current active zone heat
  if activeZone and activeZone.zone_name == zoneName then
    local intensity = math.min(1.0, (value or 0) / 100.0)
    if intensity > 0 then
      StartScreenEffect('DrugsMichaelAliensFight', 2000, false)
    else
      StopAllScreenEffects()
    end
  end
end)

-- Optional: integrate PolyZone for client-side zone detection
CreateThread(function()
  if not PolyZone then return end
  -- This is a placeholder; zones with geometry 'circle' require center+radius in geometry JSON.
  -- For brevity, we skip dynamic building and rely on server init for data cache.
end)




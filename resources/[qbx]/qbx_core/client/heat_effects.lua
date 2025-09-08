local heatZones = {}

RegisterNetEvent(CLIENT.HEAT_UPDATE, function(zone, level)
  heatZones[zone] = level
  lib.notify({ description = ('%s heat is now %d'):format(zone, level), type = 'info' })
end)

-- additional local effects could be added here

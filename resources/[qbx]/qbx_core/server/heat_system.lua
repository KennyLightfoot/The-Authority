local cacheZones = {}

local function loadZones()
  cacheZones = MySQL.query.await('SELECT * FROM heat_zones') or {}
end

local function setZoneHeat(name, val)
  MySQL.update.await('UPDATE heat_zones SET heat_level=? WHERE zone_name=?', { val, name })
  loadZones()
  -- Optionally broadcast to clients
  TriggerClientEvent(CLIENT.HEAT_UPDATE, -1, name, val)
end

AddEventHandler('onResourceStart', function(r)
  if r == GetCurrentResourceName() then loadZones() end
end)

-- periodic effects / decay
CreateThread(function()
  while true do
    -- decay or escalate logic here
    Wait(Config.HeatTickInterval or 60000)
  end
end)

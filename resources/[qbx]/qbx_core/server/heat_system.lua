local zones = {}

local function fetchZones()
  local result = MySQL.query.await('SELECT zone_name, zone_type, geometry, heat_level FROM heat_zones')
  zones = {}
  if result then
    for _, row in ipairs(result) do
      if type(row.geometry) == 'string' then
        row.geometry = json.decode(row.geometry) or {}
      end
      zones[#zones+1] = row
    end
  end
end

local function sendZones(src)
  TriggerClientEvent(CLIENT.HEAT_ZONES_INIT, src, zones)
end

CreateThread(fetchZones)

AddEventHandler('playerJoining', function()
  sendZones(source)
end)

RegisterNetEvent(EVENTS.ZONE_HEAT_APPLY, function(zoneName, value)
  if not zoneName or value == nil then return end
  MySQL.prepare.await('UPDATE heat_zones SET heat_level = ? WHERE zone_name = ?', {value, zoneName})
  for _, z in ipairs(zones) do
    if z.zone_name == zoneName then
      z.heat_level = value
      break
    end
  end
  TriggerClientEvent(CLIENT.HEAT_UPDATE, -1, zoneName, value)
end)

RegisterCommand('heatzones_reload', function(source)
  if source ~= 0 then return end
  fetchZones()
  for _, playerId in ipairs(GetPlayers()) do
    sendZones(tonumber(playerId))
  end
  print('heat zones reloaded')
end, true)

RegisterCommand('heatzone_add', function(source, args, raw)
  if source ~= 0 then return end
  local name = args[1]
  local zoneType = args[2] or 'circle'
  local geomJson = table.concat(args, ' ', 3)
  if not name or geomJson == '' then
    print('Usage: heatzone_add <name> <circle|poly> <geometry_json>')
    return
  end
  local ok, geom = pcall(json.decode, geomJson)
  if not ok then
    print('Invalid geometry JSON')
    return
  end
  MySQL.prepare.await('INSERT INTO heat_zones (zone_name, zone_type, geometry) VALUES (?, ?, ?)', {name, zoneType, json.encode(geom)})
  fetchZones()
  print(('heat zone %s added'):format(name))
end, true)

local zones = {}
local activeZone
local zoneObjects = {}

local function clearZones()
  for _, z in pairs(zoneObjects) do
    z:destroy()
  end
  zoneObjects = {}
end

local function buildZones(serverZones)
  zones = serverZones or {}
  clearZones()
  if not PolyZone then return end

  for _, z in ipairs(zones) do
    local geom = z.geometry
    if type(geom) == 'string' then
      geom = json.decode(geom)
    end

    local zone
    if z.zone_type == 'circle' and geom then
      local center = geom.center or geom.coords or geom
      if center and geom.radius then
        zone = CircleZone:Create(vec3(center.x, center.y, center.z or 0.0), geom.radius, { name = z.zone_name })
      end
    elseif z.zone_type == 'poly' and geom then
      local pts = {}
      for _, p in ipairs(geom.points or geom) do
        pts[#pts + 1] = vector2(p.x or p[1], p.y or p[2])
      end
      zone = PolyZone:Create(pts, { name = z.zone_name })
    end

    if zone then
      zone:onPlayerInOut(function(isInside)
        if isInside then
          activeZone = z
          if z.heat_level and z.heat_level > 0 then
            local intensity = math.min(1.0, z.heat_level / 100.0)
            StartScreenEffect('DrugsMichaelAliensFight', 0, true)
            SetTimecycleModifierStrength(intensity)
          end
        else
          if activeZone and activeZone.zone_name == z.zone_name then
            activeZone = nil
            StopAllScreenEffects()
            ClearTimecycleModifier()
            SetTimecycleModifierStrength(0.0)
          end
        end
      end)

      zoneObjects[#zoneObjects + 1] = zone
    end
  end
end

RegisterNetEvent(CLIENT.HEAT_ZONES_INIT, function(serverZones)
  buildZones(serverZones)
end)

RegisterNetEvent(CLIENT.HEAT_UPDATE, function(zoneName, value)
  if not zoneName then return end
  for _, z in ipairs(zones) do
    if z.zone_name == zoneName then
      z.heat_level = value
      break
    end
  end

  if activeZone and activeZone.zone_name == zoneName then
    local intensity = math.min(1.0, (value or 0) / 100.0)
    if intensity > 0 then
      StartScreenEffect('DrugsMichaelAliensFight', 0, true)
      SetTimecycleModifierStrength(intensity)
    else
      StopAllScreenEffects()
      ClearTimecycleModifier()
      SetTimecycleModifierStrength(0.0)
    end
  end
end)




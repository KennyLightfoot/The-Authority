local qbx = exports.qbx_core

local rentalModels = {
  { name = 'Blista', model = 'blista', price = 0 },
  { name = 'Panto', model = 'panto', price = 0 },
  { name = 'Faggio', model = 'faggio', price = 0 },
}

RegisterCommand('rent', function(source, args)
  local src = source
  local Player = qbx:GetPlayer(src)
  if not Player then return end

  local choice = tostring(args[1] or ''):lower()
  local selected = rentalModels[1]
  for _, v in ipairs(rentalModels) do
    if v.model == choice then selected = v break end
  end

  local ped = GetPlayerPed(src)
  local coords = GetEntityCoords(ped)
  local heading = GetEntityHeading(ped)

  local netId, veh = qbx.spawnVehicle({ spawnSource = vec4(coords.x, coords.y, coords.z, heading), model = selected.model, warp = ped })
  if not veh then
    return qbx:Notify(src, 'Could not spawn vehicle here', 'error')
  end

  if GetResourceState('qbx_vehiclekeys') == 'started' then
    TriggerEvent('qb-vehiclekeys:server:setVehLockState', netId, 1)
  end

  qbx:Notify(src, ('Enjoy your rental (%s). Drive safe!'):format(selected.name), 'success')
end, false)



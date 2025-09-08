local has = function(perm)
  return lib.checkPermission and lib.checkPermission(perm)
end

local function inputNumber(title, min, max)
  local r = lib.inputDialog(title, {
    { type = 'number', label = title, min = min, max = max, required = true }
  })
  if r and r[1] then return tonumber(r[1]) end
end

local function inputText(title, max)
  local r = lib.inputDialog(title, {
    { type = 'input', label = title, required = true, max = max }
  })
  if r and r[1] then return r[1] end
end

local function inputReason()
  return inputText('Reason', 60)
end

-- teleport helper
RegisterNetEvent('QBXAdmin:TpCoords', function(coords)
  if type(coords) == 'vector3' then
    SetEntityCoords(cache.ped, coords.x, coords.y, coords.z, false, false, false, false)
  end
end)

-- freeze helper
RegisterNetEvent('QBXAdmin:Freeze', function(state)
  FreezeEntityPosition(cache.ped, state)
end)

RegisterNetEvent('QBXAdmin:Heal', function()
  SetEntityHealth(cache.ped, 200)
end)

RegisterNetEvent('QBXAdmin:Armor', function()
  SetPedArmour(cache.ped, 100)
end)

RegisterNetEvent('QBXAdmin:Revive', function()
  local ped = cache.ped
  ResurrectPed(ped)
  ClearPedTasksImmediately(ped)
  SetEntityHealth(ped, 200)
end)

-- spectate
local spectating = false
RegisterNetEvent('QBXAdmin:Spectate', function(target)
  if spectating then
    NetworkSetInSpectatorMode(false, 0)
    spectating = false
  else
    local ply = GetPlayerFromServerId(target)
    local ped = GetPlayerPed(ply)
    if ped ~= 0 then
      NetworkSetInSpectatorMode(true, ped)
      spectating = true
    end
  end
end)

-- noclip
local noclip = false
CreateThread(function()
  while true do
    if noclip then
      local ped = cache.ped
      local pos = GetEntityCoords(ped)
      local camRot = GetGameplayCamRot(2)
      local dir = vec3(-math.sin(math.rad(camRot.z)) * math.cos(math.rad(camRot.x)), math.cos(math.rad(camRot.z)) * math.cos(math.rad(camRot.x)), math.sin(math.rad(camRot.x)))
      if IsControlPressed(0, 32) then pos = pos + dir end
      if IsControlPressed(0, 33) then pos = pos - dir end
      SetEntityCoordsNoOffset(ped, pos.x, pos.y, pos.z, true, true, true)
      Wait(0)
    else
      Wait(500)
    end
  end
end)

RegisterNetEvent('QBXAdmin:NoclipToggle', function()
  noclip = not noclip
  local ped = cache.ped
  SetEntityInvincible(ped, noclip)
  SetEntityVisible(ped, not noclip, false)
end)

RegisterNetEvent('QBXAdmin:VehRepair', function()
  local veh = GetVehiclePedIsIn(cache.ped, false)
  if veh ~= 0 then SetVehicleFixed(veh) end
end)

RegisterNetEvent('QBXAdmin:VehClean', function()
  local veh = GetVehiclePedIsIn(cache.ped, false)
  if veh ~= 0 then SetVehicleDirtLevel(veh, 0.0) end
end)

RegisterNetEvent('QBXAdmin:VehFlip', function()
  local veh = GetVehiclePedIsIn(cache.ped, false)
  if veh ~= 0 then SetVehicleOnGroundProperly(veh) end
end)

RegisterNetEvent('QBXAdmin:VehDeleteNearest', function(radius)
  radius = radius or 5.0
  local ped = cache.ped
  local pos = GetEntityCoords(ped)
  local veh = GetClosestVehicle(pos.x, pos.y, pos.z, radius, 0, 70)
  if veh ~= 0 then DeleteEntity(veh) end
end)

RegisterNetEvent('QBXAdmin:ShowIDs', function(ids)
  if not ids then return end
  local text = table.concat(ids, '\n')
  if lib.setClipboard then lib.setClipboard(text) end
  if lib.notify then lib.notify({ title = 'IDs copied', description = text }) end
end)

RegisterNetEvent('QBXAdmin:Announce', function(msg)
  if lib.notify then lib.notify({ title = 'Announcement', description = msg }) end
end)

-- ===== Menus =====
local function openEconomyMenu(target)
  local opts = {}
  if has('qbxadmin.givecash') then
    opts[#opts+1] = { title = 'Give Cash', onSelect = function()
      local amount = inputNumber('Amount', 1, Config.Caps.CashMax)
      if not amount then return end
      local reason = inputReason(); if not reason then return end
      TriggerServerEvent('QBXAdmin:GiveCash', target, amount, reason)
    end }
  end
  if has('qbxadmin.takecash') then
    opts[#opts+1] = { title = 'Take Cash', onSelect = function()
      local amount = inputNumber('Amount', 1, Config.Caps.CashMax)
      if not amount then return end
      local reason = inputReason(); if not reason then return end
      TriggerServerEvent('QBXAdmin:TakeCash', target, amount, reason)
    end }
  end
  if has('qbxadmin.giveitem') then
    opts[#opts+1] = { title = 'Give Item', onSelect = function()
      local items = {}
      for _,v in ipairs(Config.Whitelists.Items) do
        items[#items+1] = { label = v, value = v }
      end
      local r = lib.inputDialog('Give Item', {
        { type='select', label='Item', options=items, required=true },
        { type='number', label='Count', min=1, max=Config.Caps.ItemMax, required=true },
        { type='input', label='Reason', required=true }
      })
      if r and r[1] and r[2] and r[3] then
        TriggerServerEvent('QBXAdmin:GiveItem', target, r[1], tonumber(r[2]), r[3])
      end
    end }
  end
  lib.registerContext({ id = 'admin_economy', title = 'Economy', options = opts })
  lib.showContext('admin_economy')
end

local function openPlayerActions(id)
  local opts = {}
  if has('qbxadmin.tp') then
    opts[#opts+1] = { title = 'Teleport to', onSelect = function() TriggerServerEvent('QBXAdmin:TpTo', id) end }
    opts[#opts+1] = { title = 'Bring', onSelect = function() TriggerServerEvent('QBXAdmin:Bring', id) end }
    opts[#opts+1] = { title = 'Return', onSelect = function() TriggerServerEvent('QBXAdmin:Return', id) end }
  end
  if has('qbxadmin.spectate') then
    opts[#opts+1] = { title = 'Spectate', onSelect = function() TriggerServerEvent('QBXAdmin:SpectateToggle', id) end }
  end
  if has('qbxadmin.freeze') then
    opts[#opts+1] = { title = 'Freeze', onSelect = function() TriggerServerEvent('QBXAdmin:FreezeToggle', id) end }
  end
  if has('qbxadmin.medical') then
    opts[#opts+1] = { title = 'Heal', onSelect = function() TriggerServerEvent('QBXAdmin:Heal', id) end }
    opts[#opts+1] = { title = 'Armor', onSelect = function() TriggerServerEvent('QBXAdmin:Armor', id) end }
    opts[#opts+1] = { title = 'Revive', onSelect = function() TriggerServerEvent('QBXAdmin:Revive', id) end }
  end
  if has('qbxadmin.moderation') then
    opts[#opts+1] = { title = 'Warn', onSelect = function()
      local reasons = {
        { title = 'Spam', onSelect = function() TriggerServerEvent('QBXAdmin:Warn', id, 'Spam') end },
        { title = 'RDM', onSelect = function() TriggerServerEvent('QBXAdmin:Warn', id, 'RDM') end },
        { title = 'VDM', onSelect = function() TriggerServerEvent('QBXAdmin:Warn', id, 'VDM') end },
      }
      lib.registerContext({ id='admin_warn', title='Warn', options=reasons })
      lib.showContext('admin_warn')
    end }
    opts[#opts+1] = { title = 'Kick', onSelect = function()
      local reason = inputReason(); if not reason then return end
      TriggerServerEvent('QBXAdmin:Kick', id, reason)
    end }
  end
  if has('qbxadmin.givecash') or has('qbxadmin.takecash') or has('qbxadmin.giveitem') then
    opts[#opts+1] = { title = 'Economy', onSelect = function() openEconomyMenu(id) end }
  end
  lib.registerContext({ id = 'admin_player_'..id, title = ('Player %s'):format(id), options = opts })
  lib.showContext('admin_player_'..id)
end

local function openPlayersMenu()
  local opts = {}
  for _,pid in ipairs(GetActivePlayers()) do
    local sid = GetPlayerServerId(pid)
    local name = GetPlayerName(pid)
    opts[#opts+1] = { title = ("%s (%s)"):format(name, sid), onSelect = function() openPlayerActions(sid) end }
  end
  opts[#opts+1] = { title = 'Search by ID', onSelect = function()
    local id = inputNumber('Server ID', 1, 1024)
    if id then openPlayerActions(id) end
  end }
  lib.registerContext({ id = 'admin_players', title = 'Players', options = opts })
  lib.showContext('admin_players')
end

local function openVehicleMenu()
  local opts = {}
  if has('qbxadmin.vehicle_basic') then
    opts[#opts+1] = { title = 'Repair Vehicle', onSelect = function() TriggerServerEvent('QBXAdmin:VehRepair') end }
    opts[#opts+1] = { title = 'Clean Vehicle', onSelect = function() TriggerServerEvent('QBXAdmin:VehClean') end }
    opts[#opts+1] = { title = 'Flip Vehicle', onSelect = function() TriggerServerEvent('QBXAdmin:VehFlip') end }
  end
  if has('qbxadmin.vehicle_delete') then
    opts[#opts+1] = { title = 'Delete Nearest', onSelect = function()
      TriggerServerEvent('QBXAdmin:VehDeleteNearest', 5.0)
    end }
  end
  lib.registerContext({ id = 'admin_vehicle', title = 'Vehicles', options = opts })
  lib.showContext('admin_vehicle')
end

local function openUtilitiesMenu()
  local opts = {}
  if has('qbxadmin.noclip') then
    opts[#opts+1] = { title = 'Toggle NoClip', onSelect = function() TriggerServerEvent('QBXAdmin:NoclipToggle') end }
  end
  if has('qbxadmin.ids') then
    opts[#opts+1] = { title = 'Show IDs', onSelect = function() TriggerServerEvent('QBXAdmin:ShowIDs') end }
  end
  if has('qbxadmin.announce') then
    opts[#opts+1] = { title = 'Announce', onSelect = function()
      local msg = inputText('Message', 180); if not msg then return end
      TriggerServerEvent('QBXAdmin:Announce', msg)
    end }
  end
  lib.registerContext({ id = 'admin_utils', title = 'Utilities', options = opts })
  lib.showContext('admin_utils')
end

local function openAdminMenu()
  local opts = {}
  opts[#opts+1] = { title = 'Players', onSelect = openPlayersMenu }
  opts[#opts+1] = { title = 'Vehicles', onSelect = openVehicleMenu }
  opts[#opts+1] = { title = 'Utilities', onSelect = openUtilitiesMenu }
  lib.registerContext({ id = 'admin_root', title = 'Admin Menu', options = opts })
  lib.showContext('admin_root')
end

RegisterKeyMapping('adminmenu', 'Open Admin Menu', 'keyboard', 'F10')
RegisterCommand('adminmenu', openAdminMenu, false)

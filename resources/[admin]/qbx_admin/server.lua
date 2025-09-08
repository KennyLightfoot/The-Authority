local QBCore = exports['qbx-core']:GetCoreObject()

local cooldowns = {}
local lastCoords = {}
local frozen = {}
local itemWhitelist = {}
for _,v in ipairs(Config.Whitelists.Items) do itemWhitelist[v] = true end

local function allowed(src, ace)
  return IsPlayerAceAllowed(src, ace)
end

local function log(msg)
  local text = ('[ADMIN] %s'):format(msg)
  print(text)
  local url = Config.Webhooks.admin
  if url ~= '' then
    PerformHttpRequest(url, function() end, 'POST', json.encode({content = text}), {['Content-Type'] = 'application/json'})
  end
end

local function cdkey(action, src, target)
  return ('%s:%s:%s'):format(action, src, target)
end

local function checkCooldown(key)
  local now = os.time()
  if cooldowns[key] and cooldowns[key] > now then return false end
  cooldowns[key] = now + (Config.Cooldowns.Economy or 30)
  return true
end

-- Economy actions
RegisterNetEvent('QBXAdmin:GiveCash', function(targetId, amount, reason)
  local src = source
  if not allowed(src, 'qbxadmin.givecash') then return end
  if type(targetId) ~= 'number' or type(amount) ~= 'number' or type(reason) ~= 'string' or reason == '' then return end
  if amount < 0 or amount > Config.Caps.CashMax then return end
  local key = cdkey('givecash', src, targetId)
  if not checkCooldown(key) then return end
  local tgt = QBCore.Functions.GetPlayer(targetId)
  if not tgt then return end
  tgt.Functions.AddMoney('cash', amount, 'admin:'..reason)
  log(('GiveCash %s -> %s (%s)'):format(src, targetId, reason))
end)

RegisterNetEvent('QBXAdmin:TakeCash', function(targetId, amount, reason)
  local src = source
  if not allowed(src, 'qbxadmin.takecash') then return end
  if type(targetId) ~= 'number' or type(amount) ~= 'number' or type(reason) ~= 'string' or reason == '' then return end
  if amount < 0 or amount > Config.Caps.CashMax then return end
  local key = cdkey('takecash', src, targetId)
  if not checkCooldown(key) then return end
  local tgt = QBCore.Functions.GetPlayer(targetId)
  if not tgt then return end
  tgt.Functions.RemoveMoney('cash', amount, 'admin:'..reason)
  log(('TakeCash %s -> %s (%s)'):format(src, targetId, reason))
end)

RegisterNetEvent('QBXAdmin:GiveItem', function(targetId, item, count, reason)
  local src = source
  if not allowed(src, 'qbxadmin.giveitem') then return end
  if type(targetId) ~= 'number' or type(item) ~= 'string' or type(count) ~= 'number' or type(reason) ~= 'string' or reason == '' then return end
  if count < 1 or count > Config.Caps.ItemMax or not itemWhitelist[item] then return end
  local key = cdkey('giveitem', src, targetId)
  if not checkCooldown(key) then return end
  local tgt = QBCore.Functions.GetPlayer(targetId)
  if not tgt then return end
  tgt.Functions.AddItem(item, count)
  log(('GiveItem %s x%s -> %s (%s)'):format(item, count, targetId, reason))
end)

-- Player movement
RegisterNetEvent('QBXAdmin:TpTo', function(targetId)
  local src = source
  if not allowed(src, 'qbxadmin.tp') then return end
  if type(targetId) ~= 'number' then return end
  local ped = GetPlayerPed(targetId)
  if not ped or ped == 0 then return end
  local coords = GetEntityCoords(ped)
  TriggerClientEvent('QBXAdmin:TpCoords', src, coords)
  log(('TpTo %s -> %s'):format(src, targetId))
end)

RegisterNetEvent('QBXAdmin:Bring', function(targetId)
  local src = source
  if not allowed(src, 'qbxadmin.tp') then return end
  if type(targetId) ~= 'number' then return end
  local tped = GetPlayerPed(targetId)
  if not tped or tped == 0 then return end
  lastCoords[targetId] = GetEntityCoords(tped)
  local sped = GetPlayerPed(src)
  local scoords = GetEntityCoords(sped)
  TriggerClientEvent('QBXAdmin:TpCoords', targetId, scoords)
  log(('Bring %s by %s'):format(targetId, src))
end)

RegisterNetEvent('QBXAdmin:Return', function(targetId)
  local src = source
  if not allowed(src, 'qbxadmin.tp') then return end
  if type(targetId) ~= 'number' then return end
  local coords = lastCoords[targetId]
  if not coords then return end
  TriggerClientEvent('QBXAdmin:TpCoords', targetId, coords)
  lastCoords[targetId] = nil
  log(('Return %s by %s'):format(targetId, src))
end)

AddEventHandler('playerDropped', function()
  local src = source
  frozen[src] = nil
  lastCoords[src] = nil
end)

-- Spectate
RegisterNetEvent('QBXAdmin:SpectateToggle', function(targetId)
  local src = source
  if not allowed(src, 'qbxadmin.spectate') then return end
  if type(targetId) ~= 'number' then return end
  TriggerClientEvent('QBXAdmin:Spectate', src, targetId)
  log(('Spectate %s -> %s'):format(src, targetId))
end)

-- Freeze
local function unfreeze(targetId)
  if frozen[targetId] then
    frozen[targetId] = nil
    TriggerClientEvent('QBXAdmin:Freeze', targetId, false)
    log(('Unfreeze %s (auto)'):format(targetId))
  end
end

RegisterNetEvent('QBXAdmin:FreezeToggle', function(targetId)
  local src = source
  if not allowed(src, 'qbxadmin.freeze') then return end
  if type(targetId) ~= 'number' then return end
  if frozen[targetId] then
    frozen[targetId] = nil
    TriggerClientEvent('QBXAdmin:Freeze', targetId, false)
    log(('Unfreeze %s by %s'):format(targetId, src))
  else
    frozen[targetId] = true
    TriggerClientEvent('QBXAdmin:Freeze', targetId, true)
    log(('Freeze %s by %s'):format(targetId, src))
    SetTimeout(120000, function() unfreeze(targetId) end)
  end
end)

-- Medical
RegisterNetEvent('QBXAdmin:Heal', function(targetId)
  local src = source
  if not allowed(src, 'qbxadmin.medical') then return end
  if type(targetId) ~= 'number' then return end
  TriggerClientEvent('QBXAdmin:Heal', targetId)
  log(('Heal %s by %s'):format(targetId, src))
end)

RegisterNetEvent('QBXAdmin:Armor', function(targetId)
  local src = source
  if not allowed(src, 'qbxadmin.medical') then return end
  if type(targetId) ~= 'number' then return end
  TriggerClientEvent('QBXAdmin:Armor', targetId)
  log(('Armor %s by %s'):format(targetId, src))
end)

RegisterNetEvent('QBXAdmin:Revive', function(targetId)
  local src = source
  if not allowed(src, 'qbxadmin.medical') then return end
  if type(targetId) ~= 'number' then return end
  TriggerClientEvent('QBXAdmin:Revive', targetId)
  log(('Revive %s by %s'):format(targetId, src))
end)

-- Moderation
RegisterNetEvent('QBXAdmin:Warn', function(targetId, reason)
  local src = source
  if not allowed(src, 'qbxadmin.moderation') then return end
  if type(targetId) ~= 'number' or type(reason) ~= 'string' or reason == '' then return end
  log(('Warn %s by %s (%s)'):format(targetId, src, reason))
end)

RegisterNetEvent('QBXAdmin:Kick', function(targetId, reason)
  local src = source
  if not allowed(src, 'qbxadmin.moderation') then return end
  if type(targetId) ~= 'number' or type(reason) ~= 'string' or reason == '' then return end
  DropPlayer(targetId, reason)
  log(('Kick %s by %s (%s)'):format(targetId, src, reason))
end)

-- Vehicles
RegisterNetEvent('QBXAdmin:VehRepair', function()
  local src = source
  if not allowed(src, 'qbxadmin.vehicle_basic') then return end
  TriggerClientEvent('QBXAdmin:VehRepair', src)
  log(('VehRepair %s'):format(src))
end)

RegisterNetEvent('QBXAdmin:VehClean', function()
  local src = source
  if not allowed(src, 'qbxadmin.vehicle_basic') then return end
  TriggerClientEvent('QBXAdmin:VehClean', src)
  log(('VehClean %s'):format(src))
end)

RegisterNetEvent('QBXAdmin:VehFlip', function()
  local src = source
  if not allowed(src, 'qbxadmin.vehicle_basic') then return end
  TriggerClientEvent('QBXAdmin:VehFlip', src)
  log(('VehFlip %s'):format(src))
end)

RegisterNetEvent('QBXAdmin:VehDeleteNearest', function(radius)
  local src = source
  if not allowed(src, 'qbxadmin.vehicle_delete') then return end
  radius = tonumber(radius) or 5.0
  if radius > Config.Caps.ClearRadiusMax then radius = Config.Caps.ClearRadiusMax end
  TriggerClientEvent('QBXAdmin:VehDeleteNearest', src, radius)
  log(('VehDeleteNearest %s (%.1f)'):format(src, radius))
end)

-- Utilities
RegisterNetEvent('QBXAdmin:Announce', function(msg)
  local src = source
  if not allowed(src, 'qbxadmin.announce') then return end
  if type(msg) ~= 'string' or msg == '' then return end
  msg = msg:sub(1, 180)
  TriggerClientEvent('QBXAdmin:Announce', -1, msg)
  log(('Announce by %s: %s'):format(src, msg))
end)

RegisterNetEvent('QBXAdmin:NoclipToggle', function()
  local src = source
  if not allowed(src, 'qbxadmin.noclip') then return end
  TriggerClientEvent('QBXAdmin:NoclipToggle', src)
  log(('Noclip %s'):format(src))
end)

RegisterNetEvent('QBXAdmin:ShowIDs', function(targetId)
  local src = source
  if not allowed(src, 'qbxadmin.ids') then return end
  local ids = {}
  local tgt = targetId and targetId or src
  for _,v in ipairs(GetPlayerIdentifiers(tgt)) do ids[#ids+1] = v end
  TriggerClientEvent('QBXAdmin:ShowIDs', src, ids)
  log(('ShowIDs %s target %s'):format(src, tgt))
end)


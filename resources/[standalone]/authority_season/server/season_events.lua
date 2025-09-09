RegisterNetEvent('authority:server:seasonReward', function(item)
  local src = source
  local player = exports.qbx_core:GetPlayer(src); if not player then return end
  -- validate item against allowed rewards list
  if type(item) ~= 'string' then return end
  local allowed = {
    ['water'] = true,
    ['sandwich'] = true,
    ['lockpick'] = true,
  }
  if not allowed[item] then return end
  exports.ox_inventory:AddItem(src, item, 1)
end)

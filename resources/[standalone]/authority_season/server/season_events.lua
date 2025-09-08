RegisterNetEvent('authority:server:seasonReward', function(item)
  local src = source
  local player = exports.qbx_core:GetPlayer(src); if not player then return end
  if item then
    exports.ox_inventory:AddItem(src, item, 1)
  end
end)

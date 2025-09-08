local function updatePass(citizenid, level, xp)
  MySQL.update.await('UPDATE player_meta SET resistance_pass_level=?, resistance_pass_xp=? WHERE citizenid=?', { level, xp, citizenid })
end

RegisterNetEvent('authority:server:setPass', function(level, xp)
  local src = source
  local player = exports.qbx_core:GetPlayer(src); if not player then return end
  local cid = player.PlayerData.citizenid
  updatePass(cid, level or 0, xp or 0)
  local meta = MySQL.single.await('SELECT * FROM player_meta WHERE citizenid=?', { cid })
  TriggerClientEvent(CLIENT.META_PUSH, src, meta)
end)

RegisterNetEvent(EVENTS.SET_PATH, function(path)
  local src = source
  local cid = exports.qbx_core:GetPlayer(src)?.PlayerData?.citizenid
  if not cid then return end
  path = (path == 'pioneer' or path == 'rebel') and path or 'undecided'
  MySQL.update.await('UPDATE player_meta SET player_path=? WHERE citizenid=?', { path, cid })
  local meta = MySQL.single.await('SELECT * FROM player_meta WHERE citizenid=?', { cid })
  TriggerClientEvent(CLIENT.META_PUSH, src, meta)
end)

RegisterNetEvent(EVENTS.ONBOARDING_DONE, function()
  local src = source
  local cid = exports.qbx_core:GetPlayer(src)?.PlayerData?.citizenid
  if not cid then return end
  MySQL.update.await('UPDATE player_meta SET onboarding_complete=1 WHERE citizenid=?', { cid })
  -- Grant small reward or standing bump:
  MySQL.update.await('UPDATE player_meta SET authority_standing=LEAST(100, authority_standing+5) WHERE citizenid=?', { cid })
  local meta = MySQL.single.await('SELECT * FROM player_meta WHERE citizenid=?', { cid })
  TriggerClientEvent(CLIENT.META_PUSH, src, meta)
  TriggerClientEvent('ox_lib:notify', src, { description='Onboarding complete!', type='success' })
end)

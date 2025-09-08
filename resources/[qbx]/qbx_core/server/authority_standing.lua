local clamp = function(v, lo, hi) return math.min(hi, math.max(lo, v)) end

local function getCitizenId(src)
  local player = exports.qbx_core:GetPlayer(src)
  return player and player.PlayerData and player.PlayerData.citizenid or nil
end

local function ensureMeta(citizenid)
  MySQL.prepare.await([[ 
    INSERT IGNORE INTO player_meta (citizenid) VALUES (?)
  ]], { citizenid })
end

local function fetchMeta(citizenid)
  return MySQL.single.await('SELECT * FROM player_meta WHERE citizenid = ?', { citizenid })
end

local function pushClientMeta(src, meta)
  if not src or not meta then return end
  TriggerClientEvent(CLIENT.META_PUSH, src, {
    authority = meta.authority_standing,
    heat = meta.heat_level,
    path = meta.player_path,
    onboarding = meta.onboarding_complete,
    pass_level = meta.resistance_pass_level,
    pass_xp = meta.resistance_pass_xp
  })
  local state = Player(src).state
  state:set('authority', meta.authority_standing, true)
  state:set('heat', meta.heat_level, true)
  state:set('player_path', meta.player_path, true)
end

RegisterNetEvent(EVENTS.REQ_META, function()
  local src = source
  local cid = getCitizenId(src); if not cid then return end
  ensureMeta(cid)
  local meta = fetchMeta(cid)
  pushClientMeta(src, meta)
end)

-- Admin-safe mutation helper
local function addStanding(citizenid, delta, reason)
  local meta = fetchMeta(citizenid); if not meta then return end
  local newVal = clamp((meta.authority_standing or 0) + delta, -100, 100)
  MySQL.transaction.await(function(tx)
    tx.prepare('UPDATE player_meta SET authority_standing=? WHERE citizenid=?', { newVal, citizenid })
    tx.prepare('INSERT INTO authority_events (citizenid, event_type, standing_change, note) VALUES (?,?,?,?)',
               { citizenid, 'delta', delta, reason or '' })
  end)
  return newVal
end

RegisterNetEvent(EVENTS.ADD_STANDING, function(delta, note)
  local src = source
  local cid = getCitizenId(src); if not cid then return end
  -- Server-side validation: clamp per-action, rate-limit if needed
  delta = tonumber(delta) or 0
  delta = clamp(delta, -20, 20)
  local newVal = addStanding(cid, delta, ('player:%d %s'):format(src, note or ''))
  pushClientMeta(src, fetchMeta(cid))
end)

-- Example admin command (via qbx_admin permission check)
lib.addCommand('auth_add', {
  help = 'Add Authority Standing to a player',
  params = {
    { name='id', type='playerId' },
    { name='delta', type='number' },
    { name='note', type='string', optional=true },
  },
  restricted = 'group.admin'
}, function(source, args, raw)
  local target = tonumber(args.id)
  local player = exports.qbx_core:GetPlayer(target); if not player then return end
  local cid = player.PlayerData.citizenid
  local newVal = addStanding(cid, args.delta, args.note or ('admin:%d'):format(source))
  TriggerClientEvent('ox_lib:notify', source, { description = ('New standing: %d'):format(newVal), type = 'success' })
  pushClientMeta(target, fetchMeta(cid))
end)

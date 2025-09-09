-- Server-side character callbacks used by client multichar

local storage = require 'server.storage.players'

---Return preview skin/model for the given citizenId
lib.callback.register('qbx_core:server:getPreviewPedData', function(_source, citizenId)
    if not citizenId then return nil, nil end
    local skin = storage.fetchPlayerSkin(citizenId)
    if not skin then return nil, nil end
    return skin.skin, skin.model
end)

---Return all characters for the connecting license
lib.callback.register('qbx_core:server:getCharacters', function(source)
    local license2 = GetPlayerIdentifierByType(source, 'license2')
    local license = GetPlayerIdentifierByType(source, 'license')
    local chars = storage.fetchAllPlayerEntities(license2, license)
    return chars, #chars
end)

---Create a new character for the connecting player
lib.callback.register('qbx_core:server:createCharacter', function(source, data)
    -- Minimal path: insert into players with defaults
    local license2 = GetPlayerIdentifierByType(source, 'license2')
    local license = GetPlayerIdentifierByType(source, 'license')

    local citizenid = ('%s'):format(lib.string.random('QBX........'))
    local firstname = data.firstname or 'John'
    local lastname = data.lastname or 'Doe'
    local nationality = data.nationality or 'American'
    local gender = data.gender or 0
    local birthdate = data.birthdate or '1990-01-01'
    local cid = tonumber(data.cid) or 1

    local charinfo = {
        firstname = firstname,
        lastname = lastname,
        nationality = nationality,
        gender = gender,
        birthdate = birthdate,
        cid = cid,
        phone = tostring(math.random(100,999)) .. tostring(math.random(1000000,9999999)),
        account = 'US0' .. math.random(1, 9) .. 'QBX' .. math.random(1111, 9999) .. math.random(1111, 9999) .. math.random(11, 99),
    }

    local playerEntity = {
        userId = 0,
        citizenid = citizenid,
        license = license2 or license,
        name = (firstname .. ' ' .. lastname),
        money = { cash = 500, bank = 5000, crypto = 0 },
        charinfo = charinfo,
        job = require 'shared.jobs'.unemployed and { name = 'unemployed', label = 'Civilian', onduty = true, payment = 10, grade = { name = 'Freelancer', level = 0 } } or nil,
        gang = require 'shared.gangs'.none and { name = 'none', label = 'No Gang', grade = { name = 'Unaffiliated', level = 0 } } or nil,
        position = vec4(0.0, 0.0, 72.0, 0.0),
        metadata = { hunger = 100, thirst = 100 },
        lastLoggedOut = os.time(),
    }

    storage.upsertPlayerEntity({ playerEntity = playerEntity, position = playerEntity.position })
    return playerEntity
end)

---Load the specified character for the source (minimal stub)
lib.callback.register('qbx_core:server:loadCharacter', function(source, citizenId)
    -- In a fuller implementation, set QBX.PlayerData and trigger join events
    local entity = storage.fetchPlayerEntity(citizenId)
    if not entity then return false end
    TriggerClientEvent('QBCore:Client:OnPlayerLoaded', source)
    return true
end)

-- Minimal wrappers used by compatibility bridges

local function GetPlayer(source)
    if QBX and QBX.Players and QBX.Players[source] then
        return QBX.Players[source]
    end
    return nil
end

local function GetPlayerByCitizenId(citizenid)
    if not (QBX and QBX.Players) then return nil end
    for _, player in pairs(QBX.Players) do
        if player.PlayerData and player.PlayerData.citizenid == citizenid then
            return player
        end
    end
    return nil
end

exports('GetPlayer', GetPlayer)
exports('GetPlayerByCitizenId', GetPlayerByCitizenId)


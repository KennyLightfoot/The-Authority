local shared = require 'shared.main'

-- Minimal server-side stubs that other resources expect from qbx_core

local function GetPlayersData()
    local sources = GetPlayers()
    local players = {}
    for i = 1, #sources do
        local src = tonumber(sources[i])
        local player = exports.qbx_core:GetPlayer(src)
        if player and player.PlayerData then
            players[#players+1] = player.PlayerData
        end
    end
    return players
end

local function GetJobs()
    return require 'shared.jobs'
end

local function GetGangs()
    return require 'shared.gangs'
end

exports('GetPlayersData', GetPlayersData)
exports('GetJobs', GetJobs)
exports('GetGangs', GetGangs)


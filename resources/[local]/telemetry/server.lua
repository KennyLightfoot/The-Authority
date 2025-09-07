local oxmysql = exports.oxmysql

local TELEMETRY_QUEUE = {}
local AUDIT_QUEUE = {}
local MAX_BATCH = 100
local FLUSH_INTERVAL_MS = 5000

local function flushTelemetry()
    if #TELEMETRY_QUEUE == 0 then return end
    local batch = {}
    for i = 1, math.min(#TELEMETRY_QUEUE, MAX_BATCH) do
        batch[#batch + 1] = TELEMETRY_QUEUE[i]
    end
    for i = 1, #batch do
        table.remove(TELEMETRY_QUEUE, 1)
    end

    oxmysql:insert(
        'INSERT INTO telemetry_events (event_name, player_id, citizenid, payload, created_at) VALUES (?, ?, ?, ?, NOW())',
        batch,
        function() end
    )
end

local function flushAudit()
    if #AUDIT_QUEUE == 0 then return end
    local batch = {}
    for i = 1, math.min(#AUDIT_QUEUE, MAX_BATCH) do
        batch[#batch + 1] = AUDIT_QUEUE[i]
    end
    for i = 1, #batch do
        table.remove(AUDIT_QUEUE, 1)
    end

    oxmysql:insert(
        'INSERT INTO audit_logs (action, actor_id, citizenid, target_id, target_citizenid, details, created_at) VALUES (?, ?, ?, ?, ?, ?, NOW())',
        batch,
        function() end
    )
end

CreateThread(function()
    while true do
        Wait(FLUSH_INTERVAL_MS)
        local ok, err = pcall(function()
            flushTelemetry()
            flushAudit()
        end)
        if not ok then
            print(('^1[telemetry]^7 flush error: %s'):format(err))
        end
    end
end)

local function safeJson(data)
    local ok, encoded = pcall(json.encode, data)
    if ok then return encoded end
    return '{}'
end

exports('telemetry', function(eventName, playerId, citizenid, payload)
    TELEMETRY_QUEUE[#TELEMETRY_QUEUE + 1] = {
        eventName,
        playerId or 0,
        citizenid or '',
        safeJson(payload or {})
    }
end)

exports('audit', function(action, actorId, citizenid, targetId, targetCitizenId, details)
    AUDIT_QUEUE[#AUDIT_QUEUE + 1] = {
        action,
        actorId or 0,
        citizenid or '',
        targetId or 0,
        targetCitizenId or '',
        safeJson(details or {})
    }
end)

RegisterNetEvent('authority:telemetry', function(eventName, payload)
    local src = source
    exports['authority_telemetry']:telemetry(eventName, src, '', payload)
end)

RegisterNetEvent('authority:audit', function(action, targetId, details)
    local src = source
    exports['authority_telemetry']:audit(action, src, '', targetId, '', details)
end)

print('^2[telemetry]^7 Resource loaded: telemetry/audit collectors active')



-- qbx_admin | Client (txAdmin-first; optional EasyAdmin aliasing)
local RATE_MS = Config.RateMs or 750
local lastAction = 0

local function canActNow()
    local now = GetGameTimer()
    if (now - lastAction) < RATE_MS then return false end
    lastAction = now
    return true
end

local function hasLib()
    return GetResourceState('ox_lib') == 'started' and lib ~= nil
end

local function notify(desc, typ)
    typ = typ or 'info'
    if hasLib() and lib.notify then
        lib.notify({ title = 'QBX Admin', description = tostring(desc), type = typ, duration = 5000 })
    else
        BeginTextCommandThefeedPost('STRING')
        AddTextComponentSubstringPlayerName(tostring(desc))
        EndTextCommandThefeedPostTicker(false, false)
    end
end

-- ========= Target selection =========
local function ensureTargetId(id)
    id = tonumber(id)
    if id and id > 0 then return id end
    if not hasLib() or not lib.inputDialog then
        notify('ox_lib required to prompt for a target id.', 'error'); return nil
    end
    local resp = lib.inputDialog('Target Player', { { type='number', label='Server ID', min=1, required=true } })
    if not resp or not resp[1] then return nil end
    local sid = tonumber(resp[1])
    if not sid or sid < 1 then notify('Invalid target id.', 'error'); return nil end
    return sid
end

-- ========= Neutral client -> server triggers =========
local function giveMoney(id)
    if not canActNow() then return notify('Slow down a sec (rate limited).', 'error') end
    id = ensureTargetId(id); if not id then return end
    if not hasLib() or not lib.inputDialog then return notify('ox_lib required for this action.', 'error') end
    local res = lib.inputDialog('Give Money', {
        { type='select', label='Account', options={{label='Cash',value='cash'},{label='Bank',value='bank'}}, required=true },
        { type='number', label='Amount', min=1, max=Config.MaxMoneyAmount or 1000000, required=true },
    })
    if res and res[1] and res[2] then
        TriggerServerEvent('QBXAdmin:GiveMoney', id, res[1], tonumber(res[2]))
    end
end

local function removeMoney(id)
    if not canActNow() then return notify('Slow down a sec (rate limited).', 'error') end
    id = ensureTargetId(id); if not id then return end
    if not hasLib() or not lib.inputDialog then return notify('ox_lib required for this action.', 'error') end
    local res = lib.inputDialog('Remove Money', {
        { type='select', label='Account', options={{label='Cash',value='cash'},{label='Bank',value='bank'}}, required=true },
        { type='number', label='Amount', min=1, max=Config.MaxMoneyAmount or 1000000, required=true },
    })
    if res and res[1] and res[2] then
        TriggerServerEvent('QBXAdmin:RemoveMoney', id, res[1], tonumber(res[2]))
    end
end

local function setMoney(id)
    if not canActNow() then return notify('Slow down a sec (rate limited).', 'error') end
    id = ensureTargetId(id); if not id then return end
    if not hasLib() or not lib.inputDialog then return notify('ox_lib required for this action.', 'error') end
    local res = lib.inputDialog('Set Money', {
        { type='select', label='Account', options={{label='Cash',value='cash'},{label='Bank',value='bank'}}, required=true },
        { type='number', label='Amount', min=1, max=Config.MaxMoneyAmount or 1000000, required=true },
    })
    if res and res[1] and res[2] then
        TriggerServerEvent('QBXAdmin:SetMoney', id, res[1], tonumber(res[2]))
    end
end

local function setJob(id)
    if not canActNow() then return notify('Slow down a sec (rate limited).', 'error') end
    id = ensureTargetId(id); if not id then return end
    if not hasLib() or not lib.inputDialog then return notify('ox_lib required for this action.', 'error') end
    local res = lib.inputDialog('Set Job', { { type='input', label='Job Name', required=true } })
    if res and res[1] then TriggerServerEvent('QBXAdmin:SetJob', id, res[1]) end
end

local function setJobGrade(id)
    if not canActNow() then return notify('Slow down a sec (rate limited).', 'error') end
    id = ensureTargetId(id); if not id then return end
    if not hasLib() or not lib.inputDialog then return notify('ox_lib required for this action.', 'error') end
    local res = lib.inputDialog('Set Job Grade', { { type='number', label='Grade', min=0, max=Config.MaxJobGrade or 10, required=true } })
    if res and res[1] then TriggerServerEvent('QBXAdmin:SetJobGrade', id, tonumber(res[1])) end
end

local function toggleDuty(id)
    if not canActNow() then return notify('Slow down a sec (rate limited).', 'error') end
    id = ensureTargetId(id); if not id then return end
    TriggerServerEvent('QBXAdmin:ToggleDuty', id)
end

local function setGang(id)
    if not canActNow() then return notify('Slow down a sec (rate limited).', 'error') end
    id = ensureTargetId(id); if not id then return end
    if not hasLib() or not lib.inputDialog then return notify('ox_lib required for this action.', 'error') end
    local res = lib.inputDialog('Set Gang', { { type='input', label='Gang Name', required=true } })
    if res and res[1] then TriggerServerEvent('QBXAdmin:SetGang', id, res[1]) end
end

local function setGangGrade(id)
    if not canActNow() then return notify('Slow down a sec (rate limited).', 'error') end
    id = ensureTargetId(id); if not id then return end
    if not hasLib() or not lib.inputDialog then return notify('ox_lib required for this action.', 'error') end
    local res = lib.inputDialog('Set Gang Grade', { { type='number', label='Grade', min=0, max=Config.MaxGangGrade or 10, required=true } })
    if res and res[1] then TriggerServerEvent('QBXAdmin:SetGangGrade', id, tonumber(res[1])) end
end

local function getInfo(id)
    if not canActNow() then return notify('Slow down a sec (rate limited).', 'error') end
    id = ensureTargetId(id); if not id then return end
    TriggerServerEvent('QBXAdmin:GetPlayerInfo', id)
end

local function heal(id)
    if not canActNow() then return notify('Slow down a sec (rate limited).', 'error') end
    id = ensureTargetId(id); if not id then return end
    TriggerServerEvent('QBXAdmin:Heal', id)
end

local function revive(id)
    if not canActNow() then return notify('Slow down a sec (rate limited).', 'error') end
    id = ensureTargetId(id); if not id then return end
    TriggerServerEvent('QBXAdmin:Revive', id)
end

-- ========= Info + effects =========
RegisterNetEvent('QBXAdmin:ReceivePlayerInfo', function(info)
    if hasLib() and lib.alertDialog then
        lib.alertDialog({
            header = ('Player Info — %s'):format(info.name),
            content = ('CitizenID: %s\nJob: %s (Grade %d, %s)\nGang: %s (Grade %d)\nMoney: $%d cash, $%d bank')
                :format(
                    tostring(info.citizenid),
                    tostring(info.job), tonumber(info.jobGrade or 0), info.jobDuty and 'On Duty' or 'Off Duty',
                    tostring(info.gang), tonumber(info.gangGrade or 0),
                    tonumber(info.money.cash or 0), tonumber(info.money.bank or 0)
                ),
            centered = true, cancel = false
        })
    else
        notify(('Player %s | CID %s | Job %s/%d (%s) | Gang %s/%d | Cash $%d | Bank $%d')
            :format(
                tostring(info.name), tostring(info.citizenid),
                tostring(info.job), tonumber(info.jobGrade or 0), info.jobDuty and 'On' or 'Off',
                tostring(info.gang), tonumber(info.gangGrade or 0),
                tonumber(info.money.cash or 0), tonumber(info.money.bank or 0)
            ), 'info')
    end
end)

RegisterNetEvent('QBXAdmin:Client:Heal', function()
    local ped = PlayerPedId()
    SetEntityHealth(ped, GetEntityMaxHealth(ped))
    ClearPedBloodDamage(ped)
    ResetPedVisibleDamage(ped)
    ClearPedWetness(ped)
    SetPedArmour(ped, 100)
    notify('You have been healed.', 'success')
end)

RegisterNetEvent('QBXAdmin:Client:Revive', function()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, heading, true, false)
    ClearPedBloodDamage(ped)
    SetEntityHealth(ped, GetEntityMaxHealth(ped))
    SetPedArmour(ped, 0)
    ClearPedTasksImmediately(ped)
    notify('You have been revived.', 'success')
end)

-- ========= Commands (client) =========
local function registerClientCommand(cmd, fn)
    RegisterCommand(cmd, function(_, args) fn(args[1]) end, true)
end

registerClientCommand('qbxadmin_givemoney',   giveMoney)
registerClientCommand('qbxadmin_removemoney', removeMoney)
registerClientCommand('qbxadmin_setmoney',    setMoney)
registerClientCommand('qbxadmin_setjob',      setJob)
registerClientCommand('qbxadmin_setjobgrade', setJobGrade)
registerClientCommand('qbxadmin_toggleduty',  toggleDuty)
registerClientCommand('qbxadmin_setgang',     setGang)
registerClientCommand('qbxadmin_setganggrade',setGangGrade)
registerClientCommand('qbxadmin_info',        getInfo)
registerClientCommand('qbxadmin_heal',        heal)
registerClientCommand('qbxadmin_revive',      revive)

-- Optional legacy EasyAdmin aliases (toggle in config)
if Config.UseEasyAdmin then
    local alias = {
        qbxadmin_givemoney   = 'easyadmin_qbx_givemoney',
        qbxadmin_removemoney = 'easyadmin_qbx_removemoney',
        qbxadmin_setmoney    = 'easyadmin_qbx_setmoney',
        qbxadmin_setjob      = 'easyadmin_qbx_setjob',
        qbxadmin_setjobgrade = 'easyadmin_qbx_setjobgrade',
        qbxadmin_toggleduty  = 'easyadmin_qbx_toggleduty',
        qbxadmin_setgang     = 'easyadmin_qbx_setgang',
        qbxadmin_setganggrade= 'easyadmin_qbx_setganggrade',
        qbxadmin_info        = 'easyadmin_qbx_playerinfo',
        qbxadmin_heal        = 'easyadmin_qbx_heal',
        qbxadmin_revive      = 'easyadmin_qbx_revive',
    }
    for new, old in pairs(alias) do
        RegisterCommand(old, function(_, args) ExecuteCommand(('%s %s'):format(new, args[1] or '')) end, true)
    end
end

-- ========= Quick-aim helpers + context menu =========
local function rotToVec(rot)
    local z = math.rad(rot.z); local x = math.rad(rot.x)
    local num = math.abs(math.cos(x))
    return vec3(-math.sin(z)*num, math.cos(z)*num, math.sin(x))
end

local function aimedServerId()
    local cam = GetGameplayCamCoord()
    local dir = rotToVec(GetGameplayCamRot(2))
    local to = vec3(cam.x + dir.x*10.0, cam.y + dir.y*10.0, cam.z + dir.z*10.0)
    local ray = StartShapeTestRay(cam.x, cam.y, cam.z, to.x, to.y, to.z, 8, -1, 0)
    local hit, _, entity, _, _ = GetShapeTestResult(ray)
    if hit == 1 and IsPedAPlayer(entity) then return GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity)) end
end

local function openPlayerActions(targetId)
    targetId = ensureTargetId(targetId); if not targetId then return end
    if not hasLib() or not lib.registerContext then return notify('ox_lib context menu not available.', 'error') end
    local idx = GetPlayerFromServerId(targetId)
    local playerName = (idx and GetPlayerName(idx)) or ('ID '..tostring(targetId))
    lib.registerContext({
        id = 'qbx_admin_menu',
        title = ('Admin Actions - %s'):format(playerName),
        options = {
            { title='💰 Money: Give',   icon='plus',    onSelect=function() giveMoney(targetId) end },
            { title='💰 Money: Remove', icon='minus',   onSelect=function() removeMoney(targetId) end },
            { title='💰 Money: Set',    icon='equals',  onSelect=function() setMoney(targetId) end },
            { title='💼 Job: Set',      icon='briefcase', onSelect=function() setJob(targetId) end },
            { title='💼 Job: Grade',    icon='star',    onSelect=function() setJobGrade(targetId) end },
            { title='💼 Job: Toggle Duty', icon='clock', onSelect=function() toggleDuty(targetId) end },
            { title='👥 Gang: Set',     icon='users',   onSelect=function() setGang(targetId) end },
            { title='👑 Gang: Grade',   icon='crown',   onSelect=function() setGangGrade(targetId) end },
            { title='❤️ Heal',          icon='heart',   onSelect=function() heal(targetId) end },
            { title='🫀 Revive',        icon='activity',onSelect=function() revive(targetId) end },
            { title='ℹ️ Info',          icon='info',    onSelect=function() getInfo(targetId) end },
        }
    })
    lib.showContext('qbx_admin_menu')
end

local function openPlayersMenu()
    if not hasLib() or not lib.registerContext then
        return notify('ox_lib context menu not available.', 'error')
    end
    local selfId = GetPlayerServerId(PlayerId())
    local options = {
        { title=('Self - %s (ID: %d)'):format(GetPlayerName(PlayerId()), selfId), icon='user', onSelect=function()
            openPlayerActions(selfId)
        end }
    }
    for _, idx in ipairs(GetActivePlayers()) do
        local sid = GetPlayerServerId(idx)
        if sid ~= selfId then
            options[#options+1] = {
                title = ('%s (ID: %d)'):format(GetPlayerName(idx), sid),
                icon = 'user',
                onSelect = function() openPlayerActions(sid) end
            }
        end
    end
    lib.registerContext({ id='qbx_admin_players', title='Players', options=options })
    lib.showContext('qbx_admin_players')
end

RegisterCommand('qbxadmin_menu', function(_, args)
    if args[1] then
        openPlayerActions(args[1])
    else
        openPlayersMenu()
    end
end, true)
-- Alias: /adminmenu opens the same context UI
RegisterCommand('adminmenu', function(_, args)
    if args[1] then
        openPlayerActions(args[1])
    else
        openPlayersMenu()
    end
end, true)

RegisterCommand('qbxadmin_menu_aim', function()
    local sid = aimedServerId()
    if sid then
        openPlayerActions(sid)
    else
        notify('Aim at a player first.', 'error')
    end
end, true)

-- Chat suggestions (if chat is running)
if GetResourceState('chat') == 'started' then
    local function suggest(cmd, help)
        TriggerEvent('chat:addSuggestion', '/'..cmd, help, { { name='serverId', help='Optional; prompts if omitted' } })
    end
    for _, cmd in ipairs({
        'qbxadmin_givemoney','qbxadmin_removemoney','qbxadmin_setmoney',
        'qbxadmin_setjob','qbxadmin_setjobgrade','qbxadmin_toggleduty',
        'qbxadmin_setgang','qbxadmin_setganggrade','qbxadmin_heal','qbxadmin_revive',
        'qbxadmin_info','qbxadmin_menu','qbxadmin_menu_aim'
    }) do suggest(cmd, 'QBX Admin: '..cmd:gsub('qbxadmin_',''):gsub('_',' ')) end
end

-- Keybinds (blank defaults; bind in Settings)
RegisterKeyMapping('qbxadmin_menu', 'QBX: Admin Menu', 'keyboard', '')
-- Bind F10 by default as requested in getting-started
RegisterKeyMapping('adminmenu', 'QBX: Admin Menu (alias)', 'keyboard', 'F10')
RegisterKeyMapping('qbxadmin_menu_aim', 'QBX: Admin Menu (Aim)', 'keyboard', '')
RegisterKeyMapping('qbxadmin_heal', 'QBX: Heal (prompt target)', 'keyboard', '')
RegisterKeyMapping('qbxadmin_revive', 'QBX: Revive (prompt target)', 'keyboard', '')

-- QBX Admin (txAdmin-first, EasyAdmin fallback) - Client

local RATE_MS = 750
local lastAction = 0

local function canActNow()
	local now = GetGameTimer()
	if (now - lastAction) < RATE_MS then return false end
	lastAction = now
	return true
end

local function hasLib()
	return GetResourceState('ox_lib') == 'started' and lib ~= nil
end

local function showNotification(message, type)
	type = type or 'info'
	if hasLib() and lib.notify then
		lib.notify({ title='QBX Admin', description=tostring(message), type=type, duration=5000 })
	else
		BeginTextCommandThefeedPost('STRING')
		AddTextComponentSubstringPlayerName(tostring(message))
		EndTextCommandThefeedPostTicker(false, false)
	end
end

local function getPlayerIndexFromServerId(sid)
	sid = tonumber(sid)
	if not sid then return -1 end
	local idx = GetPlayerFromServerId(sid)
	return idx or -1
end

local function ensureTargetId(targetId)
	targetId = tonumber(targetId)
	if targetId and targetId > 0 then return targetId end
	if not hasLib() or not lib.inputDialog then
		showNotification('ox_lib required to prompt for a target id.', 'error')
		return nil
	end
	local resp = lib.inputDialog('Target Player', { { type='number', label='Server ID', min=1, required=true } })
	if not resp or not resp[1] then return nil end
	local sid = tonumber(resp[1])
	if not sid or sid < 1 then
		showNotification('Invalid target id.', 'error')
		return nil
	end
	return sid
end

-- Money
local function giveMoney(targetId)
	if not canActNow() then return showNotification('Slow down a sec (rate limited).', 'error') end
	targetId = ensureTargetId(targetId); if not targetId then return end
	if not hasLib() or not lib.inputDialog then return showNotification('ox_lib required for this action.', 'error') end
	local account = lib.inputDialog('Give Money', {
		{ type='select', label='Account', options={{label='Cash',value='cash'},{label='Bank',value='bank'}}, required=true },
		{ type='number', label='Amount', min=1, max=1000000, required=true }
	})
	if account and account[1] and account[2] then
		TriggerServerEvent('QBXAdmin:GiveMoney', targetId, account[1], tonumber(account[2]))
	end
end

local function removeMoney(targetId)
	if not canActNow() then return showNotification('Slow down a sec (rate limited).', 'error') end
	targetId = ensureTargetId(targetId); if not targetId then return end
	if not hasLib() or not lib.inputDialog then return showNotification('ox_lib required for this action.', 'error') end
	local account = lib.inputDialog('Remove Money', {
		{ type='select', label='Account', options={{label='Cash',value='cash'},{label='Bank',value='bank'}}, required=true },
		{ type='number', label='Amount', min=1, max=1000000, required=true }
	})
	if account and account[1] and account[2] then
		TriggerServerEvent('QBXAdmin:RemoveMoney', targetId, account[1], tonumber(account[2]))
	end
end

local function setMoney(targetId)
	if not canActNow() then return showNotification('Slow down a sec (rate limited).', 'error') end
	targetId = ensureTargetId(targetId); if not targetId then return end
	if not hasLib() or not lib.inputDialog then return showNotification('ox_lib required for this action.', 'error') end
	local account = lib.inputDialog('Set Money', {
		{ type='select', label='Account', options={{label='Cash',value='cash'},{label='Bank',value='bank'}}, required=true },
		{ type='number', label='Amount', min=1, max=1000000, required=true }
	})
	if account and account[1] and account[2] then
		TriggerServerEvent('QBXAdmin:SetMoney', targetId, account[1], tonumber(account[2]))
	end
end

-- Job
local function setJob(targetId)
	if not canActNow() then return showNotification('Slow down a sec (rate limited).', 'error') end
	targetId = ensureTargetId(targetId); if not targetId then return end
	if not hasLib() or not lib.inputDialog then return showNotification('ox_lib required for this action.', 'error') end
	local job = lib.inputDialog('Set Job', { { type='input', label='Job Name', placeholder='police, ambulance, mechanic', required=true } })
	if job and job[1] then
		TriggerServerEvent('QBXAdmin:SetJob', targetId, job[1])
	end
end

local function setJobGrade(targetId)
	if not canActNow() then return showNotification('Slow down a sec (rate limited).', 'error') end
	targetId = ensureTargetId(targetId); if not targetId then return end
	if not hasLib() or not lib.inputDialog then return showNotification('ox_lib required for this action.', 'error') end
	local grade = lib.inputDialog('Set Job Grade', { { type='number', label='Grade', min=0, max=10, required=true } })
	if grade and grade[1] then
		TriggerServerEvent('QBXAdmin:SetJobGrade', targetId, tonumber(grade[1]))
	end
end

local function toggleDuty(targetId)
	if not canActNow() then return showNotification('Slow down a sec (rate limited).', 'error') end
	targetId = ensureTargetId(targetId); if not targetId then return end
	TriggerServerEvent('QBXAdmin:ToggleDuty', targetId)
end

-- Gang
local function setGang(targetId)
	if not canActNow() then return showNotification('Slow down a sec (rate limited).', 'error') end
	targetId = ensureTargetId(targetId); if not targetId then return end
	if not hasLib() or not lib.inputDialog then return showNotification('ox_lib required for this action.', 'error') end
	local gang = lib.inputDialog('Set Gang', { { type='input', label='Gang Name', placeholder='ballas, vagos', required=true } })
	if gang and gang[1] then
		TriggerServerEvent('QBXAdmin:SetGang', targetId, gang[1])
	end
end

local function setGangGrade(targetId)
	if not canActNow() then return showNotification('Slow down a sec (rate limited).', 'error') end
	targetId = ensureTargetId(targetId); if not targetId then return end
	if not hasLib() or not lib.inputDialog then return showNotification('ox_lib required for this action.', 'error') end
	local grade = lib.inputDialog('Set Gang Grade', { { type='number', label='Grade', min=0, max=10, required=true } })
	if grade and grade[1] then
		TriggerServerEvent('QBXAdmin:SetGangGrade', targetId, tonumber(grade[1]))
	end
end

-- Info/Health
local function getPlayerInfo(targetId)
	if not canActNow() then return showNotification('Slow down a sec (rate limited).', 'error') end
	targetId = ensureTargetId(targetId); if not targetId then return end
	TriggerServerEvent('QBXAdmin:GetPlayerInfo', targetId)
end

local function healPlayer(targetId)
	if not canActNow() then return showNotification('Slow down a sec (rate limited).', 'error') end
	targetId = ensureTargetId(targetId); if not targetId then return end
	TriggerServerEvent('QBXAdmin:Heal', targetId)
end

local function revivePlayer(targetId)
	if not canActNow() then return showNotification('Slow down a sec (rate limited).', 'error') end
	targetId = ensureTargetId(targetId); if not targetId then return end
	TriggerServerEvent('QBXAdmin:Revive', targetId)
end

RegisterNetEvent('QBXAdmin:ReceivePlayerInfo', function(info)
	if hasLib() and lib.alertDialog then
		lib.alertDialog({ header=('Player Info — %s'):format(info.name), content=(
			'CitizenID: %s\nJob: %s (Grade %d, %s)\nGang: %s (Grade %d)\nMoney: $%d cash, $%d bank')
			:format(tostring(info.citizenid), tostring(info.job), tonumber(info.jobGrade or 0), info.jobDuty and 'On Duty' or 'Off Duty', tostring(info.gang), tonumber(info.gangGrade or 0), tonumber(info.money.cash or 0), tonumber(info.money.bank or 0)), centered=true, cancel=false })
	else
		showNotification(('Player: %s  |  Job: %s (%d)  |  Gang: %s (%d)'):format(tostring(info.name), tostring(info.job), tonumber(info.jobGrade or 0), tostring(info.gang), tonumber(info.gangGrade or 0)), 'info')
	end
end)

RegisterNetEvent('QBXAdmin:Client:Heal', function()
	local ped = PlayerPedId()
	SetEntityHealth(ped, GetEntityMaxHealth(ped))
	ClearPedBloodDamage(ped)
	ResetPedVisibleDamage(ped)
	ClearPedWetness(ped)
	SetPedArmour(ped, 100)
	showNotification('You have been healed.', 'success')
end)

RegisterNetEvent('QBXAdmin:Client:Revive', function()
	local ped = PlayerPedId()
	local coords = GetEntityCoords(ped)
	local heading = GetEntityHeading(ped)
	NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, heading, true, false)
	ClearPedBloodDamage(ped)
	SetEntityHealth(ped, GetEntityMaxHealth(ped))
	SetPedArmour(ped, 0)
	ClearPedTasksImmediately(ped)
	showNotification('You have been revived.', 'success')
end)

-- Optional legacy event bridges (when EasyAdmin is present)
RegisterNetEvent('EasyAdmin:QBX:ReceivePlayerInfo', function(info)
	TriggerEvent('QBXAdmin:ReceivePlayerInfo', info)
end)
RegisterNetEvent('EasyAdmin:QBX:Client:Heal', function()
	TriggerEvent('QBXAdmin:Client:Heal')
end)
RegisterNetEvent('EasyAdmin:QBX:Client:Revive', function()
	TriggerEvent('QBXAdmin:Client:Revive')
end)

-- Commands (+legacy aliases if enabled)
local function registerAdminCommand(name, cb)
	RegisterCommand(name, cb, false)
	if Config and Config.UseEasyAdmin then
		RegisterCommand(('easyadmin_'..name), cb, false)
	end
end

registerAdminCommand('qbxadmin_givemoney', function(_, args) giveMoney(args[1]) end)
registerAdminCommand('qbxadmin_removemoney', function(_, args) removeMoney(args[1]) end)
registerAdminCommand('qbxadmin_setmoney', function(_, args) setMoney(args[1]) end)

registerAdminCommand('qbxadmin_setjob', function(_, args) setJob(args[1]) end)
registerAdminCommand('qbxadmin_setjobgrade', function(_, args) setJobGrade(args[1]) end)
registerAdminCommand('qbxadmin_toggleduty', function(_, args) toggleDuty(args[1]) end)

registerAdminCommand('qbxadmin_setgang', function(_, args) setGang(args[1]) end)
registerAdminCommand('qbxadmin_setganggrade', function(_, args) setGangGrade(args[1]) end)

registerAdminCommand('qbxadmin_playerinfo', function(_, args) getPlayerInfo(args[1]) end)

registerAdminCommand('qbxadmin_heal', function(_, args)
	local tid = args[1] and tonumber(args[1])
	if not tid then tid = GetPlayerServerId(PlayerId()) end
	healPlayer(tid)
end)

registerAdminCommand('qbxadmin_revive', function(_, args)
	local tid = args[1] and tonumber(args[1])
	if not tid then tid = GetPlayerServerId(PlayerId()) end
	revivePlayer(tid)
end)

-- Aim helper
local function RotAnglesToVec(rot)
	local z = math.rad(rot.z)
	local x = math.rad(rot.x)
	local num = math.abs(math.cos(x))
	return vec3(-math.sin(z) * num, math.cos(z) * num, math.sin(x))
end

local function getAimedServerId()
	local cam = GetGameplayCamCoord()
	local dir = RotAnglesToVec(GetGameplayCamRot(2))
	local to = vec3(cam.x + dir.x * 10.0, cam.y + dir.y * 10.0, cam.z + dir.z * 10.0)
	local ray = StartShapeTestRay(cam.x, cam.y, cam.z, to.x, to.y, to.z, 8, -1, 0)
	local hit, _, entity = GetShapeTestResult(ray)
	if hit == 1 and IsPedAPlayer(entity) then
		return GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))
	end
end

-- Quick actions
RegisterCommand('qbx_quick_heal', function()
	local targetId = getAimedServerId()
	if targetId then healPlayer(targetId) else showNotification('Aim at a player first to heal them.', 'error') end
end, true)

RegisterCommand('qbx_quick_revive', function()
	local targetId = getAimedServerId()
	if targetId then revivePlayer(targetId) else showNotification('Aim at a player first to revive them.', 'error') end
end, true)

local function openPlayerActions(targetId)
        targetId = ensureTargetId(targetId)
        if not targetId then return end
        if not hasLib() or not lib.registerContext then return showNotification('ox_lib context menu not available.', 'error') end
        local idx = getPlayerIndexFromServerId(targetId)
        local playerName = (idx ~= -1 and GetPlayerName(idx)) or 'Unknown'
        lib.registerContext({ id='qbx_admin_menu', title=('Admin Actions - %s (ID: %d)'):format(playerName, targetId), options={
                { title='💰 Money Management', description='Give, remove, or set money', icon='dollar-sign', menu='qbx_money_menu' },
                { title='💼 Job Management', description='Set job, grade, or toggle duty', icon='briefcase', menu='qbx_job_menu' },
                { title='🔫 Gang Management', description='Set gang or gang grade', icon='users', menu='qbx_gang_menu' },
                { title='❤️ Heal', description='Restore health/armor', icon='heart', onSelect=function() healPlayer(targetId) end },
                { title='🫀 Revive', description='Bring back from downed state', icon='activity', onSelect=function() revivePlayer(targetId) end },
                { title='ℹ️ Player Info', description='View detailed player information', icon='info', onSelect=function() getPlayerInfo(targetId) end },
        }})
        lib.registerContext({ id='qbx_money_menu', title='Money Management', menu='qbx_admin_menu', options={
                { title='Give Money', description='Add money to player account', icon='plus', onSelect=function() giveMoney(targetId) end },
                { title='Remove Money', description='Remove money from player account', icon='minus', onSelect=function() removeMoney(targetId) end },
                { title='Set Money', description='Set exact amount of money', icon='equals', onSelect=function() setMoney(targetId) end },
        }})
        lib.registerContext({ id='qbx_job_menu', title='Job Management', menu='qbx_admin_menu', options={
                { title='Set Job', description='Change player job', icon='briefcase', onSelect=function() setJob(targetId) end },
                { title='Set Job Grade', description='Change player job grade', icon='star', onSelect=function() setJobGrade(targetId) end },
                { title='Toggle Duty', description='Toggle player duty status', icon='clock', onSelect=function() toggleDuty(targetId) end },
        }})
        lib.registerContext({ id='qbx_gang_menu', title='Gang Management', menu='qbx_admin_menu', options={
                { title='Set Gang', description='Change player gang', icon='users', onSelect=function() setGang(targetId) end },
                { title='Set Gang Grade', description='Change player gang grade', icon='crown', onSelect=function() setGangGrade(targetId) end },
        }})
        lib.showContext('qbx_admin_menu')
end

local function openPlayersMenu()
        if not hasLib() or not lib.registerContext then
                return showNotification('ox_lib context menu not available.', 'error')
        end
        local selfId = GetPlayerServerId(PlayerId())
        local options = {
                { title=('Self - %s (ID: %d)'):format(GetPlayerName(PlayerId()), selfId), icon='user', onSelect=function()
                        openPlayerActions(selfId)
                end }
        }
        for _, idx in ipairs(GetActivePlayers()) do
                local sid = GetPlayerServerId(idx)
                if sid ~= selfId then
                        options[#options+1] = {
                                title = ('%s (ID: %d)'):format(GetPlayerName(idx), sid),
                                icon = 'user',
                                onSelect = function() openPlayerActions(sid) end
                        }
                end
        end
        lib.registerContext({ id='qbx_admin_players', title='Players', options=options })
        lib.showContext('qbx_admin_players')
end

registerAdminCommand('qbxadmin_menu', function(_, args)
        local target = args[1]
        if target then
                openPlayerActions(target)
        else
                openPlayersMenu()
        end
end)
registerAdminCommand('qbxadmin_menu_aim', function()
        local sid = getAimedServerId()
        if sid then
                openPlayerActions(sid)
        else
                showNotification('Aim at a player first.', 'error')
        end
end)

-- Chat Suggestions
if GetResourceState('chat') == 'started' then
	local suggestions = {
		{cmd='qbxadmin_givemoney',help='Give money to a player'},
		{cmd='qbxadmin_removemoney',help='Remove money from a player'},
		{cmd='qbxadmin_setmoney',help='Set exact amount of money for a player'},
		{cmd='qbxadmin_setjob',help="Set a player's job"},
		{cmd='qbxadmin_setjobgrade',help="Set a player's job grade"},
		{cmd='qbxadmin_toggleduty',help='Toggle a player duty status'},
		{cmd='qbxadmin_setgang',help='Set a player gang'},
		{cmd='qbxadmin_setganggrade',help='Set a player gang grade'},
		{cmd='qbxadmin_heal',help='Heal a player'},
		{cmd='qbxadmin_revive',help='Revive a player'},
		{cmd='qbxadmin_playerinfo',help='View detailed player information'},
		{cmd='qbxadmin_menu',help='Open admin context menu for a player'},
		{cmd='qbxadmin_menu_aim',help='Open admin context menu for aimed-at player'},
	}
	for _, s in ipairs(suggestions) do
		if s.cmd ~= 'qbxadmin_menu_aim' then
			TriggerEvent('chat:addSuggestion', '/'..s.cmd, s.help, { { name='serverId', help='Target player server ID (optional; prompts if omitted)' } })
		else
			TriggerEvent('chat:addSuggestion', '/'..s.cmd, s.help, { { name='', help='Aim at a player and use this command' } })
		end
	end
	if Config and Config.UseEasyAdmin then
		local map = {
			qbxadmin_givemoney='easyadmin_qbx_givemoney', qbxadmin_removemoney='easyadmin_qbx_removemoney', qbxadmin_setmoney='easyadmin_qbx_setmoney',
			qbxadmin_setjob='easyadmin_qbx_setjob', qbxadmin_setjobgrade='easyadmin_qbx_setjobgrade', qbxadmin_toggleduty='easyadmin_qbx_toggleduty',
			qbxadmin_setgang='easyadmin_qbx_setgang', qbxadmin_setganggrade='easyadmin_qbx_setganggrade', qbxadmin_heal='easyadmin_qbx_heal', qbxadmin_revive='easyadmin_qbx_revive',
			qbxadmin_playerinfo='easyadmin_qbx_playerinfo', qbxadmin_menu='easyadmin_qbx_menu', qbxadmin_menu_aim='easyadmin_qbx_menu_aim'
		}
		for _, s in ipairs(suggestions) do
			local legacy = map[s.cmd]
			if legacy then
				if s.cmd ~= 'qbxadmin_menu_aim' then
					TriggerEvent('chat:addSuggestion', '/'..legacy, s.help..' (legacy alias)', { { name='serverId', help='Target player server ID (optional; prompts if omitted)' } })
				else
					TriggerEvent('chat:addSuggestion', '/'..legacy, s.help..' (legacy alias)', { { name='', help='Aim at a player and use this command' } })
				end
			end
		end
	end
end

AddEventHandler('onResourceStop', function(res)
	if res ~= GetCurrentResourceName() or GetResourceState('chat') ~= 'started' then return end
	for _, cmd in ipairs({
		'qbxadmin_givemoney','qbxadmin_removemoney','qbxadmin_setmoney','qbxadmin_setjob','qbxadmin_setjobgrade','qbxadmin_toggleduty','qbxadmin_setgang','qbxadmin_setganggrade','qbxadmin_heal','qbxadmin_revive','qbxadmin_playerinfo','qbxadmin_menu','qbxadmin_menu_aim','qbx_quick_heal','qbx_quick_revive'
	}) do
		TriggerEvent('chat:removeSuggestion', '/'..cmd)
	end
	if Config and Config.UseEasyAdmin then
		for _, cmd in ipairs({
			'easyadmin_qbx_givemoney','easyadmin_qbx_removemoney','easyadmin_qbx_setmoney','easyadmin_qbx_setjob','easyadmin_qbx_setjobgrade','easyadmin_qbx_toggleduty','easyadmin_qbx_setgang','easyadmin_qbx_setganggrade','easyadmin_qbx_heal','easyadmin_qbx_revive','easyadmin_qbx_playerinfo','easyadmin_qbx_menu','easyadmin_qbx_menu_aim'
		}) do
			TriggerEvent('chat:removeSuggestion', '/'..cmd)
		end
	end
end)

-- Keybinds
RegisterKeyMapping('qbxadmin_givemoney', 'QBX: Give Money', 'keyboard', '')
RegisterKeyMapping('qbxadmin_removemoney', 'QBX: Remove Money', 'keyboard', '')
RegisterKeyMapping('qbxadmin_setmoney', 'QBX: Set Money', 'keyboard', '')
RegisterKeyMapping('qbxadmin_setjob', 'QBX: Set Job', 'keyboard', '')
RegisterKeyMapping('qbxadmin_setjobgrade', 'QBX: Set Job Grade', 'keyboard', '')
RegisterKeyMapping('qbxadmin_toggleduty', 'QBX: Toggle Duty', 'keyboard', '')
RegisterKeyMapping('qbxadmin_setgang', 'QBX: Set Gang', 'keyboard', '')
RegisterKeyMapping('qbxadmin_setganggrade', 'QBX: Set Gang Grade', 'keyboard', '')
RegisterKeyMapping('qbxadmin_heal', 'QBX: Heal Player', 'keyboard', '')
RegisterKeyMapping('qbxadmin_revive', 'QBX: Revive Player', 'keyboard', '')
RegisterKeyMapping('qbxadmin_playerinfo', 'QBX: Player Info', 'keyboard', '')
RegisterKeyMapping('qbxadmin_menu', 'QBX: Admin Menu', 'keyboard', '')
RegisterKeyMapping('qbxadmin_menu_aim', 'QBX: Admin Menu (Aim)', 'keyboard', '')

if Config and Config.UseEasyAdmin then
	RegisterKeyMapping('easyadmin_qbx_givemoney', 'QBX: Give Money (Legacy)', 'keyboard', '')
	RegisterKeyMapping('easyadmin_qbx_removemoney', 'QBX: Remove Money (Legacy)', 'keyboard', '')
	RegisterKeyMapping('easyadmin_qbx_setmoney', 'QBX: Set Money (Legacy)', 'keyboard', '')
	RegisterKeyMapping('easyadmin_qbx_setjob', 'QBX: Set Job (Legacy)', 'keyboard', '')
	RegisterKeyMapping('easyadmin_qbx_setjobgrade', 'QBX: Set Job Grade (Legacy)', 'keyboard', '')
	RegisterKeyMapping('easyadmin_qbx_toggleduty', 'QBX: Toggle Duty (Legacy)', 'keyboard', '')
	RegisterKeyMapping('easyadmin_qbx_setgang', 'QBX: Set Gang (Legacy)', 'keyboard', '')
	RegisterKeyMapping('easyadmin_qbx_setganggrade', 'QBX: Set Gang Grade (Legacy)', 'keyboard', '')
	RegisterKeyMapping('easyadmin_qbx_heal', 'QBX: Heal Player (Legacy)', 'keyboard', '')
	RegisterKeyMapping('easyadmin_qbx_revive', 'QBX: Revive Player (Legacy)', 'keyboard', '')
	RegisterKeyMapping('easyadmin_qbx_playerinfo', 'QBX: Player Info (Legacy)', 'keyboard', '')
	RegisterKeyMapping('easyadmin_qbx_menu', 'QBX: Admin Menu (Legacy)', 'keyboard', '')
	RegisterKeyMapping('easyadmin_qbx_menu_aim', 'QBX: Admin Menu (Aim, Legacy)', 'keyboard', '')
end

-- Quick Hotkeys
RegisterKeyMapping('qbx_quick_heal', 'QBX: Quick Heal (Aimed Player)', 'keyboard', 'F6')
RegisterKeyMapping('qbx_quick_revive', 'QBX: Quick Revive (Aimed Player)', 'keyboard', 'F7')

print('[QBX Admin] Client loaded')



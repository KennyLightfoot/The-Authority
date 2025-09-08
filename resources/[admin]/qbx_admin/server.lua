-- QBX Admin (txAdmin-first, EasyAdmin fallback) - Server

local VALID_ACCOUNTS = { cash = true, bank = true }
local MAX_MONEY_AMOUNT = 50000
local MAX_JOB_GRADE = 10
local MAX_GANG_GRADE = 10
local RATE_MS = 30000

local lastAction = {}

AddEventHandler('playerDropped', function()
	lastAction[source] = nil
end)

local function canActNow(src)
	local now = GetGameTimer()
	local last = lastAction[src] or 0
	if (now - last) < RATE_MS then return false end
	lastAction[src] = now
	return true
end

local function hasPermRaw(src, permKey)
	-- Allow console
	if src == 0 then return true end
	-- txAdmin-first
	if GetResourceState('txAdmin') == 'started' then
		local okTrusted, trusted = pcall(function()
			return exports['txAdmin'] and exports['txAdmin'].isPlayerTrusted and exports['txAdmin'].isPlayerTrusted(src)
		end)
		if okTrusted and trusted then
			local okHas, has = pcall(function()
				return exports['txAdmin'] and exports['txAdmin'].hasPerm and exports['txAdmin'].hasPerm(src, permKey)
			end)
			if okHas then return has end
			return true
		end
	end
	-- EasyAdmin helper
	if type(DoesPlayerHavePermission) == 'function' then
		local ok, has = pcall(DoesPlayerHavePermission, src, permKey)
		if ok and has then return true end
	end
	-- ACE fallback
	return IsPlayerAceAllowed(src, permKey)
end

local function hasActionPerm(src, action)
	local key = Config and Config.Perms and Config.Perms[action]
	if not key or key == '' then return false end
	return hasPermRaw(src, key)
end

local function canProceed(src)
	if hasActionPerm(src, 'bypass') then return true end
	return canActNow(src)
end

local validPlayer = function(id)
	id = tonumber(id)
	if not id then return false end
	if not GetPlayerName(id) then return false end
	return true
end

local function getPlayerData(pid)
	local player = exports['qbx_core']:GetPlayer(pid)
	return player
end

local function getLivePlayer(id)
	if not validPlayer(id) then return nil end
	return getPlayerData(id)
end

local function sanitizeAmount(v)
	v = tonumber(v)
	if not v or v ~= v or v <= 0 then return nil end
	if v > MAX_MONEY_AMOUNT then return MAX_MONEY_AMOUNT end
	return math.floor(v)
end

local function sanitizeAccount(a)
	if not a then return nil end
	a = string.lower(a)
	if VALID_ACCOUNTS[a] then return a end
	return nil
end

local function notifyAdmin(source, message, type)
	type = type or 'info'
	TriggerClientEvent('ox_lib:notify', source, { title='QBX Admin', description=message, type=type, duration=5000 })
end

local function getIdentifierByType(pid, typ)
	if GetPlayerIdentifierByType then return GetPlayerIdentifierByType(pid, typ) end
	for i = 0, GetNumPlayerIdentifiers(pid) - 1 do
		local id = GetPlayerIdentifier(pid, i)
		if id and id:find(typ..':') == 1 then return id end
	end
	return nil
end

local function idLine(pid)
	local license = getIdentifierByType(pid, 'license') or 'n/a'
	local discord = getIdentifierByType(pid, 'discord') or 'n/a'
	local steam = getIdentifierByType(pid, 'steam') or 'n/a'
	return string.format('(%d) lic:%s dc:%s steam:%s', pid, license, discord, steam)
end

local function getWebhook(category)
	if not Config or not Config.Webhooks then return '' end
	if category == 'money' and Config.Webhooks.money and Config.Webhooks.money ~= '' then return Config.Webhooks.money end
	if category == 'job'   and Config.Webhooks.job   and Config.Webhooks.job   ~= '' then return Config.Webhooks.job end
	if category == 'gang'  and Config.Webhooks.gang  and Config.Webhooks.gang  ~= '' then return Config.Webhooks.gang end
	return Config.Webhooks.default or ''
end

local function sendAudit(title, description, color, category)
	local webhook = getWebhook(category)
	if not webhook or webhook == '' then return end
	if type(json) ~= 'table' or type(json.encode) ~= 'function' then
		print('[QBX Admin] json.encode not available, skipping Discord audit')
		return
	end
	PerformHttpRequest(webhook, function() end, 'POST', json.encode({
		username = 'QBX Admin',
		embeds = {{ title = title, description = description, color = color or 3447003, timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ') }}
	}), { ['Content-Type'] = 'application/json' })
end

-- Neutral Events (with legacy bridges at bottom)

RegisterNetEvent('QBXAdmin:GiveMoney')
AddEventHandler('QBXAdmin:GiveMoney', function(targetId, account, amount)
	local src = source
	if not hasActionPerm(src, 'money') then return notifyAdmin(src, "You don't have permission to manage money", 'error') end
	if not canProceed(src) then return notifyAdmin(src, 'Slow down a sec (rate limited).', 'error') end
	if not validPlayer(targetId) then return notifyAdmin(src, 'Player not found', 'error') end
	if src == tonumber(targetId) then return notifyAdmin(src, "You can't target yourself with this action.", 'error') end
	account = sanitizeAccount(account); amount = sanitizeAmount(amount)
	if not account or not amount then return notifyAdmin(src, 'Invalid account or amount', 'error') end
	local targetPlayer = getLivePlayer(targetId); if not targetPlayer then return notifyAdmin(src, 'Player not found (disconnected?)', 'error') end
	local ok = targetPlayer.Functions.AddMoney(account, amount, 'Admin gave money')
	if ok then
		local adminName = GetPlayerName(src) or ('['..tostring(src)..']')
		local targetName = GetPlayerName(targetId) or ('['..tostring(targetId)..']')
		notifyAdmin(src, ('Gave $%d %s to %s'):format(amount, account, targetName), 'success')
		TriggerClientEvent('ox_lib:notify', targetId, { title='Money Received', description=('You received $%d %s from an admin'):format(amount, account), type='success', duration=5000 })
		print(('[QBX Admin] %s -> %s: +$%d %s'):format(adminName, targetName, amount, account))
		sendAudit('Money Given', ('**Admin:** %s %s\n**Target:** %s %s\n**Amount:** $%d %s'):format(adminName, idLine(src), targetName, idLine(targetId), amount, account), 3066993, 'money')
	else
		notifyAdmin(src, 'Failed to give money', 'error')
	end
end)

RegisterNetEvent('QBXAdmin:RemoveMoney')
AddEventHandler('QBXAdmin:RemoveMoney', function(targetId, account, amount)
	local src = source
	if not hasActionPerm(src, 'money') then return notifyAdmin(src, "You don't have permission to manage money", 'error') end
	if not canProceed(src) then return notifyAdmin(src, 'Slow down a sec (rate limited).', 'error') end
	if not validPlayer(targetId) then return notifyAdmin(src, 'Player not found', 'error') end
	if src == tonumber(targetId) then return notifyAdmin(src, "You can't target yourself with this action.", 'error') end
	account = sanitizeAccount(account); amount = sanitizeAmount(amount)
	if not account or not amount then return notifyAdmin(src, 'Invalid account or amount', 'error') end
	local targetPlayer = getLivePlayer(targetId); if not targetPlayer then return notifyAdmin(src, 'Player not found (disconnected?)', 'error') end
	local currentMoney = (targetPlayer.PlayerData.money and targetPlayer.PlayerData.money[account]) or 0
	if currentMoney < amount then return notifyAdmin(src, ('Player only has $%d %s'):format(currentMoney, account), 'error') end
	local ok = targetPlayer.Functions.RemoveMoney(account, amount, 'Admin removed money')
	if ok then
		local adminName = GetPlayerName(src) or ('['..tostring(src)..']')
		local targetName = GetPlayerName(targetId) or ('['..tostring(targetId)..']')
		notifyAdmin(src, ('Removed $%d %s from %s'):format(amount, account, targetName), 'success')
		TriggerClientEvent('ox_lib:notify', targetId, { title='Money Removed', description=(' $%d %s was removed by an admin'):format(amount, account), type='error', duration=5000 })
		print(('[QBX Admin] %s -> %s: -$%d %s'):format(adminName, targetName, amount, account))
		sendAudit('Money Removed', ('**Admin:** %s %s\n**Target:** %s %s\n**Amount:** $%d %s'):format(adminName, idLine(src), targetName, idLine(targetId), amount, account), 15158332, 'money')
	else
		notifyAdmin(src, 'Failed to remove money', 'error')
	end
end)

RegisterNetEvent('QBXAdmin:SetMoney')
AddEventHandler('QBXAdmin:SetMoney', function(targetId, account, amount)
	local src = source
	if not hasActionPerm(src, 'money') then return notifyAdmin(src, "You don't have permission to manage money", 'error') end
	if not canProceed(src) then return notifyAdmin(src, 'Slow down a sec (rate limited).', 'error') end
	if not validPlayer(targetId) then return notifyAdmin(src, 'Player not found', 'error') end
	if src == tonumber(targetId) then return notifyAdmin(src, "You can't target yourself with this action.", 'error') end
	account = sanitizeAccount(account); amount = sanitizeAmount(amount)
	if not account or not amount then return notifyAdmin(src, 'Invalid account or amount', 'error') end
	local targetPlayer = getLivePlayer(targetId); if not targetPlayer then return notifyAdmin(src, 'Player not found (disconnected?)', 'error') end
	local currentMoney = (targetPlayer.PlayerData.money and targetPlayer.PlayerData.money[account]) or 0
	local diff = amount - currentMoney
	local ok = true
	if diff > 0 then ok = targetPlayer.Functions.AddMoney(account, diff, 'Admin set money')
	elseif diff < 0 then ok = targetPlayer.Functions.RemoveMoney(account, math.abs(diff), 'Admin set money') end
	if ok then
		local adminName = GetPlayerName(src) or ('['..tostring(src)..']')
		local targetName = GetPlayerName(targetId) or ('['..tostring(targetId)..']')
		notifyAdmin(src, ("Set %s's %s to $%d"):format(targetName, account, amount), 'success')
		TriggerClientEvent('ox_lib:notify', targetId, { title='Money Set', description=("Your %s was set to $%d by an admin"):format(account, amount), type='info', duration=5000 })
		print(('[QBX Admin] %s -> %s: %s = $%d (was $%d)'):format(adminName, targetName, account, amount, currentMoney))
		sendAudit('Money Set', ('**Admin:** %s %s\n**Target:** %s %s\n**Account:** %s\n**Amount:** $%d (was $%d)'):format(adminName, idLine(src), targetName, idLine(targetId), account, amount, currentMoney), 3447003, 'money')
	else
		notifyAdmin(src, 'Failed to set money', 'error')
	end
end)

-- Job
RegisterNetEvent('QBXAdmin:SetJob')
AddEventHandler('QBXAdmin:SetJob', function(targetId, jobName)
	local src = source
	if not hasActionPerm(src, 'job') then return notifyAdmin(src, "You don't have permission to manage jobs", 'error') end
	if not canProceed(src) then return notifyAdmin(src, 'Slow down a sec (rate limited).', 'error') end
	if not validPlayer(targetId) then return notifyAdmin(src, 'Player not found', 'error') end
	if src == tonumber(targetId) then return notifyAdmin(src, "You can't target yourself with this action.", 'error') end
	if type(jobName) ~= 'string' or jobName == '' then return notifyAdmin(src, 'Invalid job', 'error') end
	local targetPlayer = getLivePlayer(targetId); if not targetPlayer then return notifyAdmin(src, 'Player not found (disconnected?)', 'error') end
	local ok, ret = pcall(function() return targetPlayer.Functions.SetJob(jobName, 0) end)
	if ok and (ret == nil or ret == true) then
		local adminName = GetPlayerName(src) or ('['..tostring(src)..']')
		local targetName = GetPlayerName(targetId) or ('['..tostring(targetId)..']')
		notifyAdmin(src, ("Set %s's job to %s"):format(targetName, jobName), 'success')
		TriggerClientEvent('ox_lib:notify', targetId, { title='Job Changed', description=("Your job was changed to %s by an admin"):format(jobName), type='info', duration=5000 })
		print(('[QBX Admin] %s -> %s: job = %s'):format(adminName, targetName, jobName))
		sendAudit('Job Changed', ('**Admin:** %s %s\n**Target:** %s %s\n**Job:** %s'):format(adminName, idLine(src), targetName, idLine(targetId), jobName), 3447003, 'job')
	else
		notifyAdmin(src, 'Failed to set job', 'error')
	end
end)

RegisterNetEvent('QBXAdmin:SetJobGrade')
AddEventHandler('QBXAdmin:SetJobGrade', function(targetId, grade)
	local src = source
	if not hasActionPerm(src, 'job') then return notifyAdmin(src, "You don't have permission to manage jobs", 'error') end
	if not canProceed(src) then return notifyAdmin(src, 'Slow down a sec (rate limited).', 'error') end
	if not validPlayer(targetId) then return notifyAdmin(src, 'Player not found', 'error') end
	if src == tonumber(targetId) then return notifyAdmin(src, "You can't target yourself with this action.", 'error') end
	grade = tonumber(grade); if not grade or grade < 0 then return notifyAdmin(src, 'Invalid grade', 'error') end
	local targetPlayer = getLivePlayer(targetId); if not targetPlayer or not targetPlayer.PlayerData or not targetPlayer.PlayerData.job then return notifyAdmin(src, 'Player or job not found', 'error') end
	local currentJob = targetPlayer.PlayerData.job.name
	local maxGrade = MAX_JOB_GRADE
	if targetPlayer.PlayerData.job.grade and targetPlayer.PlayerData.job.grade.level then maxGrade = targetPlayer.PlayerData.job.grade.level or MAX_JOB_GRADE end
	grade = math.min(grade, maxGrade)
	local ok, ret = pcall(function() return targetPlayer.Functions.SetJob(currentJob, grade) end)
	if ok and (ret == nil or ret == true) then
		local adminName = GetPlayerName(src) or ('['..tostring(src)..']')
		local targetName = GetPlayerName(targetId) or ('['..tostring(targetId)..']')
		notifyAdmin(src, ("Set %s's job grade to %d"):format(targetName, grade), 'success')
		TriggerClientEvent('ox_lib:notify', targetId, { title='Job Grade Changed', description=("Your job grade was changed to %d by an admin"):format(grade), type='info', duration=5000 })
		print(('[QBX Admin] %s -> %s: %s grade = %d'):format(adminName, targetName, currentJob, grade))
		sendAudit('Job Grade Changed', ('**Admin:** %s %s\n**Target:** %s %s\n**Job:** %s\n**Grade:** %d'):format(adminName, idLine(src), targetName, idLine(targetId), currentJob, grade), 3447003, 'job')
	else
		notifyAdmin(src, 'Failed to set job grade', 'error')
	end
end)

RegisterNetEvent('QBXAdmin:ToggleDuty')
AddEventHandler('QBXAdmin:ToggleDuty', function(targetId)
	local src = source
	if not hasActionPerm(src, 'job') then return notifyAdmin(src, "You don't have permission to manage jobs", 'error') end
	if not canProceed(src) then return notifyAdmin(src, 'Slow down a sec (rate limited).', 'error') end
	if not validPlayer(targetId) then return notifyAdmin(src, 'Player not found', 'error') end
	if src == tonumber(targetId) then return notifyAdmin(src, "You can't target yourself with this action.", 'error') end
	local targetPlayer = getLivePlayer(targetId); if not targetPlayer or not targetPlayer.PlayerData or not targetPlayer.PlayerData.job then return notifyAdmin(src, 'Player or job not found', 'error') end
	local currentDuty = targetPlayer.PlayerData.job.onduty == true
	local newState = not currentDuty
	local ok, ret = pcall(function() return targetPlayer.Functions.SetDuty(newState) end)
	if ok and (ret == nil or ret == true) then
		local adminName = GetPlayerName(src) or ('['..tostring(src)..']')
		local targetName = GetPlayerName(targetId) or ('['..tostring(targetId)..']')
		local dutyStatus = newState and 'on duty' or 'off duty'
		notifyAdmin(src, ("Set %s %s"):format(targetName, dutyStatus), 'success')
		TriggerClientEvent('ox_lib:notify', targetId, { title='Duty Status Changed', description=("You are now %s"):format(dutyStatus), type='info', duration=5000 })
		print(('[QBX Admin] %s -> %s: duty = %s'):format(adminName, targetName, dutyStatus))
		sendAudit('Duty Status Changed', ('**Admin:** %s %s\n**Target:** %s %s\n**Status:** %s'):format(adminName, idLine(src), targetName, idLine(targetId), dutyStatus), 3447003, 'job')
	else
		notifyAdmin(src, 'Failed to toggle duty', 'error')
	end
end)

-- Gang
RegisterNetEvent('QBXAdmin:SetGang')
AddEventHandler('QBXAdmin:SetGang', function(targetId, gangName)
	local src = source
	if not hasActionPerm(src, 'gang') then return notifyAdmin(src, "You don't have permission to manage gangs", 'error') end
	if not canProceed(src) then return notifyAdmin(src, 'Slow down a sec (rate limited).', 'error') end
	if not validPlayer(targetId) then return notifyAdmin(src, 'Player not found', 'error') end
	if src == tonumber(targetId) then return notifyAdmin(src, "You can't target yourself with this action.", 'error') end
	if type(gangName) ~= 'string' or gangName == '' then return notifyAdmin(src, 'Invalid gang', 'error') end
	local targetPlayer = getLivePlayer(targetId); if not targetPlayer then return notifyAdmin(src, 'Player not found (disconnected?)', 'error') end
	local ok, ret = pcall(function() return targetPlayer.Functions.SetGang(gangName, 0) end)
	if ok and (ret == nil or ret == true) then
		local adminName = GetPlayerName(src) or ('['..tostring(src)..']')
		local targetName = GetPlayerName(targetId) or ('['..tostring(targetId)..']')
		notifyAdmin(src, ("Set %s's gang to %s"):format(targetName, gangName), 'success')
		TriggerClientEvent('ox_lib:notify', targetId, { title='Gang Changed', description=("Your gang was changed to %s by an admin"):format(gangName), type='info', duration=5000 })
		print(('[QBX Admin] %s -> %s: gang = %s'):format(adminName, targetName, gangName))
		sendAudit('Gang Changed', ('**Admin:** %s %s\n**Target:** %s %s\n**Gang:** %s'):format(adminName, idLine(src), targetName, idLine(targetId), gangName), 15105570, 'gang')
	else
		notifyAdmin(src, 'Failed to set gang', 'error')
	end
end)

RegisterNetEvent('QBXAdmin:SetGangGrade')
AddEventHandler('QBXAdmin:SetGangGrade', function(targetId, grade)
	local src = source
	if not hasActionPerm(src, 'gang') then return notifyAdmin(src, "You don't have permission to manage gangs", 'error') end
	if not canProceed(src) then return notifyAdmin(src, 'Slow down a sec (rate limited).', 'error') end
	if not validPlayer(targetId) then return notifyAdmin(src, 'Player not found', 'error') end
	if src == tonumber(targetId) then return notifyAdmin(src, "You can't target yourself with this action.", 'error') end
	grade = tonumber(grade); if not grade or grade < 0 then return notifyAdmin(src, 'Invalid grade', 'error') end
	local targetPlayer = getLivePlayer(targetId); if not targetPlayer or not targetPlayer.PlayerData or not targetPlayer.PlayerData.gang then return notifyAdmin(src, 'Player or gang not found', 'error') end
	local currentGang = targetPlayer.PlayerData.gang.name
	local maxG = MAX_GANG_GRADE
	if targetPlayer.PlayerData.gang.grade and targetPlayer.PlayerData.gang.grade.level then maxG = targetPlayer.PlayerData.gang.grade.level or MAX_GANG_GRADE end
	grade = math.min(grade, maxG)
	local ok, ret = pcall(function() return targetPlayer.Functions.SetGang(currentGang, grade) end)
	if ok and (ret == nil or ret == true) then
		local adminName = GetPlayerName(src) or ('['..tostring(src)..']')
		local targetName = GetPlayerName(targetId) or ('['..tostring(targetId)..']')
		notifyAdmin(src, ("Set %s's gang grade to %d"):format(targetName, grade), 'success')
		TriggerClientEvent('ox_lib:notify', targetId, { title='Gang Grade Changed', description=("Your gang grade was changed to %d by an admin"):format(grade), type='info', duration=5000 })
		print(('[QBX Admin] %s -> %s: %s grade = %d'):format(adminName, targetName, currentGang, grade))
		sendAudit('Gang Grade Changed', ('**Admin:** %s %s\n**Target:** %s %s\n**Gang:** %s\n**Grade:** %d'):format(adminName, idLine(src), targetName, idLine(targetId), currentGang, grade), 15105570, 'gang')
	else
		notifyAdmin(src, 'Failed to set gang grade', 'error')
	end
end)

-- Info / Health
RegisterNetEvent('QBXAdmin:GetPlayerInfo')
AddEventHandler('QBXAdmin:GetPlayerInfo', function(targetId)
	local src = source
	if not hasActionPerm(src, 'info') then return notifyAdmin(src, "You don't have permission to view player info", 'error') end
	if not canProceed(src) then return notifyAdmin(src, 'Slow down a sec (rate limited).', 'error') end
	if not validPlayer(targetId) then return notifyAdmin(src, 'Player not found', 'error') end
	local targetPlayer = getLivePlayer(targetId); if not targetPlayer or not targetPlayer.PlayerData then return notifyAdmin(src, 'Player not found (disconnected?)', 'error') end
	local pd = targetPlayer.PlayerData
	local info = {
		name = GetPlayerName(targetId) or ('['..tostring(targetId)..']'),
		citizenid = pd.citizenid or 'unknown',
		job = (pd.job and pd.job.name) or 'unemployed',
		jobGrade = (pd.job and pd.job.grade and pd.job.grade.level) or 0,
		jobDuty = (pd.job and pd.job.onduty) == true,
		gang = (pd.gang and pd.gang.name) or 'none',
		gangGrade = (pd.gang and pd.gang.grade and pd.gang.grade.level) or 0,
		money = { cash = (pd.money and pd.money.cash) or 0, bank = (pd.money and pd.money.bank) or 0 }
	}
	TriggerClientEvent('QBXAdmin:ReceivePlayerInfo', src, info)
	local adminName = GetPlayerName(src) or ('['..tostring(src)..']')
	print(('[QBX Admin] %s requested info for %s (%s)'):format(adminName, info.name, tostring(pd.citizenid)))
end)

RegisterNetEvent('QBXAdmin:Heal')
AddEventHandler('QBXAdmin:Heal', function(targetId)
	local src = source
	if not hasActionPerm(src, 'heal') then return notifyAdmin(src, "You don't have permission to heal", 'error') end
	if not canProceed(src) then return notifyAdmin(src, 'Slow down a sec (rate limited).', 'error') end
	targetId = tonumber(targetId) or src
	if not validPlayer(targetId) then return notifyAdmin(src, 'Player not found', 'error') end
	TriggerClientEvent('QBXAdmin:Client:Heal', targetId)
	local adminName = GetPlayerName(src) or ('['..tostring(src)..']')
	local targetName = GetPlayerName(targetId) or ('['..tostring(targetId)..']')
	notifyAdmin(src, ('Healed %s'):format(targetName), 'success')
	if src ~= targetId then
		TriggerClientEvent('ox_lib:notify', targetId, { title='Healed', description='An admin healed you', type='success', duration=4000 })
	end
	print(('[QBX Admin] %s healed %s'):format(adminName, targetName))
	sendAudit('Heal', ('**Admin:** %s %s\n**Target:** %s %s'):format(adminName, idLine(src), targetName, idLine(targetId)), 3066993, 'health')
end)

RegisterNetEvent('QBXAdmin:Revive')
AddEventHandler('QBXAdmin:Revive', function(targetId)
	local src = source
	if not hasActionPerm(src, 'revive') then return notifyAdmin(src, "You don't have permission to revive", 'error') end
	if not canProceed(src) then return notifyAdmin(src, 'Slow down a sec (rate limited).', 'error') end
	targetId = tonumber(targetId) or src
	if not validPlayer(targetId) then return notifyAdmin(src, 'Player not found', 'error') end
	-- Optionally call medical resource here
	TriggerClientEvent('QBXAdmin:Client:Revive', targetId)
	local adminName = GetPlayerName(src) or ('['..tostring(src)..']')
	local targetName = GetPlayerName(targetId) or ('['..tostring(targetId)..']')
	notifyAdmin(src, ('Revived %s'):format(targetName), 'success')
	if src ~= targetId then
		TriggerClientEvent('ox_lib:notify', targetId, { title='Revived', description='An admin revived you', type='success', duration=4000 })
	end
	print(('[QBX Admin] %s revived %s'):format(adminName, targetName))
	sendAudit('Revive', ('**Admin:** %s %s\n**Target:** %s %s'):format(adminName, idLine(src), targetName, idLine(targetId)), 3447003, 'health')
end)

-- Server Commands (txAdmin Remote Console / menu buttons)
local function registerServerCommand(name, handler)
	RegisterCommand(name, function(src, args)
		handler(src, args)
	end, true)
end

registerServerCommand('qbxadmin_givemoney', function(_, a)
	TriggerEvent('QBXAdmin:GiveMoney', tonumber(a[1]), a[2], tonumber(a[3]))
end)
registerServerCommand('qbxadmin_removemoney', function(_, a)
	TriggerEvent('QBXAdmin:RemoveMoney', tonumber(a[1]), a[2], tonumber(a[3]))
end)
registerServerCommand('qbxadmin_setmoney', function(_, a)
	TriggerEvent('QBXAdmin:SetMoney', tonumber(a[1]), a[2], tonumber(a[3]))
end)
registerServerCommand('qbxadmin_setjob', function(_, a)
	TriggerEvent('QBXAdmin:SetJob', tonumber(a[1]), a[2])
end)
registerServerCommand('qbxadmin_setjobgrade', function(_, a)
	TriggerEvent('QBXAdmin:SetJobGrade', tonumber(a[1]), tonumber(a[2]))
end)
registerServerCommand('qbxadmin_toggleduty', function(_, a)
	TriggerEvent('QBXAdmin:ToggleDuty', tonumber(a[1]))
end)
registerServerCommand('qbxadmin_setgang', function(_, a)
	TriggerEvent('QBXAdmin:SetGang', tonumber(a[1]), a[2])
end)
registerServerCommand('qbxadmin_setganggrade', function(_, a)
	TriggerEvent('QBXAdmin:SetGangGrade', tonumber(a[1]), tonumber(a[2]))
end)
registerServerCommand('qbxadmin_heal', function(_, a)
	TriggerEvent('QBXAdmin:Heal', tonumber(a[1]))
end)
registerServerCommand('qbxadmin_revive', function(_, a)
	TriggerEvent('QBXAdmin:Revive', tonumber(a[1]))
end)
registerServerCommand('qbxadmin_info', function(_, a)
	TriggerEvent('QBXAdmin:GetPlayerInfo', tonumber(a[1]))
end)

-- Legacy EasyAdmin Bridges (optional)
RegisterNetEvent('EasyAdmin:QBX:GiveMoney')      AddEventHandler('EasyAdmin:QBX:GiveMoney',      function(...) TriggerEvent('QBXAdmin:GiveMoney', ...) end)
RegisterNetEvent('EasyAdmin:QBX:RemoveMoney')    AddEventHandler('EasyAdmin:QBX:RemoveMoney',    function(...) TriggerEvent('QBXAdmin:RemoveMoney', ...) end)
RegisterNetEvent('EasyAdmin:QBX:SetMoney')       AddEventHandler('EasyAdmin:QBX:SetMoney',       function(...) TriggerEvent('QBXAdmin:SetMoney', ...) end)
RegisterNetEvent('EasyAdmin:QBX:SetJob')         AddEventHandler('EasyAdmin:QBX:SetJob',         function(...) TriggerEvent('QBXAdmin:SetJob', ...) end)
RegisterNetEvent('EasyAdmin:QBX:SetJobGrade')    AddEventHandler('EasyAdmin:QBX:SetJobGrade',    function(...) TriggerEvent('QBXAdmin:SetJobGrade', ...) end)
RegisterNetEvent('EasyAdmin:QBX:ToggleDuty')     AddEventHandler('EasyAdmin:QBX:ToggleDuty',     function(...) TriggerEvent('QBXAdmin:ToggleDuty', ...) end)
RegisterNetEvent('EasyAdmin:QBX:SetGang')        AddEventHandler('EasyAdmin:QBX:SetGang',        function(...) TriggerEvent('QBXAdmin:SetGang', ...) end)
RegisterNetEvent('EasyAdmin:QBX:SetGangGrade')   AddEventHandler('EasyAdmin:QBX:SetGangGrade',   function(...) TriggerEvent('QBXAdmin:SetGangGrade', ...) end)
RegisterNetEvent('EasyAdmin:QBX:GetPlayerInfo')  AddEventHandler('EasyAdmin:QBX:GetPlayerInfo',  function(...) TriggerEvent('QBXAdmin:GetPlayerInfo', ...) end)
RegisterNetEvent('EasyAdmin:QBX:Heal')           AddEventHandler('EasyAdmin:QBX:Heal',           function(...) TriggerEvent('QBXAdmin:Heal', ...) end)
RegisterNetEvent('EasyAdmin:QBX:Revive')         AddEventHandler('EasyAdmin:QBX:Revive',         function(...) TriggerEvent('QBXAdmin:Revive', ...) end)

print('[QBX Admin] Server loaded')



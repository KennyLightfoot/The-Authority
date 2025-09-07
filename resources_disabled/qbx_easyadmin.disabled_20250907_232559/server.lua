-- EasyAdmin QBX Integration Plugin - Server Side
-- Custom plugin for QBX framework integration with EasyAdmin

-- Configuration
local VALID_ACCOUNTS = { cash = true, bank = true }
local MAX_MONEY_AMOUNT = 1000000
local MAX_JOB_GRADE = 10
local MAX_GANG_GRADE = 10
local DISCORD_WEBHOOK = GetConvar('qbx_admin_webhook', '')
local WEBHOOK_MONEY = GetConvar('qbx_admin_webhook_money', DISCORD_WEBHOOK)
local WEBHOOK_JOB   = GetConvar('qbx_admin_webhook_job',   DISCORD_WEBHOOK)
local WEBHOOK_GANG  = GetConvar('qbx_admin_webhook_gang',  DISCORD_WEBHOOK)
local RATE_MS = 750

local lastAction = {}

AddEventHandler('playerDropped', function()
	lastAction[source] = nil
end)

-- ===== Neutral server console commands (txAdmin/console friendly) =====
-- These allow executing via txAdmin RCON/console: e.g. 'qbxadmin_givemoney 23 cash 500'

RegisterCommand('qbxadmin_givemoney', function(src, args)
    local targetId, account, amount = tonumber(args[1]), args[2], tonumber(args[3])
    TriggerEvent('QBXAdmin:GiveMoney', targetId, account, amount)
end, true)

RegisterCommand('qbxadmin_removemoney', function(src, args)
    local targetId, account, amount = tonumber(args[1]), args[2], tonumber(args[3])
    TriggerEvent('QBXAdmin:RemoveMoney', targetId, account, amount)
end, true)

RegisterCommand('qbxadmin_setmoney', function(src, args)
    local targetId, account, amount = tonumber(args[1]), args[2], tonumber(args[3])
    TriggerEvent('QBXAdmin:SetMoney', targetId, account, amount)
end, true)

RegisterCommand('qbxadmin_setjob', function(src, args)
    local targetId, job = tonumber(args[1]), args[2]
    TriggerEvent('QBXAdmin:SetJob', targetId, job)
end, true)

RegisterCommand('qbxadmin_setjobgrade', function(src, args)
    local targetId, grade = tonumber(args[1]), tonumber(args[2])
    TriggerEvent('QBXAdmin:SetJobGrade', targetId, grade)
end, true)

RegisterCommand('qbxadmin_toggleduty', function(src, args)
    local targetId = tonumber(args[1])
    TriggerEvent('QBXAdmin:ToggleDuty', targetId)
end, true)

RegisterCommand('qbxadmin_setgang', function(src, args)
    local targetId, gang = tonumber(args[1]), args[2]
    TriggerEvent('QBXAdmin:SetGang', targetId, gang)
end, true)

RegisterCommand('qbxadmin_setganggrade', function(src, args)
    local targetId, grade = tonumber(args[1]), tonumber(args[2])
    TriggerEvent('QBXAdmin:SetGangGrade', targetId, grade)
end, true)

RegisterCommand('qbxadmin_playerinfo', function(src, args)
    local targetId = tonumber(args[1])
    TriggerEvent('QBXAdmin:GetPlayerInfo', targetId)
end, true)

RegisterCommand('qbxadmin_heal', function(src, args)
    local targetId = tonumber(args[1])
    TriggerEvent('QBXAdmin:Heal', targetId)
end, true)

RegisterCommand('qbxadmin_revive', function(src, args)
    local targetId = tonumber(args[1])
    TriggerEvent('QBXAdmin:Revive', targetId)
end, true)

local validPlayer

local function getPlayerData(source)
	local player = exports['qbx_core']:GetPlayer(source)
	if not player then
		return nil
	end
	return player
end

local function getLivePlayer(id)
	if not validPlayer(id) then return nil end
	return getPlayerData(id)
end

local function canActNow(src)
	local now = GetGameTimer()
	local last = lastAction[src] or 0
	if (now - last) < RATE_MS then return false end
	lastAction[src] = now
	return true
end

local function hasPerm(src, perm)
	-- Allow console
	if src == 0 then return true end
	-- txAdmin-first: check trust and granular perm when available
	if GetResourceState('txAdmin') == 'started' then
		local okTrusted, trusted = pcall(function()
			return exports['txAdmin'] and exports['txAdmin'].isPlayerTrusted and exports['txAdmin'].isPlayerTrusted(src)
		end)
		if okTrusted and trusted then
			local okHas, has = pcall(function()
				return exports['txAdmin'] and exports['txAdmin'].hasPerm and exports['txAdmin'].hasPerm(src, perm)
			end)
			if okHas then return has end
			-- If trusted but no granular check, allow
			return true
		end
	end
	-- EasyAdmin/native fallback
	if type(DoesPlayerHavePermission) == "function" then
		return DoesPlayerHavePermission(src, perm)
	end
	return IsPlayerAceAllowed(src, perm)
end

local function canProceed(src)
	local bypassKey = (GetResourceState('txAdmin') == 'started') and 'qbxadmin.bypassratelimit' or 'easyadmin.qbx.bypassratelimit'
	if hasPerm(src, bypassKey) then return true end
	return canActNow(src)
end

local function hasActionPerm(src, action)
	local key
	if GetResourceState('txAdmin') == 'started' then
		key = ('qbxadmin.%s'):format(action)
	else
		key = ('easyadmin.qbx.%s'):format(action)
	end
	return hasPerm(src, key)
end

local function getIdentifierByType(pid, typ)
	if GetPlayerIdentifierByType then
		return GetPlayerIdentifierByType(pid, typ)
	end
	for i = 0, GetNumPlayerIdentifiers(pid) - 1 do
		local id = GetPlayerIdentifier(pid, i)
		if id and id:find(typ..":") == 1 then return id end
	end
	return nil
end

local function idLine(pid)
	local license = getIdentifierByType(pid, "license") or "n/a"
	local discord = getIdentifierByType(pid, "discord") or "n/a"
	local steam = getIdentifierByType(pid, "steam") or "n/a"
	return string.format("(%d) lic:%s dc:%s steam:%s", pid, license, discord, steam)
end

validPlayer = function(id)
	id = tonumber(id)
	if not id then return false end
	if not GetPlayerName(id) then return false end
	return true
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
	type = type or "info"
	TriggerClientEvent('ox_lib:notify', source, {
		title = 'QBX Admin',
		description = message,
		type = type,
		duration = 5000
	})
end

local function getWebhook(category)
	if category == 'money' and WEBHOOK_MONEY and WEBHOOK_MONEY ~= '' then return WEBHOOK_MONEY end
	if category == 'job'   and WEBHOOK_JOB   and WEBHOOK_JOB   ~= '' then return WEBHOOK_JOB end
	if category == 'gang'  and WEBHOOK_GANG  and WEBHOOK_GANG  ~= '' then return WEBHOOK_GANG end
	return DISCORD_WEBHOOK
end

local function sendAudit(title, description, color, category)
	local webhook = getWebhook(category)
	if not webhook or webhook == "" then return end
	if type(json) ~= "table" or type(json.encode) ~= "function" then
		print("[QBX Admin] Warning: json.encode not available, skipping Discord audit")
		return
	end
	color = color or 3066993
	PerformHttpRequest(webhook, function() end, 'POST', json.encode({
		username = "QBX Admin",
		embeds = {{
			title = title,
			description = description,
			color = color,
			timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
		}}
	}), { ['Content-Type'] = 'application/json' })
end

CreateThread(function()
	if type(json) ~= 'table' or type(json.encode) ~= 'function' then
		print('^3[QBX Admin]^0 json library missing; Discord audits disabled.')
	end
end)

local function jobExists(name)
	local ok, res = pcall(function() return exports['qbx_core']:GetJob(name) end)
	return ok and res ~= nil
end

local function gangExists(name)
	local ok, res = pcall(function() return exports['qbx_core']:GetGang(name) end)
	return ok and res ~= nil
end

-- Money Management
RegisterNetEvent('QBXAdmin:GiveMoney')
AddEventHandler('QBXAdmin:GiveMoney', function(targetId, account, amount)
	local src = source
	if not hasActionPerm(src, 'money') then
		notifyAdmin(src, "You don't have permission to manage money", "error")
		return
	end

	if not canProceed(src) then
		notifyAdmin(src, "Slow down a sec (rate limited).", "error")
		return
	end

	if not validPlayer(targetId) then
		notifyAdmin(src, "Player not found", "error")
		return
	end

	if src == tonumber(targetId) then
		notifyAdmin(src, "You can't target yourself with this action.", "error")
		return
	end

	account = sanitizeAccount(account)
	amount = sanitizeAmount(amount)
	if not account or not amount then
		notifyAdmin(src, "Invalid account or amount", "error")
		return
	end

	local targetPlayer = getLivePlayer(targetId)
	if not targetPlayer then
		notifyAdmin(src, "Player not found (disconnected?)", "error")
		return
	end

	local success = targetPlayer.Functions.AddMoney(account, amount, "Admin gave money")
	if success then
		local adminName = GetPlayerName(src) or ('['..tostring(src)..']')
		local targetName = GetPlayerName(targetId) or ('['..tostring(targetId)..']')

		notifyAdmin(src, ("Gave $%d %s to %s"):format(amount, account, targetName), "success")

		TriggerClientEvent('ox_lib:notify', targetId, {
			title = 'Money Received',
			description = ("You received $%d %s from an admin"):format(amount, account),
			type = "success",
			duration = 5000
		})

		print(("[QBX Admin] %s -> %s: +$%d %s"):format(adminName, targetName, amount, account))

		sendAudit("Money Given", 
			("**Admin:** %s %s\n**Target:** %s %s\n**Amount:** $%d %s"):format(
				adminName, idLine(src), targetName, idLine(targetId), amount, account
			), 3066993, 'money')
	else
		notifyAdmin(src, "Failed to give money", "error")
	end
end)

-- Legacy bridge
RegisterNetEvent('EasyAdmin:QBX:GiveMoney')
AddEventHandler('EasyAdmin:QBX:GiveMoney', function(targetId, account, amount)
	TriggerEvent('QBXAdmin:GiveMoney', targetId, account, amount)
end)

RegisterNetEvent('QBXAdmin:RemoveMoney')
AddEventHandler('QBXAdmin:RemoveMoney', function(targetId, account, amount)
	local src = source
	if not hasActionPerm(src, 'money') then
		notifyAdmin(src, "You don't have permission to manage money", "error")
		return
	end

	if not canProceed(src) then
		notifyAdmin(src, "Slow down a sec (rate limited).", "error")
		return
	end

	if not validPlayer(targetId) then
		notifyAdmin(src, "Player not found", "error")
		return
	end

	if src == tonumber(targetId) then
		notifyAdmin(src, "You can't target yourself with this action.", "error")
		return
	end

	account = sanitizeAccount(account)
	amount = sanitizeAmount(amount)
	if not account or not amount then
		notifyAdmin(src, "Invalid account or amount", "error")
		return
	end

	local targetPlayer = getLivePlayer(targetId)
	if not targetPlayer then
		notifyAdmin(src, "Player not found (disconnected?)", "error")
		return
	end

	local currentMoney = (targetPlayer.PlayerData.money and targetPlayer.PlayerData.money[account]) or 0
	if currentMoney < amount then
		notifyAdmin(src, ("Player only has $%d %s"):format(currentMoney, account), "error")
		return
	end

	local success = targetPlayer.Functions.RemoveMoney(account, amount, "Admin removed money")
	if success then
		local adminName = GetPlayerName(src) or ('['..tostring(src)..']')
		local targetName = GetPlayerName(targetId) or ('['..tostring(targetId)..']')

		notifyAdmin(src, ("Removed $%d %s from %s"):format(amount, account, targetName), "success")

		TriggerClientEvent('ox_lib:notify', targetId, {
			title = 'Money Removed',
			description = ("$%d %s was removed by an admin"):format(amount, account),
			type = "error",
			duration = 5000
		})

		print(("[QBX Admin] %s -> %s: -$%d %s"):format(adminName, targetName, amount, account))

		sendAudit("Money Removed", 
			("**Admin:** %s %s\n**Target:** %s %s\n**Amount:** $%d %s"):format(
				adminName, idLine(src), targetName, idLine(targetId), amount, account
			), 15158332, 'money')
	else
		notifyAdmin(src, "Failed to remove money", "error")
	end
end)

RegisterNetEvent('EasyAdmin:QBX:RemoveMoney')
AddEventHandler('EasyAdmin:QBX:RemoveMoney', function(targetId, account, amount)
	TriggerEvent('QBXAdmin:RemoveMoney', targetId, account, amount)
end)

RegisterNetEvent('QBXAdmin:SetMoney')
AddEventHandler('QBXAdmin:SetMoney', function(targetId, account, amount)
	local src = source
	if not hasActionPerm(src, 'money') then
		notifyAdmin(src, "You don't have permission to manage money", "error")
		return
	end

	if not canProceed(src) then
		notifyAdmin(src, "Slow down a sec (rate limited).", "error")
		return
	end

	if not validPlayer(targetId) then
		notifyAdmin(src, "Player not found", "error")
		return
	end

	if src == tonumber(targetId) then
		notifyAdmin(src, "You can't target yourself with this action.", "error")
		return
	end

	account = sanitizeAccount(account)
	amount = sanitizeAmount(amount)
	if not account or not amount then
		notifyAdmin(src, "Invalid account or amount", "error")
		return
	end

	local targetPlayer = getLivePlayer(targetId)
	if not targetPlayer then
		notifyAdmin(src, "Player not found (disconnected?)", "error")
		return
	end

	local currentMoney = (targetPlayer.PlayerData.money and targetPlayer.PlayerData.money[account]) or 0
	local difference = amount - currentMoney

	local success = true
	if difference > 0 then
		success = targetPlayer.Functions.AddMoney(account, difference, "Admin set money")
	elseif difference < 0 then
		success = targetPlayer.Functions.RemoveMoney(account, math.abs(difference), "Admin set money")
	end

	if success then
		local adminName = GetPlayerName(src) or ('['..tostring(src)..']')
		local targetName = GetPlayerName(targetId) or ('['..tostring(targetId)..']')

		notifyAdmin(src, ("Set %s's %s to $%d"):format(targetName, account, amount), "success")

		TriggerClientEvent('ox_lib:notify', targetId, {
			title = 'Money Set',
			description = ("Your %s was set to $%d by an admin"):format(account, amount),
			type = "info",
			duration = 5000
		})

		print(("[QBX Admin] %s -> %s: %s = $%d (was $%d)"):format(adminName, targetName, account, amount, currentMoney))

		sendAudit("Money Set", 
			("**Admin:** %s %s\n**Target:** %s %s\n**Account:** %s\n**Amount:** $%d (was $%d)"):format(
				adminName, idLine(src), targetName, idLine(targetId), account, amount, currentMoney
			), 3447003, 'money')
	else
		notifyAdmin(src, "Failed to set money", "error")
	end
end)

RegisterNetEvent('EasyAdmin:QBX:SetMoney')
AddEventHandler('EasyAdmin:QBX:SetMoney', function(targetId, account, amount)
	TriggerEvent('QBXAdmin:SetMoney', targetId, account, amount)
end)

-- Job Management
RegisterNetEvent('QBXAdmin:SetJob')
AddEventHandler('QBXAdmin:SetJob', function(targetId, jobName)
	local src = source
	if not hasActionPerm(src, 'job') then
		notifyAdmin(src, "You don't have permission to manage jobs", "error")
		return
	end

	if not canProceed(src) then
		notifyAdmin(src, "Slow down a sec (rate limited).", "error")
		return
	end

	if not validPlayer(targetId) then
		notifyAdmin(src, "Player not found", "error")
		return
	end

	if src == tonumber(targetId) then
		notifyAdmin(src, "You can't target yourself with this action.", "error")
		return
	end

	if type(jobName) ~= 'string' or jobName == '' then
		notifyAdmin(src, "Invalid job", "error")
		return
	end

	if not jobExists(jobName) then
		notifyAdmin(src, "Job does not exist", "error")
		return
	end

	local targetPlayer = getLivePlayer(targetId)
	if not targetPlayer then
		notifyAdmin(src, "Player not found (disconnected?)", "error")
		return
	end

	local ok, ret = pcall(function() 
		return targetPlayer.Functions.SetJob(jobName, 0)
	end)

	if ok and (ret == nil or ret == true) then
		local adminName = GetPlayerName(src) or ('['..tostring(src)..']')
		local targetName = GetPlayerName(targetId) or ('['..tostring(targetId)..']')

		notifyAdmin(src, ("Set %s's job to %s"):format(targetName, jobName), "success")

		TriggerClientEvent('ox_lib:notify', targetId, {
			title = 'Job Changed',
			description = ("Your job was changed to %s by an admin"):format(jobName),
			type = "info",
			duration = 5000
		})

		print(("[QBX Admin] %s -> %s: job = %s"):format(adminName, targetName, jobName))

		sendAudit("Job Changed", 
			("**Admin:** %s %s\n**Target:** %s %s\n**Job:** %s"):format(
				adminName, idLine(src), targetName, idLine(targetId), jobName
			), 3447003, 'job')
	else
		notifyAdmin(src, "Failed to set job", "error")
	end
end)

RegisterNetEvent('EasyAdmin:QBX:SetJob')
AddEventHandler('EasyAdmin:QBX:SetJob', function(targetId, jobName)
	TriggerEvent('QBXAdmin:SetJob', targetId, jobName)
end)

RegisterNetEvent('QBXAdmin:SetJobGrade')
AddEventHandler('QBXAdmin:SetJobGrade', function(targetId, grade)
	local src = source
	if not hasActionPerm(src, 'job') then
		notifyAdmin(src, "You don't have permission to manage jobs", "error")
		return
	end

	if not canProceed(src) then
		notifyAdmin(src, "Slow down a sec (rate limited).", "error")
		return
	end

	if not validPlayer(targetId) then
		notifyAdmin(src, "Player not found", "error")
		return
	end

	if src == tonumber(targetId) then
		notifyAdmin(src, "You can't target yourself with this action.", "error")
		return
	end

	grade = tonumber(grade)
	if not grade or grade < 0 then
		notifyAdmin(src, "Invalid grade", "error")
		return
	end

	local maxGrade = MAX_JOB_GRADE
	local tp = getLivePlayer(targetId)
	if tp and tp.PlayerData and tp.PlayerData.job and tp.PlayerData.job.grade and tp.PlayerData.job.grade.level then
		maxGrade = tp.PlayerData.job.grade.level or MAX_JOB_GRADE
	end
	grade = math.min(grade, maxGrade)

	local targetPlayer = getLivePlayer(targetId)
	if not targetPlayer or not targetPlayer.PlayerData or not targetPlayer.PlayerData.job then
		notifyAdmin(src, "Player or job not found", "error")
		return
	end

	local currentJob = targetPlayer.PlayerData.job.name
	local ok, ret = pcall(function()
		return targetPlayer.Functions.SetJob(currentJob, grade)
	end)

	if ok and (ret == nil or ret == true) then
		local adminName = GetPlayerName(src) or ('['..tostring(src)..']')
		local targetName = GetPlayerName(targetId) or ('['..tostring(targetId)..']')

		notifyAdmin(src, ("Set %s's job grade to %d"):format(targetName, grade), "success")

		TriggerClientEvent('ox_lib:notify', targetId, {
			title = 'Job Grade Changed',
			description = ("Your job grade was changed to %d by an admin"):format(grade),
			type = "info",
			duration = 5000
		})

		print(("[QBX Admin] %s -> %s: %s grade = %d"):format(adminName, targetName, currentJob, grade))

		sendAudit("Job Grade Changed", 
			("**Admin:** %s %s\n**Target:** %s %s\n**Job:** %s\n**Grade:** %d"):format(
				adminName, idLine(src), targetName, idLine(targetId), currentJob, grade
			), 3447003, 'job')
	else
		notifyAdmin(src, "Failed to set job grade", "error")
	end
end)

RegisterNetEvent('EasyAdmin:QBX:SetJobGrade')
AddEventHandler('EasyAdmin:QBX:SetJobGrade', function(targetId, grade)
	TriggerEvent('QBXAdmin:SetJobGrade', targetId, grade)
end)

RegisterNetEvent('QBXAdmin:ToggleDuty')
AddEventHandler('QBXAdmin:ToggleDuty', function(targetId)
	local src = source
	if not hasActionPerm(src, 'job') then
		notifyAdmin(src, "You don't have permission to manage jobs", "error")
		return
	end

	if not canProceed(src) then
		notifyAdmin(src, "Slow down a sec (rate limited).", "error")
		return
	end

	if not validPlayer(targetId) then
		notifyAdmin(src, "Player not found", "error")
		return
	end

	if src == tonumber(targetId) then
		notifyAdmin(src, "You can't target yourself with this action.", "error")
		return
	end

	local targetPlayer = getLivePlayer(targetId)
	if not targetPlayer or not targetPlayer.PlayerData or not targetPlayer.PlayerData.job then
		notifyAdmin(src, "Player or job not found", "error")
		return
	end

	local currentDuty = targetPlayer.PlayerData.job.onduty == true
	local newState = not currentDuty

	local ok, ret = pcall(function()
		return targetPlayer.Functions.SetDuty(newState)
	end)

	if ok and (ret == nil or ret == true) then
		local adminName = GetPlayerName(src) or ('['..tostring(src)..']')
		local targetName = GetPlayerName(targetId) or ('['..tostring(targetId)..']')
		local dutyStatus = newState and "on duty" or "off duty"

		notifyAdmin(src, ("Set %s %s"):format(targetName, dutyStatus), "success")

		TriggerClientEvent('ox_lib:notify', targetId, {
			title = 'Duty Status Changed',
			description = ("You are now %s"):format(dutyStatus),
			type = "info",
			duration = 5000
		})

		print(("[QBX Admin] %s -> %s: duty = %s"):format(adminName, targetName, dutyStatus))

		sendAudit("Duty Status Changed", 
			("**Admin:** %s %s\n**Target:** %s %s\n**Status:** %s"):format(
				adminName, idLine(src), targetName, idLine(targetId), dutyStatus
			), 3447003, 'job')
	else
		notifyAdmin(src, "Failed to toggle duty", "error")
	end
end)

RegisterNetEvent('EasyAdmin:QBX:ToggleDuty')
AddEventHandler('EasyAdmin:QBX:ToggleDuty', function(targetId)
	TriggerEvent('QBXAdmin:ToggleDuty', targetId)
end)

-- Gang Management
RegisterNetEvent('QBXAdmin:SetGang')
AddEventHandler('QBXAdmin:SetGang', function(targetId, gangName)
	local src = source
	if not hasActionPerm(src, 'gang') then
		notifyAdmin(src, "You don't have permission to manage gangs", "error")
		return
	end

	if not canProceed(src) then
		notifyAdmin(src, "Slow down a sec (rate limited).", "error")
		return
	end

	if not validPlayer(targetId) then
		notifyAdmin(src, "Player not found", "error")
		return
	end

	if src == tonumber(targetId) then
		notifyAdmin(src, "You can't target yourself with this action.", "error")
		return
	end

	if type(gangName) ~= 'string' or gangName == '' then
		notifyAdmin(src, "Invalid gang", "error")
		return
	end

	if not gangExists(gangName) then
		notifyAdmin(src, "Gang does not exist", "error")
		return
	end

	local targetPlayer = getLivePlayer(targetId)
	if not targetPlayer then
		notifyAdmin(src, "Player not found (disconnected?)", "error")
		return
	end

	local ok, ret = pcall(function()
		return targetPlayer.Functions.SetGang(gangName, 0)
	end)

	if ok and (ret == nil or ret == true) then
		local adminName = GetPlayerName(src) or ('['..tostring(src)..']')
		local targetName = GetPlayerName(targetId) or ('['..tostring(targetId)..']')

		notifyAdmin(src, ("Set %s's gang to %s"):format(targetName, gangName), "success")

		TriggerClientEvent('ox_lib:notify', targetId, {
			title = 'Gang Changed',
			description = ("Your gang was changed to %s by an admin"):format(gangName),
			type = "info",
			duration = 5000
		})

		print(("[QBX Admin] %s -> %s: gang = %s"):format(adminName, targetName, gangName))

		sendAudit("Gang Changed", 
			("**Admin:** %s %s\n**Target:** %s %s\n**Gang:** %s"):format(
				adminName, idLine(src), targetName, idLine(targetId), gangName
			), 15105570, 'gang')
	else
		notifyAdmin(src, "Failed to set gang", "error")
	end
end)

RegisterNetEvent('EasyAdmin:QBX:SetGang')
AddEventHandler('EasyAdmin:QBX:SetGang', function(targetId, gangName)
	TriggerEvent('QBXAdmin:SetGang', targetId, gangName)
end)

RegisterNetEvent('QBXAdmin:SetGangGrade')
AddEventHandler('QBXAdmin:SetGangGrade', function(targetId, grade)
	local src = source
	if not hasActionPerm(src, 'gang') then
		notifyAdmin(src, "You don't have permission to manage gangs", "error")
		return
	end

	if not canProceed(src) then
		notifyAdmin(src, "Slow down a sec (rate limited).", "error")
		return
	end

	if not validPlayer(targetId) then
		notifyAdmin(src, "Player not found", "error")
		return
	end

	if src == tonumber(targetId) then
		notifyAdmin(src, "You can't target yourself with this action.", "error")
		return
	end

	grade = tonumber(grade)
	if not grade or grade < 0 then
		notifyAdmin(src, "Invalid grade", "error")
		return
	end

	local maxG = MAX_GANG_GRADE
	local tp2 = getLivePlayer(targetId)
	if tp2 and tp2.PlayerData and tp2.PlayerData.gang and tp2.PlayerData.gang.grade and tp2.PlayerData.gang.grade.level then
		maxG = tp2.PlayerData.gang.grade.level or MAX_GANG_GRADE
	end
	grade = math.min(grade, maxG)

	local targetPlayer = getLivePlayer(targetId)
	if not targetPlayer or not targetPlayer.PlayerData or not targetPlayer.PlayerData.gang then
		notifyAdmin(src, "Player or gang not found", "error")
		return
	end

	local currentGang = targetPlayer.PlayerData.gang.name
	local ok, ret = pcall(function()
		return targetPlayer.Functions.SetGang(currentGang, grade)
	end)

	if ok and (ret == nil or ret == true) then
		local adminName = GetPlayerName(src) or ('['..tostring(src)..']')
		local targetName = GetPlayerName(targetId) or ('['..tostring(targetId)..']')

		notifyAdmin(src, ("Set %s's gang grade to %d"):format(targetName, grade), "success")

		TriggerClientEvent('ox_lib:notify', targetId, {
			title = 'Gang Grade Changed',
			description = ("Your gang grade was changed to %d by an admin"):format(grade),
			type = "info",
			duration = 5000
		})

		print(("[QBX Admin] %s -> %s: %s grade = %d"):format(adminName, targetName, currentGang, grade))

		sendAudit("Gang Grade Changed", 
			("**Admin:** %s %s\n**Target:** %s %s\n**Gang:** %s\n**Grade:** %d"):format(
				adminName, idLine(src), targetName, idLine(targetId), currentGang, grade
			), 15105570, 'gang')
	else
		notifyAdmin(src, "Failed to set gang grade", "error")
	end
end)

RegisterNetEvent('EasyAdmin:QBX:SetGangGrade')
AddEventHandler('EasyAdmin:QBX:SetGangGrade', function(targetId, grade)
	TriggerEvent('QBXAdmin:SetGangGrade', targetId, grade)
end)

-- Player Information
RegisterNetEvent('QBXAdmin:GetPlayerInfo')
AddEventHandler('QBXAdmin:GetPlayerInfo', function(targetId)
	local src = source
	if not hasActionPerm(src, 'info') then
		notifyAdmin(src, "You don't have permission to view player info", "error")
		return
	end

	if not canProceed(src) then
		notifyAdmin(src, "Slow down a sec (rate limited).", "error")
		return
	end

	if not validPlayer(targetId) then
		notifyAdmin(src, "Player not found", "error")
		return
	end

	local targetPlayer = getLivePlayer(targetId)
	if not targetPlayer or not targetPlayer.PlayerData then
		notifyAdmin(src, "Player not found (disconnected?)", "error")
		return
	end

	local playerData = targetPlayer.PlayerData
	local job = playerData.job or {}
	local gang = playerData.gang or {}
	local money = playerData.money or {}

	local info = {
		name = GetPlayerName(targetId) or ('['..tostring(targetId)..']'),
		citizenid = playerData.citizenid or "unknown",
		job = job.name or "unemployed",
		jobGrade = (job.grade and job.grade.level) or 0,
		jobDuty = job.onduty == true,
		gang = gang.name or "none",
		gangGrade = (gang.grade and gang.grade.level) or 0,
		money = {
			cash = money.cash or 0,
			bank = money.bank or 0
		}
	}

	TriggerClientEvent('QBXAdmin:ReceivePlayerInfo', src, info)

	local adminName = GetPlayerName(src) or ('['..tostring(src)..']')
	print(("[QBX Admin] %s requested info for %s (%s)"):format(adminName, info.name, tostring(playerData.citizenid)))
end)

RegisterNetEvent('EasyAdmin:QBX:GetPlayerInfo')
AddEventHandler('EasyAdmin:QBX:GetPlayerInfo', function(targetId)
	TriggerEvent('QBXAdmin:GetPlayerInfo', targetId)
end)

-- ===== Health Management Events =====
-- Perms used (add to ACE): easyadmin.qbx.heal, easyadmin.qbx.revive
-- Optional webhook override:
local WEBHOOK_HEALTH = GetConvar('qbx_admin_webhook_health', DISCORD_WEBHOOK)

local function sendHealthAudit(title, description, color)
	local webhook = (WEBHOOK_HEALTH and WEBHOOK_HEALTH ~= '') and WEBHOOK_HEALTH or DISCORD_WEBHOOK
	if not webhook or webhook == "" then return end
	if type(json) ~= "table" or type(json.encode) ~= "function" then
		print("[QBX Admin] Warning: json.encode not available, skipping Discord audit")
		return
	end
	PerformHttpRequest(webhook, function() end, 'POST', json.encode({
		username = "QBX Admin",
		embeds = {{
			title = title,
			description = description,
			color = color or 10181046, -- purple-ish
			timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
		}}
	}), { ['Content-Type'] = 'application/json' })
end

RegisterNetEvent('QBXAdmin:Heal')
AddEventHandler('QBXAdmin:Heal', function(targetId)
	local src = source
	if not hasActionPerm(src, 'heal') then
		notifyAdmin(src, "You don't have permission to heal", "error")
		return
	end
	if not canProceed(src) then
		notifyAdmin(src, "Slow down a sec (rate limited).", "error")
		return
	end

	-- Allow self-heal if no target or "me" behavior:
	targetId = tonumber(targetId) or src
	if not validPlayer(targetId) then
		notifyAdmin(src, "Player not found", "error")
		return
	end

	-- Do NOT block self on health actions (unlike money/job)
	TriggerClientEvent('QBXAdmin:Client:Heal', targetId)

	local adminName  = GetPlayerName(src) or ('['..tostring(src)..']')
	local targetName = GetPlayerName(targetId) or ('['..tostring(targetId)..']')
	notifyAdmin(src, ("Healed %s"):format(targetName), "success")

	-- Tell target
	if src ~= targetId then
		TriggerClientEvent('ox_lib:notify', targetId, {
			title = 'Healed',
			description = ("An admin healed you"):format(),
			type = "success",
			duration = 4000
		})
	end

	print(("[QBX Admin] %s healed %s"):format(adminName, targetName))
	sendHealthAudit("Heal",
		("**Admin:** %s %s\n**Target:** %s %s"):format(adminName, idLine(src), targetName, idLine(targetId)),
		3066993 -- green
	)
end)

RegisterNetEvent('EasyAdmin:QBX:Heal')
AddEventHandler('EasyAdmin:QBX:Heal', function(targetId)
	TriggerEvent('QBXAdmin:Heal', targetId)
end)

RegisterNetEvent('QBXAdmin:Revive')
AddEventHandler('QBXAdmin:Revive', function(targetId)
	local src = source
	if not hasActionPerm(src, 'revive') then
		notifyAdmin(src, "You don't have permission to revive", "error")
		return
	end
	if not canProceed(src) then
		notifyAdmin(src, "Slow down a sec (rate limited).", "error")
		return
	end

	targetId = tonumber(targetId) or src
	if not validPlayer(targetId) then
		notifyAdmin(src, "Player not found", "error")
		return
	end

	-- If you use a medical script, call its revive instead of the generic one:
	-- TriggerClientEvent('hospital:client:Revive', targetId)          -- qb-ambulancejob (old)
	-- TriggerClientEvent('qbx_ambulancejob:client:revive', targetId)  -- new/qbx variant (adjust to your resource)
	TriggerClientEvent('QBXAdmin:Client:Revive', targetId)

	local adminName  = GetPlayerName(src) or ('['..tostring(src)..']')
	local targetName = GetPlayerName(targetId) or ('['..tostring(targetId)..']')
	notifyAdmin(src, ("Revived %s"):format(targetName), "success")

	if src ~= targetId then
		TriggerClientEvent('ox_lib:notify', targetId, {
			title = 'Revived',
			description = ("An admin revived you"),
			type = "success",
			duration = 4000
		})
	end

	print(("[QBX Admin] %s revived %s"):format(adminName, targetName))
	sendHealthAudit("Revive",
		("**Admin:** %s %s\n**Target:** %s %s"):format(adminName, idLine(src), targetName, idLine(targetId)),
		3447003 -- blue
	)
end)

RegisterNetEvent('EasyAdmin:QBX:Revive')
AddEventHandler('EasyAdmin:QBX:Revive', function(targetId)
	TriggerEvent('QBXAdmin:Revive', targetId)
end)



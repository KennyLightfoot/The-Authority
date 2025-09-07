-- EasyAdmin QBX Integration Plugin - Client Side
-- Custom plugin for QBX framework integration with EasyAdmin

-- Configuration
local RATE_MS = 750 -- Rate limiting in milliseconds

-- Rate limiting
local lastAction = 0
local function canActNow()
	local now = GetGameTimer()
	if (now - lastAction) < RATE_MS then return false end
	lastAction = now
	return true
end

-- lib / ox_lib availability checks
local function hasLib()
	return GetResourceState('ox_lib') == 'started' and lib ~= nil
end

-- Notifications
local function showNotification(message, type)
	type = type or "info"
	if hasLib() and lib.notify then
		lib.notify({
			title = 'QBX Admin',
			description = tostring(message),
			type = type,
			duration = 5000
		})
	else
		BeginTextCommandThefeedPost('STRING')
		AddTextComponentSubstringPlayerName(tostring(message))
		EndTextCommandThefeedPostTicker(false, false)
	end
end

-- Convert server id -> client player index (or -1 if offline)
local function getPlayerIndexFromServerId(sid)
	sid = tonumber(sid)
	if not sid then return -1 end
	local idx = GetPlayerFromServerId(sid)
	return idx or -1
end

-- Small helper to prompt for target if not supplied
local function ensureTargetId(targetId)
	targetId = tonumber(targetId)
	-- Relaxed check: accept any positive number (server will validate)
	if targetId and targetId > 0 then return targetId end

	if not hasLib() or not lib.inputDialog then
		showNotification('ox_lib required to prompt for a target id.', 'error')
		return nil
	end

	local resp = lib.inputDialog('Target Player', {
		{ type = 'number', label = 'Server ID', min = 1, required = true }
	})
	if not resp or not resp[1] then return nil end

	local sid = tonumber(resp[1])
	if not sid or sid < 1 then
		showNotification('Invalid target id.', 'error')
		return nil
	end
	return sid
end

-- ===== Money Management =====
local function giveMoney(targetId)
	if not canActNow() then return showNotification("Slow down a sec (rate limited).", "error") end
	targetId = ensureTargetId(targetId); if not targetId then return end
	if not hasLib() or not lib.inputDialog then
		showNotification('ox_lib required for this action.', 'error'); return
	end
	local account = lib.inputDialog('Give Money', {
		{ type = 'select', label = 'Account', options = {
			{label='Cash', value='cash'}, {label='Bank', value='bank'}
		}, required = true },
		{ type = 'number', label = 'Amount', min = 1, max = 1000000, required = true }
	})
	if account and account[1] and account[2] then
		TriggerServerEvent('EasyAdmin:QBX:GiveMoney', targetId, account[1], tonumber(account[2]))
	end
end

local function removeMoney(targetId)
	if not canActNow() then return showNotification("Slow down a sec (rate limited).", "error") end
	targetId = ensureTargetId(targetId); if not targetId then return end
	if not hasLib() or not lib.inputDialog then
		showNotification('ox_lib required for this action.', 'error'); return
	end
	local account = lib.inputDialog('Remove Money', {
		{ type = 'select', label = 'Account', options = {
			{label='Cash', value='cash'}, {label='Bank', value='bank'}
		}, required = true },
		{ type = 'number', label = 'Amount', min = 1, max = 1000000, required = true }
	})
	if account and account[1] and account[2] then
		TriggerServerEvent('EasyAdmin:QBX:RemoveMoney', targetId, account[1], tonumber(account[2]))
	end
end

local function setMoney(targetId)
	if not canActNow() then return showNotification("Slow down a sec (rate limited).", "error") end
	targetId = ensureTargetId(targetId); if not targetId then return end
	if not hasLib() or not lib.inputDialog then
		showNotification('ox_lib required for this action.', 'error'); return
	end
	local account = lib.inputDialog('Set Money', {
		{ type = 'select', label = 'Account', options = {
			{label='Cash', value='cash'}, {label='Bank', value='bank'}
		}, required = true },
		{ type = 'number', label = 'Amount', min = 1, max = 1000000, required = true }
	})
	if account and account[1] and account[2] then
		TriggerServerEvent('EasyAdmin:QBX:SetMoney', targetId, account[1], tonumber(account[2]))
	end
end

-- ===== Job Management =====
local function setJob(targetId)
	if not canActNow() then return showNotification("Slow down a sec (rate limited).", "error") end
	targetId = ensureTargetId(targetId); if not targetId then return end
	if not hasLib() or not lib.inputDialog then
		showNotification('ox_lib required for this action.', 'error'); return
	end
	local job = lib.inputDialog('Set Job', {
		{ type = 'input', label = 'Job Name', placeholder = 'police, ambulance, mechanic, etc.', required = true }
	})
	if job and job[1] then
		TriggerServerEvent('EasyAdmin:QBX:SetJob', targetId, job[1])
	end
end

local function setJobGrade(targetId)
	if not canActNow() then return showNotification("Slow down a sec (rate limited).", "error") end
	targetId = ensureTargetId(targetId); if not targetId then return end
	if not hasLib() or not lib.inputDialog then
		showNotification('ox_lib required for this action.', 'error'); return
	end
	local grade = lib.inputDialog('Set Job Grade', {
		{ type = 'number', label = 'Grade', min = 0, max = 10, required = true }
	})
	if grade and grade[1] then
		TriggerServerEvent('EasyAdmin:QBX:SetJobGrade', targetId, tonumber(grade[1]))
	end
end

local function toggleDuty(targetId)
	if not canActNow() then return showNotification("Slow down a sec (rate limited).", "error") end
	targetId = ensureTargetId(targetId); if not targetId then return end
	TriggerServerEvent('EasyAdmin:QBX:ToggleDuty', targetId)
end

-- ===== Gang Management =====
local function setGang(targetId)
	if not canActNow() then return showNotification("Slow down a sec (rate limited).", "error") end
	targetId = ensureTargetId(targetId); if not targetId then return end
	if not hasLib() or not lib.inputDialog then
		showNotification('ox_lib required for this action.', 'error'); return
	end
	local gang = lib.inputDialog('Set Gang', {
		{ type = 'input', label = 'Gang Name', placeholder = 'ballas, vagos, etc.', required = true }
	})
	if gang and gang[1] then
		TriggerServerEvent('EasyAdmin:QBX:SetGang', targetId, gang[1])
	end
end

local function setGangGrade(targetId)
	if not canActNow() then return showNotification("Slow down a sec (rate limited).", "error") end
	targetId = ensureTargetId(targetId); if not targetId then return end
	if not hasLib() or not lib.inputDialog then
		showNotification('ox_lib required for this action.', 'error'); return
	end
	local grade = lib.inputDialog('Set Gang Grade', {
		{ type = 'number', label = 'Grade', min = 0, max = 10, required = true }
	})
	if grade and grade[1] then
		TriggerServerEvent('EasyAdmin:QBX:SetGangGrade', targetId, tonumber(grade[1]))
	end
end

-- ===== Player Info =====
local function getPlayerInfo(targetId)
	if not canActNow() then return showNotification("Slow down a sec (rate limited).", "error") end
	targetId = ensureTargetId(targetId); if not targetId then return end
	TriggerServerEvent('EasyAdmin:QBX:GetPlayerInfo', targetId)
end

-- Receive player info
RegisterNetEvent('EasyAdmin:QBX:ReceivePlayerInfo', function(info)
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
			centered = true,
			cancel = false
		})
	else
		local message = string.format(
			"Player: %s\nCitizen ID: %s\nJob: %s (Grade %d) - %s\nGang: %s (Grade %d)\nMoney: $%d cash, $%d bank",
			tostring(info.name),
			tostring(info.citizenid),
			tostring(info.job),
			tonumber(info.jobGrade or 0),
			info.jobDuty and "On Duty" or "Off Duty",
			tostring(info.gang),
			tonumber(info.gangGrade or 0),
			tonumber(info.money.cash or 0),
			tonumber(info.money.bank or 0)
		)
		showNotification(message, "info")
	end
end)

-- ===== EasyAdmin integration =====
RegisterCommand('easyadmin_qbx_givemoney', function(_, args) giveMoney(args[1]) end, true)
RegisterCommand('easyadmin_qbx_removemoney', function(_, args) removeMoney(args[1]) end, true)
RegisterCommand('easyadmin_qbx_setmoney', function(_, args) setMoney(args[1]) end, true)

RegisterCommand('easyadmin_qbx_setjob', function(_, args) setJob(args[1]) end, true)
RegisterCommand('easyadmin_qbx_setjobgrade', function(_, args) setJobGrade(args[1]) end, true)
RegisterCommand('easyadmin_qbx_toggleduty', function(_, args) toggleDuty(args[1]) end, true)

RegisterCommand('easyadmin_qbx_setgang', function(_, args) setGang(args[1]) end, true)
RegisterCommand('easyadmin_qbx_setganggrade', function(_, args) setGangGrade(args[1]) end, true)

RegisterCommand('easyadmin_qbx_playerinfo', function(_, args) getPlayerInfo(args[1]) end, true)

-- ===== Context Menu (Optional UX Enhancement) =====
local function showTargetMenu(targetId)
	targetId = ensureTargetId(targetId)
	if not targetId then return end

	if not hasLib() or not lib.registerContext then
		showNotification('ox_lib context menu not available.', 'error')
		return
	end

	local idx = getPlayerIndexFromServerId(targetId)
	local playerName = (idx ~= -1 and GetPlayerName(idx)) or "Unknown"

	lib.registerContext({
		id = 'qbx_admin_menu',
		title = ('Admin Actions - %s (ID: %d)'):format(playerName, targetId),
		options = {
			{
				title = '💰 Money Management',
				description = 'Give, remove, or set money',
				icon = 'dollar-sign',
				menu = 'qbx_money_menu'
			},
			{
				title = '💼 Job Management',
				description = 'Set job, grade, or toggle duty',
				icon = 'briefcase',
				menu = 'qbx_job_menu'
			},
			{
				title = '🔫 Gang Management',
				description = 'Set gang or gang grade',
				icon = 'users',
				menu = 'qbx_gang_menu'
			},
			{
				title = 'ℹ️ Player Info',
				description = 'View detailed player information',
				icon = 'info',
				onSelect = function() getPlayerInfo(targetId) end
			}
		}
	})

	lib.registerContext({
		id = 'qbx_money_menu',
		title = 'Money Management',
		menu = 'qbx_admin_menu',
		options = {
			{ title = 'Give Money',   description = 'Add money to player account',   icon = 'plus',   onSelect = function() giveMoney(targetId) end },
			{ title = 'Remove Money', description = 'Remove money from player account', icon = 'minus', onSelect = function() removeMoney(targetId) end },
			{ title = 'Set Money',    description = 'Set exact amount of money',     icon = 'equals', onSelect = function() setMoney(targetId) end }
		}
	})

	lib.registerContext({
		id = 'qbx_job_menu',
		title = 'Job Management',
		menu = 'qbx_admin_menu',
		options = {
			{ title = 'Set Job',       description = 'Change player job',        icon = 'briefcase', onSelect = function() setJob(targetId) end },
			{ title = 'Set Job Grade', description = 'Change player job grade',  icon = 'star',      onSelect = function() setJobGrade(targetId) end },
			{ title = 'Toggle Duty',   description = 'Toggle player duty status',icon = 'clock',     onSelect = function() toggleDuty(targetId) end }
		}
	})

	lib.registerContext({
		id = 'qbx_gang_menu',
		title = 'Gang Management',
		menu = 'qbx_admin_menu',
		options = {
			{ title = 'Set Gang',       description = 'Change player gang',       icon = 'users', onSelect = function() setGang(targetId) end },
			{ title = 'Set Gang Grade', description = 'Change player gang grade', icon = 'crown', onSelect = function() setGangGrade(targetId) end }
		}
	})

	lib.showContext('qbx_admin_menu')
end

-- ===== Quick Target Convenience =====
local function RotAnglesToVec(rot)
	local z = math.rad(rot.z)
	local x = math.rad(rot.x)
	local num = math.abs(math.cos(x))
	return vec3(-math.sin(z) * num, math.cos(z) * num, math.sin(x))
end

local function getAimedServerId()
	local cam = GetGameplayCamCoord()
	local dir = RotAnglesToVec(GetGameplayCamRot(2))
	local from = cam
	local to = vec3(cam.x + dir.x * 10.0, cam.y + dir.y * 10.0, cam.z + dir.z * 10.0)
	local ray = StartShapeTestRay(from.x, from.y, from.z, to.x, to.y, to.z, 8, -1, 0)
	local hit, _, entity, _, _ = GetShapeTestResult(ray)
	if hit == 1 and IsPedAPlayer(entity) then
		return GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))
	end
end

RegisterCommand('easyadmin_qbx_menu', function(_, args) showTargetMenu(args[1]) end, true)

RegisterCommand('easyadmin_qbx_menu_aim', function()
	local sid = getAimedServerId()
	if sid then 
		showTargetMenu(sid) 
	else 
		showNotification('Aim at a player first.', 'error') 
	end
end, true)

-- ===== Chat Suggestions =====
if GetResourceState('chat') == 'started' then
	TriggerEvent('chat:addSuggestion', '/easyadmin_qbx_givemoney', 'Give money to a player', { { name = 'serverId', help = 'Target player server ID (optional; prompts if omitted)' } })
	TriggerEvent('chat:addSuggestion', '/easyadmin_qbx_removemoney', 'Remove money from a player', { { name = 'serverId', help = 'Target player server ID (optional; prompts if omitted)' } })
	TriggerEvent('chat:addSuggestion', '/easyadmin_qbx_setmoney', 'Set exact amount of money for a player', { { name = 'serverId', help = 'Target player server ID (optional; prompts if omitted)' } })
	TriggerEvent('chat:addSuggestion', '/easyadmin_qbx_setjob', 'Set a player\'s job', { { name = 'serverId', help = 'Target player server ID (optional; prompts if omitted)' } })
	TriggerEvent('chat:addSuggestion', '/easyadmin_qbx_setjobgrade', 'Set a player\'s job grade', { { name = 'serverId', help = 'Target player server ID (optional; prompts if omitted)' } })
	TriggerEvent('chat:addSuggestion', '/easyadmin_qbx_toggleduty', 'Toggle a player\'s duty status', { { name = 'serverId', help = 'Target player server ID (optional; prompts if omitted)' } })
	TriggerEvent('chat:addSuggestion', '/easyadmin_qbx_setgang', 'Set a player\'s gang', { { name = 'serverId', help = 'Target player server ID (optional; prompts if omitted)' } })
	TriggerEvent('chat:addSuggestion', '/easyadmin_qbx_setganggrade', 'Set a player\'s gang grade', { { name = 'serverId', help = 'Target player server ID (optional; prompts if omitted)' } })
	TriggerEvent('chat:addSuggestion', '/easyadmin_qbx_playerinfo', 'View detailed player information', { { name = 'serverId', help = 'Target player server ID (optional; prompts if omitted)' } })
	TriggerEvent('chat:addSuggestion', '/easyadmin_qbx_menu', 'Open admin context menu for a player', { { name = 'serverId', help = 'Target player server ID (optional; prompts if omitted)' } })
	TriggerEvent('chat:addSuggestion', '/easyadmin_qbx_menu_aim', 'Open admin context menu for aimed-at player', { { name = '', help = 'Aim at a player and use this command' } })
end

AddEventHandler('onResourceStop', function(res)
	if res ~= GetCurrentResourceName() or GetResourceState('chat') ~= 'started' then return end
	for _, cmd in ipairs({
		'easyadmin_qbx_givemoney','easyadmin_qbx_removemoney','easyadmin_qbx_setmoney',
		'easyadmin_qbx_setjob','easyadmin_qbx_setjobgrade','easyadmin_qbx_toggleduty',
		'easyadmin_qbx_setgang','easyadmin_qbx_setganggrade','easyadmin_qbx_playerinfo',
		'easyadmin_qbx_menu','easyadmin_qbx_menu_aim'
	}) do
		TriggerEvent('chat:removeSuggestion', '/'..cmd)
	end
end)

-- Keybinds
RegisterKeyMapping('easyadmin_qbx_givemoney',    'QBX: Give Money',    'keyboard', '')
RegisterKeyMapping('easyadmin_qbx_removemoney',  'QBX: Remove Money',  'keyboard', '')
RegisterKeyMapping('easyadmin_qbx_setmoney',     'QBX: Set Money',     'keyboard', '')
RegisterKeyMapping('easyadmin_qbx_setjob',       'QBX: Set Job',       'keyboard', '')
RegisterKeyMapping('easyadmin_qbx_setjobgrade',  'QBX: Set Job Grade', 'keyboard', '')
RegisterKeyMapping('easyadmin_qbx_toggleduty',   'QBX: Toggle Duty',   'keyboard', '')
RegisterKeyMapping('easyadmin_qbx_setgang',      'QBX: Set Gang',      'keyboard', '')
RegisterKeyMapping('easyadmin_qbx_setganggrade', 'QBX: Set Gang Grade','keyboard', '')
RegisterKeyMapping('easyadmin_qbx_playerinfo',   'QBX: Player Info',   'keyboard', '')
RegisterKeyMapping('easyadmin_qbx_menu',         'QBX: Admin Menu',    'keyboard', '')
RegisterKeyMapping('easyadmin_qbx_menu_aim',     'QBX: Admin Menu (Aim)', 'keyboard', '')

-- Exports
exports('giveMoney', giveMoney)
exports('removeMoney', removeMoney)
exports('setMoney', setMoney)
exports('setJob', setJob)
exports('setJobGrade', setJobGrade)
exports('toggleDuty', toggleDuty)
exports('setGang', setGang)
exports('setGangGrade', setGangGrade)
exports('getPlayerInfo', getPlayerInfo)
exports('showTargetMenu', showTargetMenu)

print("[QBX Admin] Client integration loaded successfully!")



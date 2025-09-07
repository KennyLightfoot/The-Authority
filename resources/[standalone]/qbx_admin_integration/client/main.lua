-- QBX Admin Integration - Client Side
-- This integrates QBX features with EasyAdmin

-- Wait for ox_lib to be ready
Citizen.CreateThread(function()
    while not lib do
        Citizen.Wait(100)
    end
    
    print("[QBX Admin] Client integration loaded successfully!")
end)

-- Money Management Dialogs
RegisterNetEvent('qbx_admin:openMoneyDialog', function(action)
    local account = lib.inputDialog(('Give Money'):format(action), {
        {type = 'select', label = 'Account', options = {
            {label = 'Cash', value = 'cash'},
            {label = 'Bank', value = 'bank'}
        }, required = true},
        {type = 'number', label = 'Amount', min = 1, max = 1000000, required = true}
    })
    
    if account and account[1] and account[2] then
        TriggerServerEvent('EasyAdmin:QBX:GiveMoney', GetPlayerServerId(PlayerId()), account[1], account[2])
    end
end)

-- Job Management Dialogs
RegisterNetEvent('qbx_admin:openJobDialog', function()
    local job = lib.inputDialog('Set Job', {
        {type = 'input', label = 'Job Name', placeholder = 'police, ambulance, mechanic, etc.', required = true}
    })
    
    if job and job[1] then
        TriggerServerEvent('EasyAdmin:QBX:SetJob', GetPlayerServerId(PlayerId()), job[1])
    end
end)

RegisterNetEvent('qbx_admin:openJobGradeDialog', function()
    local grade = lib.inputDialog('Set Job Grade', {
        {type = 'number', label = 'Grade', min = 0, max = 10, required = true}
    })
    
    if grade and grade[1] then
        TriggerServerEvent('EasyAdmin:QBX:SetJobGrade', GetPlayerServerId(PlayerId()), grade[1])
    end
end)

-- Gang Management Dialogs
RegisterNetEvent('qbx_admin:openGangDialog', function()
    local gang = lib.inputDialog('Set Gang', {
        {type = 'input', label = 'Gang Name', placeholder = 'ballas, vagos, etc.', required = true}
    })
    
    if gang and gang[1] then
        TriggerServerEvent('EasyAdmin:QBX:SetGang', GetPlayerServerId(PlayerId()), gang[1])
    end
end)

RegisterNetEvent('qbx_admin:openGangGradeDialog', function()
    local grade = lib.inputDialog('Set Gang Grade', {
        {type = 'number', label = 'Grade', min = 0, max = 10, required = true}
    })
    
    if grade and grade[1] then
        TriggerServerEvent('EasyAdmin:QBX:SetGangGrade', GetPlayerServerId(PlayerId()), grade[1])
    end
end)

-- Receive player info from server
RegisterNetEvent('EasyAdmin:QBX:ReceivePlayerInfo', function(info)
    local message = string.format(
        "Player: %s\nCitizen ID: %s\nJob: %s (Grade %d) - %s\nGang: %s (Grade %d)\nMoney: $%d cash, $%d bank",
        info.name,
        info.citizenid,
        info.job,
        info.jobGrade,
        info.jobDuty and "On Duty" or "Off Duty",
        info.gang,
        info.gangGrade,
        info.money.cash,
        info.money.bank
    )
    
    lib.alertDialog({
        header = 'Player Information',
        content = message,
        centered = true,
        size = 'lg'
    })
end)

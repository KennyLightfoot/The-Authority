-- luacheck: globals exports GetResourceState RegisterNetEvent NetworkGetEntityFromNetworkId lib source

local bank = exports['Renewed-Banking']
local vehicleKeys = exports.qbx_vehiclekeys

local function chargeAccount(account, amount, title, message)
    if GetResourceState('Renewed-Banking') ~= 'started' then
        return false, 'banking_not_started'
    end
    if type(account) ~= 'string' or type(amount) ~= 'number' or amount <= 0 then
        return false, 'invalid_parameters'
    end

    local balance = bank:getAccountMoney(account)
    if not balance or balance < amount then
        return false, 'insufficient_funds'
    end

    bank:handleTransaction(account, title or 'Transaction', -amount, message or '', 'system', account, 'withdraw')
    bank:removeAccountMoney(account, amount)
    return true
end

exports('chargeAccount', chargeAccount)

local function giveVehicleKeys(src, vehicle)
    if GetResourceState('qbx_vehiclekeys') ~= 'started' then
        return false, 'vehiclekeys_not_started'
    end
    if not vehicle or vehicle == 0 then
        return false, 'invalid_vehicle'
    end
    vehicleKeys:GiveKeys(src, vehicle)
    return true
end

exports('giveVehicleKeys', giveVehicleKeys)

RegisterNetEvent('authority:giveVehicleKeys', function(netId)
    local src = source
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    giveVehicleKeys(src, vehicle)
end)

print('^2[core]^7 payment and key helpers loaded')


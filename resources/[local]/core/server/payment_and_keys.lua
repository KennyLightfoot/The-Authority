-- luacheck: globals exports GetResourceState RegisterNetEvent NetworkGetEntityFromNetworkId lib source TriggerClientEvent

local bank = exports['Renewed-Banking']
local vehicleKeys = exports.qbx_vehiclekeys
local Sec = exports['authority_security']
local AuthSec = {}
if GetResourceState('authority_security') == 'started' then
    AuthSec.addBank = function(src, amt, reason) return exports['authority_security']:addBank(src, amt, reason) end
    AuthSec.removeBank = function(src, amt, reason) return exports['authority_security']:removeBank(src, amt, reason) end
    AuthSec.giveItem = function(src, item, count) return exports['authority_security']:giveItem(src, item, count) end
    AuthSec.issueToken = function(src, purpose) return exports['authority_security']:issueToken(src, purpose) end
    AuthSec.consumeToken = function(src, purpose, token) return exports['authority_security']:consumeToken(src, purpose, token) end
    AuthSec.getShopItemPrice = function(shop, item, qty) return exports['authority_security']:getShopItemPrice(shop, item, qty) end
    AuthSec.getPayout = function(job, item, qty) return exports['authority_security']:getPayout(job, item, qty) end
    AuthSec.getTaxes = function() return exports['authority_security']:getTaxes() end
end

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

-- Secure token issuers
if GetResourceState('authority_security') == 'started' then
    if lib and lib.callback then
        lib.callback.register('authority:token:shop', function(src)
            return AuthSec.issueToken(src, 'shop')
        end)
        lib.callback.register('authority:token:payout', function(src)
            return AuthSec.issueToken(src, 'payout')
        end)
    end

    -- Secure shop purchase
    RegisterNetEvent('authority:shop:buy', function(shop, item, qty, token)
        local src = source
        local ok, why = AuthSec.consumeToken(src, 'shop', token)
        if not ok then return TriggerClientEvent('ox_lib:notify', src, { type='error', description='Invalid token '..(why or '') }) end

        local total, err, meta = AuthSec.getShopItemPrice(shop, item, qty)
        if not total then return TriggerClientEvent('ox_lib:notify', src, { type='error', description='Invalid purchase '..(err or '') }) end

        if meta and meta.requires and meta.requires.license == 'firearm' and not HasLicense(src, 'firearm') then
            return TriggerClientEvent('ox_lib:notify', src, { type='error', description='License required' })
        end

        local salesTax = Sec and Sec.getSalesTax and Sec:getSalesTax() or 0
        local grand = math.floor(total + (total * salesTax))

        local removed, rerr = AuthSec.removeBank(src, grand, ('shop:%s'):format(shop))
        if not removed then return TriggerClientEvent('ox_lib:notify', src, { type='error', description='Payment failed: '..(rerr or '') }) end

        local okItem = AuthSec.giveItem(src, item, qty)
        if not okItem then
            AuthSec.addBank(src, grand, 'refund_shop_fail')
            return TriggerClientEvent('ox_lib:notify', src, { type='error', description='Delivery failed; refunded' })
        end

        if GetResourceState('audit_logs') == 'started' then
            exports['audit_logs']:write(src, 'shop_buy', {
                shop = shop, item = item, qty = qty, subtotal = total, sales_tax = salesTax, total = grand,
                price_version = Sec and Sec.getCatalogVersion and Sec:getCatalogVersion() or nil,
            })
        end
        TriggerClientEvent('ox_lib:notify', src, { type='success', description=('Purchased %sx %s'):format(qty, item) })
    end)

    -- Secure job payout
    RegisterNetEvent('authority:job:payout', function(job, itemCounts, token)
        local src = source
        local ok, why = AuthSec.consumeToken(src, 'payout', token)
        if not ok then return end

        local total = 0
        for item, qty in pairs(itemCounts or {}) do
            local p = AuthSec.getPayout(job, item, qty)
            if p then total = total + p end
        end
        total = math.floor(total)
        if total <= 0 then return end

        AuthSec.addBank(src, total, ('payout:%s'):format(job))
        if GetResourceState('audit_logs') == 'started' then
            exports['audit_logs']:write(src, 'job_payout', {
                job = job, total = total, items = itemCounts,
                price_version = Sec and Sec.getCatalogVersion and Sec:getCatalogVersion() or nil,
            })
        end
        TriggerClientEvent('ox_lib:notify', src, { type='success', description=('Payout $%d'):format(total) })
    end)
end


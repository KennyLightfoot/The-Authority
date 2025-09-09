-- Simple Delivery Job Client
-- Placeholder implementation for The Authority

print('^2[qb-delivery]^7 Simple delivery job client loaded (placeholder)')

-- Simple delivery job command for testing
RegisterCommand('startdelivery', function()
    lib.notify({
        title = 'Delivery Job',
        description = 'Simple delivery job placeholder - use /testdelivery to simulate completion',
        type = 'inform',
        duration = 5000
    })
end, false)

-- Test delivery completion
RegisterCommand('testdelivery', function()
    lib.notify({
        title = 'Delivery Complete',
        description = 'Simulating delivery completion...',
        type = 'success',
        duration = 3000
    })
    
    -- Tokenized payout: request token then trigger secure payout
    local payload = { package = 1, distance_km = 1.0 }
    lib.callback('authority:token:payout', false, function(tok)
        if not tok then
            lib.notify({ type = 'error', description = 'Payout token failed' })
            return
        end
        TriggerServerEvent('authority:job:payout', 'delivery', payload, tok)
    end)
end, false)













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
    
    -- Trigger server event
    TriggerServerEvent('qb-delivery:server:completedDelivery', 'package', 1000)
end, false)










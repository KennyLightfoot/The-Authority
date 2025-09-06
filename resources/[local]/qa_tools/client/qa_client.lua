-- QA Tools Client
-- Provides client-side testing tools

RegisterCommand('qa:notify', function(source, args, rawCommand)
    -- Test ox_lib notification system
    local message = table.concat(args, ' ') or 'QA notification test'
    
    lib.notify({
        title = 'QA Test',
        description = message,
        type = 'success',
        duration = 5000,
        position = 'top'
    })
    
    print('^2[QA Tools]^7 Notification test sent: ' .. message)
end, false)

RegisterCommand('qa:coords', function(source, args, rawCommand)
    -- Get player coordinates for testing
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    
    local coordsText = string.format('X: %.2f, Y: %.2f, Z: %.2f, H: %.2f', coords.x, coords.y, coords.z, heading)
    
    lib.notify({
        title = 'Current Coordinates',
        description = coordsText,
        type = 'inform',
        duration = 10000
    })
    
    -- Also copy to clipboard if possible
    lib.setClipboard(string.format('vector4(%.2f, %.2f, %.2f, %.2f)', coords.x, coords.y, coords.z, heading))
    
    print('^2[QA Tools]^7 Coordinates: ' .. coordsText)
end, false)

RegisterCommand('qa:vehicle', function(source, args, rawCommand)
    -- Test vehicle information
    local ped = PlayerPedId()
    
    if IsPedInAnyVehicle(ped, false) then
        local vehicle = GetVehiclePedIsIn(ped, false)
        local model = GetEntityModel(vehicle)
        local modelName = GetDisplayNameFromVehicleModel(model)
        local plate = GetVehicleNumberPlateText(vehicle)
        local netId = NetworkGetNetworkIdFromEntity(vehicle)
        
        local vehicleInfo = string.format('Model: %s, Plate: %s, NetID: %d', modelName, plate, netId)
        
        lib.notify({
            title = 'Vehicle Information',
            description = vehicleInfo,
            type = 'inform',
            duration = 8000
        })
        
        print('^2[QA Tools]^7 Vehicle info: ' .. vehicleInfo)
    else
        lib.notify({
            title = 'Vehicle Test',
            description = 'You are not in a vehicle',
            type = 'warning',
            duration = 3000
        })
    end
end, false)

print('^2[QA Tools]^7 Client-side QA tools loaded! Use /qa:notify, /qa:coords, /qa:vehicle')


local shared = require 'shared.main'

-- Vehicles API (server-side) to mirror client exports
local function GetVehiclesByName(key)
    local vehicles = shared.Vehicles
    return key and vehicles[key] or vehicles
end

local function GetVehiclesByHash(key)
    local vehicleHashes = shared.VehicleHashes
    return key and vehicleHashes[key] or vehicleHashes
end

local function GetVehiclesByCategory()
    return qbx.table.mapBySubfield(shared.Vehicles, 'category')
end

exports('GetVehiclesByName', GetVehiclesByName)
exports('GetVehiclesByHash', GetVehiclesByHash)
exports('GetVehiclesByCategory', GetVehiclesByCategory)


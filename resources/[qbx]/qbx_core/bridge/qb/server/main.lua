if GetConvar('qbx:enablebridge', 'true') == 'false' then return end

local qbCoreCompat = {}
qbCoreCompat.Shared = require 'bridge.qb.shared.main'
qbCoreCompat.Functions = require 'bridge.qb.server.functions'

local createQbExport = require 'bridge.qb.shared.export-function'

createQbExport('GetCoreObject', function()
    return qbCoreCompat
end)


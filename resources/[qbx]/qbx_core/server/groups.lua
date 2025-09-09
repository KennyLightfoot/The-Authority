-- Server-side callbacks for group data expected by clients

local function getGroups()
    local jobs = require 'shared.jobs'
    local gangs = require 'shared.gangs'
    return { jobs = jobs, gangs = gangs }
end

lib.callback.register('qbx_core:server:getGroups', function(_source)
    return getGroups()
end)

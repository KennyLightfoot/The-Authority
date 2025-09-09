-- Apartments Client
-- Handles apartment interactions and UI

local currentApartment = nil
local apartmentBlips = {}

-- Create apartment blips
local function CreateApartmentBlips()
    for _, apartment in ipairs(Config.Apartments) do
        local blip = AddBlipForCoord(apartment.spawn.x, apartment.spawn.y, apartment.spawn.z)
        SetBlipSprite(blip, apartment.blip.sprite)
        SetBlipColour(blip, apartment.blip.color)
        SetBlipScale(blip, apartment.blip.scale)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(apartment.name)
        EndTextCommandSetBlipName(blip)
        
        apartmentBlips[apartment.id] = blip
    end
end

-- Show apartment selection menu
RegisterNetEvent('apartments:client:showSelection', function()
    local options = {}
    
    for _, apartment in ipairs(Config.Apartments) do
        table.insert(options, {
            title = apartment.name,
            description = apartment.description,
            icon = 'home',
            onSelect = function()
                TriggerServerEvent('apartments:server:spawnPlayer', apartment.id)
            end
        })
    end
    
    lib.registerContext({
        id = 'apartment_selection',
        title = 'Choose Your Apartment',
        options = options
    })
    
    lib.showContext('apartment_selection')
end)

-- Spawn player in apartment
RegisterNetEvent('apartments:client:spawnInApartment', function(apartment)
    currentApartment = apartment
    
    -- Handle screen fade for spawn
    DoScreenFadeOut(500)
    while not IsScreenFadedOut() do
        Wait(0)
    end
    
    -- Set player position
    local ped = PlayerPedId()
    SetEntityCoords(ped, apartment.spawn.x, apartment.spawn.y, apartment.spawn.z, false, false, false, true)
    SetEntityHeading(ped, apartment.spawn.w)
    
    -- Wait a moment for positioning
    Wait(1000)
    
    -- Fade back in
    DoScreenFadeIn(500)
    while not IsScreenFadedIn() do
        Wait(0)
    end
    
    -- Close loading screen if still open
    pcall(function()
        if ShutdownLoadingScreenNui then ShutdownLoadingScreenNui() end
    end)

    -- Create interaction points
    CreateApartmentInteractions(apartment)
    
    -- Trigger player loaded events
    TriggerServerEvent('QBCore:Server:OnPlayerLoaded')
    TriggerEvent('QBCore:Client:OnPlayerLoaded')
    
    lib.notify({
        title = 'Welcome Home',
        description = 'You are now in your apartment',
        type = 'success',
        duration = 3000
    })
end)

-- Create interaction points in apartment
function CreateApartmentInteractions(apartment)
    -- Stash interaction
    exports.ox_target:addBoxZone({
        coords = apartment.stash,
        size = vec3(1.5, 1.5, 2),
        rotation = 0,
        debug = false,
        options = {
            {
                name = 'apartment_stash',
                icon = 'fas fa-box',
                label = 'Open Storage',
                onSelect = function()
                    TriggerServerEvent('apartments:server:openStash', apartment.id)
                end
            }
        }
    })
    
    -- Wardrobe interaction
    exports.ox_target:addBoxZone({
        coords = apartment.wardrobe,
        size = vec3(1.5, 1.5, 2),
        rotation = 0,
        debug = false,
        options = {
            {
                name = 'apartment_wardrobe',
                icon = 'fas fa-tshirt',
                label = 'Open Wardrobe',
                onSelect = function()
                    TriggerServerEvent('apartments:server:openWardrobe', apartment.id)
                end
            }
        }
    })
    
    -- Logout interaction
    exports.ox_target:addBoxZone({
        coords = apartment.logout,
        size = vec3(2, 2, 2),
        rotation = 0,
        debug = false,
        options = {
            {
                name = 'apartment_logout',
                icon = 'fas fa-sign-out-alt',
                label = 'Logout',
                onSelect = function()
                    lib.alertDialog({
                        header = 'Logout',
                        content = 'Are you sure you want to logout?',
                        centered = true,
                        cancel = true,
                        labels = {
                            confirm = 'Yes, Logout',
                            cancel = 'Cancel'
                        }
                    }, function(confirmed)
                        if confirmed then
                            TriggerServerEvent('apartments:server:logout')
                        end
                    end)
                end
            }
        }
    })
end

-- Initialize when resource starts
CreateThread(function()
    Wait(1000) -- Wait for other resources to load
    CreateApartmentBlips()
    
    -- Request apartment assignment on spawn
    TriggerServerEvent('apartments:server:selectApartment')
end)

-- Command to go home (for testing)
RegisterCommand('gohome', function()
    if currentApartment then
        local ped = PlayerPedId()
        SetEntityCoords(ped, currentApartment.spawn.x, currentApartment.spawn.y, currentApartment.spawn.z, false, false, false, true)
        SetEntityHeading(ped, currentApartment.spawn.w)
        
        lib.notify({
            title = 'Teleported Home',
            description = 'You have been teleported to your apartment',
            type = 'success',
            duration = 3000
        })
    else
        lib.notify({
            title = 'No Apartment',
            description = 'You do not have an apartment assigned',
            type = 'error',
            duration = 3000
        })
    end
end, false)

print('^2[Apartments]^7 Client-side apartment system loaded!')


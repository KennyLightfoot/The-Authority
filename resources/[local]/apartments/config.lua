Config = {}

-- Apartment locations and configurations
Config.Apartments = {
    {
        id = 'downtown_apt_1',
        name = 'Downtown Apartment A',
        description = 'A cozy apartment in the heart of the city',
        spawn = vector4(-1447.81, -538.32, 34.74, 33.5),
        stash = vector3(-1457.65, -530.82, 34.74),
        wardrobe = vector3(-1449.85, -549.25, 34.74),
        logout = vector3(-1447.81, -538.32, 34.74),
        blip = {
            sprite = 475,
            color = 3,
            scale = 0.8
        }
    },
    {
        id = 'vinewood_apt_1',
        name = 'Vinewood Hills Apartment',
        description = 'A luxurious apartment with a great view',
        spawn = vector4(-174.35, 497.73, 137.67, 184.5),
        stash = vector3(-174.22, 493.06, 137.67),
        wardrobe = vector3(-177.09, 508.73, 137.67),
        logout = vector3(-174.35, 497.73, 137.67),
        blip = {
            sprite = 475,
            color = 5,
            scale = 0.8
        }
    },
    {
        id = 'sandy_apt_1',
        name = 'Sandy Shores Apartment',
        description = 'A quiet apartment away from the city noise',
        spawn = vector4(1973.01, 3815.48, 33.44, 297.5),
        stash = vector3(1967.73, 3815.99, 33.44),
        wardrobe = vector3(1972.06, 3821.49, 33.44),
        logout = vector3(1973.01, 3815.48, 33.44),
        blip = {
            sprite = 475,
            color = 2,
            scale = 0.8
        }
    }
}

-- Stash configuration
Config.StashSize = {
    slots = 50,
    weight = 100000 -- 100kg
}

-- Wardrobe configuration
Config.WardrobeSlots = 10


local helpers = {}
local _cargoPlatformZ = -0.03

helpers.getCargoAreaInner4x4BoundingInfo = function()
    return {
        bbMax = { 1.9, 1.9, 5 },
        bbMin = { -1.9, -1.9, 0 },
    }
end

helpers.getCargoAreaInner4x4Collider = function()
    return {
        params = {
            halfExtents = { 1.9, 1.9, 2.7, },
        },
        transf = { 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 2.3, 1, },
        type = 'BOX',
    }
end

helpers.getCargoAreaInner4x4Lods = function(isAddRoof)
    local _materials = { 'street/new_medium_sidewalk.mtl', 'street/new_medium_sidewalk.mtl' }
    return {
        {
            node = {
                children = {
                    {
                        materials = _materials,
                        mesh = 'lollo_lorry_station/tarmac_4x4.msh',
                        transf = { 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, -2, -2, _cargoPlatformZ, 1, },
                    },
                    isAddRoof and {
                        materials = { 'lollo_lorry_station/power_pole.mtl' },
                        mesh = 'lollo_lorry_station/cargo_roof_grid_4x4.msh',
                        transf = { 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, -2, -2, _cargoPlatformZ, 1, },
                    } or nil,
                },
                name = 'RootNode',
                transf = { 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, },
            },
            static = false,
            visibleFrom = 0,
            visibleTo = 1000,
        },
    }
end

helpers.getCargoAreaInner4x4EarthLods = function(isAddRoof)
    return {
        {
            node = {
                children = {
                    {
                        materials = { 'street/new_medium_sidewalk.mtl' },
                        mesh = 'lollo_lorry_station/tyre-tracks-4x4x03.msh',
                        transf = { 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, -2, -2, _cargoPlatformZ, 1, },
                    },
                    isAddRoof and {
                        materials = { 'lollo_lorry_station/power_pole.mtl' },
                        mesh = 'lollo_lorry_station/cargo_roof_grid_4x4.msh',
                        transf = { 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, -2, -2, _cargoPlatformZ, 1, },
                    } or nil,
                },
                name = 'RootNode',
                transf = { 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, },
            },
            static = false,
            visibleFrom = 0,
            visibleTo = 1000,
        },
    }
end

helpers.getCargoAreaInner4x4GravelLods = function(isAddRoof)
    return {
        {
            node = {
                children = {
                    {
                        materials = { 'street/new_medium_sidewalk.mtl' },
                        mesh = 'lollo_lorry_station/tyre-tracks-4x4x03.msh',
                        transf = { 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, -2, -2, _cargoPlatformZ, 1, },
                    },
                    isAddRoof and {
                        materials = { 'lollo_lorry_station/power_pole.mtl' },
                        mesh = 'lollo_lorry_station/cargo_roof_grid_4x4.msh',
                        transf = { 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, -2, -2, _cargoPlatformZ, 1, },
                    } or nil,
                },
                name = 'RootNode',
                transf = { 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, },
            },
            static = false,
            visibleFrom = 0,
            visibleTo = 1000,
        },
    }
end

helpers.getCargoAreaInner4x4Metadata = function()
    local _cargoNodeZ = 0.3
    return {
        transportNetworkProvider = {
            laneLists = {
                {
                    linkable = true, -- false, --true,
                    nodes = {
                        {
                            { 2, 0, _cargoNodeZ }, -- edge 0
                            { -4, 0, 0 },
                            3,
                        },
                        {
                            { -2, 0, _cargoNodeZ },
                            { -4, 0, 0 },
                            3,
                        },
                        -- lanes across 1
                        {
                            { 1.8, 2, _cargoNodeZ }, -- edge 1
                            { 0.2, -2, 0 },
                            3,
                        },
                        {
                            { 2, 0, _cargoNodeZ },
                            { 0.2, -2, 0 },
                            3,
                        },
                        {
                            { 2, 0, _cargoNodeZ }, -- edge 2
                            { -0.2, -2, 0 },
                            3,
                        },
                        {
                            { 1.8, -2, _cargoNodeZ },
                            { -0.2, -2, 0 },
                            3,
                        },
                        -- lanes across 2
                        {
                            { -1.8, -2, _cargoNodeZ }, -- edge 3
                            { -0.2, 2, 0 },
                            3,
                        },
                        {
                            { -2, 0, _cargoNodeZ },
                            { -0.2, 2, 0 },
                            3,
                        },
                        {
                            { -2, 0, _cargoNodeZ }, -- edge 10
                            { 0.2, 2, 0 },
                            3,
                        },
                        {
                            { -1.8, 2, _cargoNodeZ },
                            { 0.2, 2, 0 },
                            3,
                        },
                    },
                    transportModes = { 'CARGO', },
                    speedLimit = 30,
                },
            },
            runways = { },
            terminals = {
                {
                    -- order = 0,
                    personEdges = { 0 },
                    personNodes = { 0, 1 },
                    -- vehicleNode = -1, -- 0,
                },
            },
        },
    }
end

helpers.getCargoLinks4x4Metadata = function()
    local result = helpers.getCargoAreaInner4x4Metadata()
    result.transportNetworkProvider.terminals = {
        {
            -- order = 0,
            -- personEdges = { 0 },
            personEdges = { },
            -- personNodes = { 0, 1 },
            personNodes = { },
            -- vehicleNode = -1, -- 0,
        },
    }
    return result
end

helpers.getVoidBoundingInfo = function()
    return {} -- this seems the same as the following
    -- return {
    --     bbMax = { 0, 0, 0 },
    --     bbMin = { 0, 0, 0 },
    -- }
end

helpers.getVoidCollider = function()
    -- return {
    --     params = {
    --         halfExtents = { 0, 0, 0, },
    --     },
    --     transf = { 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, },
    --     type = 'BOX',
    -- }
    return {
        type = 'NONE'
    }
end

helpers.getCargoLinksEnhanced4x4Lods = function()
    return {
        {
            node = {
                children = {
                    {
                        materials = { 'lollo_lorry_station/links_enhanced.mtl' },
                        mesh = 'lollo_lorry_station/lollo4x4.msh',
                        transf = { 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, -2, -2, _cargoPlatformZ, 1, },
                    },
                    {
                        materials = { 'street/new_medium_sidewalk.mtl' },
                        mesh = 'lollo_lorry_station/tyre-tracks-4x4x01.msh',
                        transf = { 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, -2, -2, -0.00, 1, },
                    },
                },
                name = 'RootNode',
                transf = { 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, },
            },
            static = false,
            visibleFrom = 0,
            visibleTo = 100,
        },
    }
end

helpers.getCargoLinks4x4Lods = function()
    return {
        {
            node = {
                children = {
                    {
                        materials = { 'street/new_medium_sidewalk.mtl' },
                        mesh = 'lollo_lorry_station/tyre-tracks-4x4x01.msh',
                        transf = { 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, -2, -2, -0.00, 1, },
                    },
                },
                name = 'RootNode',
                transf = { 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, },
            },
            static = false,
            visibleFrom = 0,
            visibleTo = 100,
        },
    }
end

helpers.getCargoAreaInner12x12BoundingInfo = function()
    return {
        bbMax = { 5.9, 5.9, 5 },
        bbMin = { -5.9, -5.9, 0 },
    }
end

helpers.getCargoAreaInner12x12Collider = function()
    return {
        params = {
            halfExtents = { 5.9, 5.9, 2.7, },
        },
        transf = { 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 2.3, 1, },
        type = 'BOX',
    }
end

helpers.getCargoAreaInner12x12Lods = function(isAddRoof)
    local _materials = { 'street/new_medium_sidewalk.mtl', 'street/new_medium_sidewalk.mtl' }
    return {
        {
            node = {
                children = {
                    {
                        materials = _materials,
                        mesh = 'lollo_lorry_station/tarmac_12x12.msh',
                        transf = { 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, -6, -6, _cargoPlatformZ, 1, },
                    },
                    isAddRoof and {
                        materials = { 'lollo_lorry_station/power_pole.mtl' },
                        mesh = 'lollo_lorry_station/cargo_roof_grid_4x4.msh',
                        transf = { 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, -6, 2, _cargoPlatformZ, 1, },
                    } or nil,
                    isAddRoof and {
                        materials = { 'lollo_lorry_station/power_pole.mtl' },
                        mesh = 'lollo_lorry_station/cargo_roof_grid_4x4.msh',
                        transf = { 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, -2, 2, _cargoPlatformZ, 1, },
                    } or nil,
                    isAddRoof and {
                        materials = { 'lollo_lorry_station/power_pole.mtl' },
                        mesh = 'lollo_lorry_station/cargo_roof_grid_4x4.msh',
                        transf = { 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 2, 2, _cargoPlatformZ, 1, },
                    } or nil,
                },
                name = 'RootNode',
                transf = { 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, },
            },
            static = false,
            visibleFrom = 0,
            visibleTo = 1000,
        },
    }
end

helpers.getCargoAreaInner12x12EarthLods = function(isAddRoof)
    return {
        {
            node = {
                children = {
                    isAddRoof and {
                        materials = { 'lollo_lorry_station/power_pole.mtl' },
                        mesh = 'lollo_lorry_station/cargo_roof_grid_4x4.msh',
                        transf = { 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, -6, 2, _cargoPlatformZ, 1, },
                    } or nil,
                    isAddRoof and {
                        materials = { 'lollo_lorry_station/power_pole.mtl' },
                        mesh = 'lollo_lorry_station/cargo_roof_grid_4x4.msh',
                        transf = { 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, -2, 2, _cargoPlatformZ, 1, },
                    } or nil,
                    isAddRoof and {
                        materials = { 'lollo_lorry_station/power_pole.mtl' },
                        mesh = 'lollo_lorry_station/cargo_roof_grid_4x4.msh',
                        transf = { 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 2, 2, _cargoPlatformZ, 1, },
                    } or nil,
                    {
                        materials = { 'street/new_medium_sidewalk.mtl' },
                        mesh = 'lollo_lorry_station/tyre-tracks-4x4x03.msh',
                        transf = { 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, -6, -6, _cargoPlatformZ, 1, },
                    },
                    {
                        materials = { 'street/new_medium_sidewalk.mtl' },
                        mesh = 'lollo_lorry_station/tyre-tracks-4x4x03.msh',
                        transf = { 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, -6, -2, _cargoPlatformZ, 1, },
                    },
                    {
                        materials = { 'street/new_medium_sidewalk.mtl' },
                        mesh = 'lollo_lorry_station/tyre-tracks-4x4x03.msh',
                        transf = { 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, -6, 2, _cargoPlatformZ, 1, },
                    },
                    {
                        materials = { 'street/new_medium_sidewalk.mtl' },
                        mesh = 'lollo_lorry_station/tyre-tracks-4x4x03.msh',
                        transf = { 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, -2, -6, _cargoPlatformZ, 1, },
                    },
                    {
                        materials = { 'street/new_medium_sidewalk.mtl' },
                        mesh = 'lollo_lorry_station/tyre-tracks-4x4x03.msh',
                        transf = { 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, -2, -2, _cargoPlatformZ, 1, },
                    },
                    {
                        materials = { 'street/new_medium_sidewalk.mtl' },
                        mesh = 'lollo_lorry_station/tyre-tracks-4x4x03.msh',
                        transf = { 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, -2, 2, _cargoPlatformZ, 1, },
                    },
                    {
                        materials = { 'street/new_medium_sidewalk.mtl' },
                        mesh = 'lollo_lorry_station/tyre-tracks-4x4x03.msh',
                        transf = { 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 2, -6, _cargoPlatformZ, 1, },
                    },
                    {
                        materials = { 'street/new_medium_sidewalk.mtl' },
                        mesh = 'lollo_lorry_station/tyre-tracks-4x4x03.msh',
                        transf = { 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 2, -2, _cargoPlatformZ, 1, },
                    },
                    {
                        materials = { 'street/new_medium_sidewalk.mtl' },
                        mesh = 'lollo_lorry_station/tyre-tracks-4x4x03.msh',
                        transf = { 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 2, 2, _cargoPlatformZ, 1, },
                    },
                },
                name = 'RootNode',
                transf = { 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, },
            },
            static = false,
            visibleFrom = 0,
            visibleTo = 1000,
        },
    }
end

helpers.getCargoAreaInner12x12GravelLods = function(isAddRoof)
    return {
        {
            node = {
                children = {
                    isAddRoof and {
                        materials = { 'lollo_lorry_station/power_pole.mtl' },
                        mesh = 'lollo_lorry_station/cargo_roof_grid_4x4.msh',
                        transf = { 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, -6, 2, _cargoPlatformZ, 1, },
                    } or nil,
                    isAddRoof and {
                        materials = { 'lollo_lorry_station/power_pole.mtl' },
                        mesh = 'lollo_lorry_station/cargo_roof_grid_4x4.msh',
                        transf = { 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, -2, 2, _cargoPlatformZ, 1, },
                    } or nil,
                    isAddRoof and {
                        materials = { 'lollo_lorry_station/power_pole.mtl' },
                        mesh = 'lollo_lorry_station/cargo_roof_grid_4x4.msh',
                        transf = { 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 2, 2, _cargoPlatformZ, 1, },
                    } or nil,
                    {
                        materials = { 'street/new_medium_sidewalk.mtl' },
                        mesh = 'lollo_lorry_station/tyre-tracks-4x4x03.msh',
                        transf = { 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, -6, -6, _cargoPlatformZ, 1, },
                    },
                    {
                        materials = { 'street/new_medium_sidewalk.mtl' },
                        mesh = 'lollo_lorry_station/tyre-tracks-4x4x03.msh',
                        transf = { 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, -6, -2, _cargoPlatformZ, 1, },
                    },
                    {
                        materials = { 'street/new_medium_sidewalk.mtl' },
                        mesh = 'lollo_lorry_station/tyre-tracks-4x4x03.msh',
                        transf = { 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, -6, 2, _cargoPlatformZ, 1, },
                    },
                    {
                        materials = { 'street/new_medium_sidewalk.mtl' },
                        mesh = 'lollo_lorry_station/tyre-tracks-4x4x03.msh',
                        transf = { 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, -2, -6, _cargoPlatformZ, 1, },
                    },
                    {
                        materials = { 'street/new_medium_sidewalk.mtl' },
                        mesh = 'lollo_lorry_station/tyre-tracks-4x4x03.msh',
                        transf = { 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, -2, -2, _cargoPlatformZ, 1, },
                    },
                    {
                        materials = { 'street/new_medium_sidewalk.mtl' },
                        mesh = 'lollo_lorry_station/tyre-tracks-4x4x03.msh',
                        transf = { 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, -2, 2, _cargoPlatformZ, 1, },
                    },
                    {
                        materials = { 'street/new_medium_sidewalk.mtl' },
                        mesh = 'lollo_lorry_station/tyre-tracks-4x4x03.msh',
                        transf = { 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 2, -6, _cargoPlatformZ, 1, },
                    },
                    {
                        materials = { 'street/new_medium_sidewalk.mtl' },
                        mesh = 'lollo_lorry_station/tyre-tracks-4x4x03.msh',
                        transf = { 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 2, -2, _cargoPlatformZ, 1, },
                    },
                    {
                        materials = { 'street/new_medium_sidewalk.mtl' },
                        mesh = 'lollo_lorry_station/tyre-tracks-4x4x03.msh',
                        transf = { 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 2, 2, _cargoPlatformZ, 1, },
                    },
                },
                name = 'RootNode',
                transf = { 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, },
            },
            static = false,
            visibleFrom = 0,
            visibleTo = 1000,
        },
    }
end

helpers.getCargoAreaInner12x12Metadata = function()
    local _cargoNodeZ = 0.3
    return {
        transportNetworkProvider = {
            laneLists = {
                {
                    linkable = true,
                    nodes = {
                        {
                            { 6, -4, _cargoNodeZ }, -- edge 0
                            { -12, 0, 0 },
                            3,
                        },
                        {
                            { -6, -4, _cargoNodeZ },
                            { -12, 0, 0 },
                            3,
                        },
                        {
                            { 6, 0, _cargoNodeZ }, -- edge 1
                            { -12, 0, 0 },
                            3,
                        },
                        {
                            { -6, 0, _cargoNodeZ },
                            { -12, 0, 0 },
                            3,
                        },
                        {
                            { 6, 4, _cargoNodeZ }, -- edge 2
                            { -12, 0, 0 },
                            3,
                        },
                        {
                            { -6, 4, _cargoNodeZ },
                            { -12, 0, 0 },
                            3,
                        },
                        -- lanes across 1
                        {
                            { 5.8, 6, _cargoNodeZ },
                            { 0.2, -2, 0 },
                            3,
                        },
                        {
                            { 6, 4, _cargoNodeZ },
                            { 0.2, -2, 0 },
                            3,
                        },
                        {
                            { 6, 4, _cargoNodeZ },
                            { -0.2, -2, 0 },
                            3,
                        },
                        {
                            { 5.8, 2, _cargoNodeZ },
                            { -0.2, -2, 0 },
                            3,
                        },
                        {
                            { 5.8, 2, _cargoNodeZ },
                            { 0.2, -2, 0 },
                            3,
                        },
                        {
                            { 6, 0, _cargoNodeZ },
                            { 0.2, -2, 0 },
                            3,
                        },
                        {
                            { 6, 0, _cargoNodeZ },
                            { -0.2, -2, 0 },
                            3,
                        },
                        {
                            { 5.8, -2, _cargoNodeZ },
                            { -0.2, -2, 0 },
                            3,
                        },
                        {
                            { 5.8, -2, _cargoNodeZ },
                            { 0.2, -2, 0 },
                            3,
                        },
                        {
                            { 6, -4, _cargoNodeZ },
                            { 0.2, -2, 0 },
                            3,
                        },
                        {
                            { 6, -4, _cargoNodeZ },
                            { -0.2, -2, 0 },
                            3,
                        },
                        {
                            { 5.8, -6, _cargoNodeZ },
                            { -0.2, -2, 0 },
                            3,
                        },
                        -- lanes across 2
                        {
                            { -5.8, -6, _cargoNodeZ },
                            { -0.2, 2, 0 },
                            3,
                        },
                        {
                            { -6, -4, _cargoNodeZ },
                            { -0.2, 2, 0 },
                            3,
                        },
                        {
                            { -6, -4, _cargoNodeZ },
                            { 0.2, 2, 0 },
                            3,
                        },
                        {
                            { -5.8, -2, _cargoNodeZ },
                            { 0.2, 2, 0 },
                            3,
                        },
                        {
                            { -5.8, -2, _cargoNodeZ },
                            { -0.2, 2, 0 },
                            3,
                        },
                        {
                            { -6, 0, _cargoNodeZ },
                            { -0.2, 2, 0 },
                            3,
                        },
                        {
                            { -6, 0, _cargoNodeZ },
                            { 0.2, 2, 0 },
                            3,
                        },
                        {
                            { -5.8, 2, _cargoNodeZ },
                            { 0.2, 2, 0 },
                            3,
                        },
                        {
                            { -5.8, 2, _cargoNodeZ },
                            { -0.2, 2, 0 },
                            3,
                        },
                        {
                            { -6, 4, _cargoNodeZ },
                            { -0.2, 2, 0 },
                            3,
                        },
                        {
                            { -6, 4, _cargoNodeZ },
                            { 0.2, 2, 0 },
                            3,
                        },
                        {
                            { -5.8, 6, _cargoNodeZ },
                            { 0.2, 2, 0 },
                            3,
                        },
                        -- diagonal lanes to match small cargo area
                        {
                            { -1.8, -6, _cargoNodeZ }, -- edge 33
                            { -4.2, 2, 0 },
                            3,
                        },
                        {
                            { -6, -4, _cargoNodeZ },
                            { -4.2, 2, 0 },
                            3,
                        },
                        {
                            { 6, -4, _cargoNodeZ }, -- edge 34
                            { -4.2, -2, 0 },
                            3,
                        },
                        {
                            { 1.8, -6, _cargoNodeZ },
                            { -4.2, -2, 0 },
                            3,
                        },
                        {
                            { -6, 4, _cargoNodeZ }, -- edge 35
                            { 4.2, 2, 0 },
                            3,
                        },
                        {
                            { -1.8, 6, _cargoNodeZ },
                            { 4.2, 2, 0 },
                            3,
                        },
                        {
                            { 1.8, 6, _cargoNodeZ }, -- edge 36
                            { 4.2, -2, 0 },
                            3,
                        },
                        {
                            { 6, 4, _cargoNodeZ },
                            { 4.2, -2, 0 },
                            3,
                        },
                    },
                    transportModes = { 'CARGO', },
                    speedLimit = 30,
                },

                -- laneutil.createLanes(
                --     generatedData['lanes_terminal'], -- curves
                --     { 'CARGO' }, -- transport means
                --     20, -- max speed
                --     4, -- lane width
                --     true -- linkable
                -- ),
            },
            runways = { },
            terminals = {
                {
                    -- order = 0,
                    personEdges = { 0, 1, 2 },
                    personNodes = { 0, 1, 2, 3, 4, 5 },
                    -- vehicleNode = -1, -- 0,
                },
            },
        },
    }
end

helpers.getAnythingStreetside12x4BoundingInfo = function ()
    return {
        bbMax = { 5.9, 1.9, 5, },
        bbMin = { -5.9, -1.9, 0, },
    }
end

helpers.getAnythingStreetside12x4Collider = function ()
    return {
        params = {
            -- halfExtents = { 5.9, 1.9, 2.7, },
            halfExtents = { 0.9, 1.9, 2.7, },
        },
        transf = { 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 2.3, 1, },
        type = "BOX",
    }
end

helpers.getLaneLists12x4NormalCapacity = function()
    local _cargoNodeZ = 0.3
    return {
        -- on the pavement
        {
            linkable = true, -- LOLLO NOTE this is useful to connect the station to the industry
            nodes = {
                {{ 6, 0, _cargoNodeZ, },{ -12, 0, 0, }, 3}, -- edge 0
                {{ -6, 0, _cargoNodeZ, },{ -12, 0, 0, }, 3},
            },
            speedLimit = 30,
            transportModes = { 'CARGO' },
        },
        -- along the y axis
        {
            linkable = false,
            nodes = {
                {{ 5.8, 2, _cargoNodeZ, }, { 0.2, -2, 0, }, 3},
                {{ 6, 0, _cargoNodeZ, }, { 0.2, -2, 0, }, 3},
                {{ 6, 0, _cargoNodeZ, }, { -0.2, -2, 0, }, 3},
                {{ 5.8, -2, _cargoNodeZ, }, { -0.2, -2, 0, }, 3},
            },
            speedLimit = 30,
            transportModes = { 'CARGO' },
        },
        {
            linkable = false,
            nodes = {
                {{ -5.8, -2, _cargoNodeZ, }, { -0.2, 2, 0, }, 3},
                {{ -6, 0, _cargoNodeZ, }, { -0.2, 2, 0, }, 3},
                {{ -6, 0, _cargoNodeZ, }, { 0.2, 2, 0, }, 3},
                {{ -5.8, 2, _cargoNodeZ, }, { 0.2, 2, 0, }, 3},
            },
            speedLimit = 30,
            transportModes = { 'CARGO' },
        },
        -- diagonals to join up with the 4x4 units
        {
            linkable = false,
            nodes = {
                {{ 1.8, 2, _cargoNodeZ, }, { 4.2, -2, 0, }, 3},
                {{ 6, 0, _cargoNodeZ, }, { 4.2, -2, 0, }, 3},
            },
            speedLimit = 30,
            transportModes = { 'CARGO' },
        },
        {
            linkable = false,
            nodes = {
                {{ -6, 0, _cargoNodeZ, }, { 4.2, 2, 0, }, 3},
                {{ -1.8, 2, _cargoNodeZ, }, { 4.2, 2, 0, }, 3},
            },
            speedLimit = 30,
            transportModes = { 'CARGO' },
        },
        {
            linkable = false,
            nodes = {
                {{ 6, 0, _cargoNodeZ, }, { -4.2, -2, 0, }, 3},
                {{ 1.8, -2, _cargoNodeZ, }, { -4.2, -2, 0, }, 3},
            },
            speedLimit = 30,
            transportModes = { 'CARGO' },
        },
        {
            linkable = false,
            nodes = {
                {{ -1.8, -2, _cargoNodeZ, }, { -4.2, 2, 0, }, 3},
                {{ -6, 0, _cargoNodeZ, }, { -4.2, 2, 0, }, 3}, -- edge 6
            },
            speedLimit = 30,
            transportModes = { 'CARGO' },
        },
    }
end

return helpers

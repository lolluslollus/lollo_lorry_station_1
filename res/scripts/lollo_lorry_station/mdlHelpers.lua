local helpers = {}

helpers.getCargoAreaInner5x5BoundingInfo = function()
    return {
        bbMax = { 2.4, 2.4, 2 },
        bbMin = { -2.4, -2.4, 0 },
    }
end

helpers.getCargoAreaInner5x5Collider = function()
    return {
        params = {
            halfExtents = { 2.4, 2.4, 1.0, },
        },
        transf = { 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, },
        type = 'BOX',
    }
end

helpers.getCargoAreaInner5x5Lods = function()
    local _materials = { 'street/new_medium_sidewalk.mtl', 'street/new_medium_sidewalk.mtl' }
    return {
        {
            node = {
                children = {
                    {
                        materials = _materials,
                        mesh = 'station/road/streetstation/pedestrian_era_c/end_l_lod0.msh',
                        transf = { 0, 2.05, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, -2.5, -2.5, -0.02, 1, },
                    },
                    {
                        materials = _materials,
                        mesh = 'station/road/streetstation/pedestrian_era_c/end_l_lod0.msh',
                        transf = { 0, 2.05, 0, 0, -1, 0, 0, 0, 0, 0, 1, 0, 2.5, -2.5, -0.02, 1, },
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

helpers.getCargoAreaInner5x5EarthLods = function()
    local _materials = { 'lollo_lorry_station/earth.mtl' }
    return {
        {
            node = {
                children = {
                    {
                        materials = _materials,
                        mesh = 'platform/lollo5x5.msh',
                        transf = { 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, -2.5, -2.5, -0.02, 1, },
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

helpers.getCargoLinks5x5 = function()
    return {
        {
            node = {
                -- name = 'RootNode',
                -- transf = { 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, },
            },
            static = false,
            visibleFrom = 0,
            visibleTo = 1000,
        },
    }
end

helpers.getCargoAreaInner5x5GravelLods = function()
    local _materials = { 'lollo_lorry_station/gravel.mtl' }
    return {
        {
            node = {
                children = {
                    {
                        materials = _materials,
                        mesh = 'platform/lollo5x5.msh',
                        transf = { 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, -2.5, -2.5, -0.02, 1, },
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

helpers.getCargoAreaInner5x5Metadata = function()
    local _cargoNodeZ = 0.3
    return {
        transportNetworkProvider = {
            laneLists = {
                {
                    linkable = true, -- false, --true,
                    nodes = {
                        {
                            { 2.50000, -1.25, _cargoNodeZ }, -- edge 0
                            { -0.5, 0, 0 },
                            3,
                        },
                        {
                            { 2.00000, -1.25, _cargoNodeZ },
                            { -0.5, 0, 0 },
                            3,
                        },
                        {
                            { 2.00000, -1.25, _cargoNodeZ }, -- edge 1
                            { -4, 0, 0 },
                            3,
                        },
                        {
                            { -2.00000, -1.25, _cargoNodeZ },
                            { -4, 0, 0 },
                            3,
                        },
                        {
                            { -2.00000, -1.25, _cargoNodeZ }, -- edge 2
                            { -0.5, 0, 0 },
                            3,
                        },
                        {
                            { -2.50000, -1.25, _cargoNodeZ },
                            { -0.5, 0, 0 },
                            3,
                        },

                        {
                            { -2.50000, 1.25, _cargoNodeZ }, -- edge 3
                            { 0.5, 0, 0 },
                            3,
                        },
                        {
                            { -2.00000, 1.25, _cargoNodeZ },
                            { 0.5, 0, 0 },
                            3,
                        },
                        {
                            { -2.00000, 1.25, _cargoNodeZ }, -- edge 4
                            { 4, 0, 0 },
                            3,
                        },
                        {
                            { 2.00000, 1.25, _cargoNodeZ },
                            { 4, 0, 0 },
                            3,
                        },
                        {
                            { 2.00000, 1.25, _cargoNodeZ }, -- edge 5
                            { 0.5, 0, 0 },
                            3,
                        },
                        {
                            { 2.50000, 1.25, _cargoNodeZ },
                            { 0.5, 0, 0 },
                            3,
                        },
                        -- lanes across 1
                        {
                            { 2, 2.5, _cargoNodeZ }, -- edge 6
                            { 0, -1.25, 0 },
                            3,
                        },
                        {
                            { 2, 1.25, _cargoNodeZ },
                            { 0, -1.25, 0 },
                            3,
                        },
                        {
                            { 2, 1.25, _cargoNodeZ }, -- edge 7
                            { 0, -1.25, 0 },
                            3,
                        },
                        {
                            { 2, -1.25, _cargoNodeZ },
                            { 0, -1.25, 0 },
                            3,
                        },
                        {
                            { 2, -1.25, _cargoNodeZ }, -- edge 8
                            { 0, -1.25, 0 },
                            3,
                        },
                        {
                            { 2, -2.5, _cargoNodeZ },
                            { 0, -1.25, 0 },
                            3,
                        },
                        -- lanes across 2
                        {
                            { -2, -2.5, _cargoNodeZ }, -- edge 9
                            { 0, 1.25, 0 },
                            3,
                        },
                        {
                            { -2, -1.25, _cargoNodeZ },
                            { 0, 1.25, 0 },
                            3,
                        },
                        {
                            { -2, -1.25, _cargoNodeZ }, -- edge 10
                            { 0, 1.25, 0 },
                            3,
                        },
                        {
                            { -2, 1.25, _cargoNodeZ },
                            { 0, 1.25, 0 },
                            3,
                        },
                        {
                            { -2, 1.25, _cargoNodeZ }, -- edge 11
                            { 0, 1.25, 0 },
                            3,
                        },
                        {
                            { -2, 2.5, _cargoNodeZ },
                            { 0, 1.25, 0 },
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
                    personEdges = { 1, 4 },
                    personNodes = { 2, 3, 8, 9 },
                    -- vehicleNode = -1, -- 0,
                },
            },
        },
    }
end

helpers.getCargoAreaInner15x15BoundingInfo = function()
    return {
        bbMax = { 7.4, 7.4, 2 },
        bbMin = { -7.4, -7.4, 0 },
    }
end

helpers.getCargoAreaInner15x15Collider = function()
    return {
        params = {
            halfExtents = { 7.4, 7.4, 1.0, },
        },
        transf = { 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, },
        type = 'BOX',
    }
end

helpers.getCargoAreaInner15x15Lods = function()
    local _materials = { 'street/new_medium_sidewalk.mtl', 'street/new_medium_sidewalk.mtl' }
    return {
        {
            node = {
                children = {
                    {
                        -- materials = { 'street/new_medium_sidewalk_border_inner.mtl', 'street/new_medium_sidewalk.mtl', },
                        materials = _materials,
                        mesh = 'station/road/streetstation/pedestrian_era_c/end_l_lod0.msh',
                        transf = { 0, 2.05, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, -7.5, -7.5, -0.02, 1, },
                    },
                    {
                        materials = _materials,
                        mesh = 'station/road/streetstation/pedestrian_era_c/straight_lod0.msh',
                        transf = {1, 0, 0, 0, 0, -2.05, 0, 0, 0, 0, 1, 0, -2.5, -7.5, -0.02, 1}
                    },
                    {
                        materials = _materials,
                        mesh = 'station/road/streetstation/pedestrian_era_c/straight_lod0.msh',
                        transf = {1, 0, 0, 0, 0, -2.05, 0, 0, 0, 0, 1, 0, 2.5, -7.5, -0.02, 1}
                    },
                    {
                        materials = _materials,
                        mesh = 'station/road/streetstation/pedestrian_era_c/end_l_lod0.msh',
                        transf = { 0, 2.05, 0, 0, -1, 0, 0, 0, 0, 0, 1, 0, 7.5, -7.5, -0.02, 1, },
                    },

                    {
                        materials = _materials,
                        mesh = 'station/road/streetstation/pedestrian_era_c/end_l_lod0.msh',
                        transf = { 0, 2.05, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, -7.5, -2.5, -0.02, 1, },
                    },
                    {
                        materials = _materials,
                        mesh = 'station/road/streetstation/pedestrian_era_c/straight_lod0.msh',
                        transf = {1, 0, 0, 0, 0, -2.05, 0, 0, 0, 0, 1, 0, -2.5, -2.5, -0.02, 1}
                    },
                    {
                        materials = _materials,
                        mesh = 'station/road/streetstation/pedestrian_era_c/straight_lod0.msh',
                        transf = {1, 0, 0, 0, 0, -2.05, 0, 0, 0, 0, 1, 0, 2.5, -2.5, -0.02, 1}
                    },
                    {
                        materials = _materials,
                        mesh = 'station/road/streetstation/pedestrian_era_c/end_l_lod0.msh',
                        transf = { 0, 2.05, 0, 0, -1, 0, 0, 0, 0, 0, 1, 0, 7.5, -2.5, -0.02, 1, },
                    },

                    {
                        materials = _materials,
                        mesh = 'station/road/streetstation/pedestrian_era_c/end_l_lod0.msh',
                        transf = { 0, 2.05, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, -7.5, 2.5, -0.02, 1, },
                    },
                    {
                        materials = _materials,
                        mesh = 'station/road/streetstation/pedestrian_era_c/straight_lod0.msh',
                        transf = {1, 0, 0, 0, 0, -2.05, 0, 0, 0, 0, 1, 0, -2.5, 2.5, -0.02, 1}
                    },
                    {
                        materials = _materials,
                        mesh = 'station/road/streetstation/pedestrian_era_c/straight_lod0.msh',
                        transf = {1, 0, 0, 0, 0, -2.05, 0, 0, 0, 0, 1, 0, 2.5, 2.5, -0.02, 1}
                    },
                    {
                        materials = _materials,
                        mesh = 'station/road/streetstation/pedestrian_era_c/end_l_lod0.msh',
                        transf = { 0, 2.05, 0, 0, -1, 0, 0, 0, 0, 0, 1, 0, 7.5, 2.5, -0.02, 1, },
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

helpers.getCargoAreaInner15x15EarthLods = function()
    local _materials = { 'lollo_lorry_station/earth.mtl' }
    return {
        {
            node = {
                children = {
                    {
                        materials = _materials,
                        mesh = 'platform/lollo15x15.msh',
                        transf = { 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, -7.5, -7.5, -0.02, 1, },
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

helpers.getCargoAreaInner15x15GravelLods = function()
    local _materials = { 'lollo_lorry_station/gravel.mtl' }
    return {
        {
            node = {
                children = {
                    {
                        materials = _materials,
                        mesh = 'platform/lollo15x15.msh',
                        transf = { 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, -7.5, -7.5, -0.02, 1, },
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

helpers.getCargoAreaInner15x15Metadata = function()
    local _cargoNodeZ = 0.3
    return {
        transportNetworkProvider = {
            laneLists = {
                {
                    linkable = true,
                    nodes = {
                        {
                            { 7.5, -6.25, _cargoNodeZ }, -- edge 0
                            { -0.5, 0, 0 },
                            3,
                        },
                        {
                            { 7.00000, -6.25, _cargoNodeZ },
                            { -0.5, 0, 0 },
                            3,
                        },
                        {
                            { 7.00000, -6.25, _cargoNodeZ }, -- edge 1
                            { -14, 0, 0 },
                            3,
                        },
                        {
                            { -7.00000, -6.25, _cargoNodeZ },
                            { -14, 0, 0 },
                            3,
                        },
                        {
                            { -7.00000, -6.25, _cargoNodeZ }, -- edge 2
                            { -0.5, 0, 0 },
                            3,
                        },
                        {
                            { -7.5, -6.25, _cargoNodeZ },
                            { -0.5, 0, 0 },
                            3,
                        },

                        {
                            { -7.5, -3.75, _cargoNodeZ }, -- edge 3
                            { 0.5, 0, 0 },
                            3,
                        },
                        {
                            { -7.00000, -3.75, _cargoNodeZ },
                            { 0.5, 0, 0 },
                            3,
                        },
                        {
                            { -7.00000, -3.75, _cargoNodeZ }, -- edge 4
                            { 14, 0, 0 },
                            3,
                        },
                        {
                            { 7.00000, -3.75, _cargoNodeZ },
                            { 14, 0, 0 },
                            3,
                        },
                        {
                            { 7.00000, -3.75, _cargoNodeZ }, -- edge 5
                            { 0.5, 0, 0 },
                            3,
                        },
                        {
                            { 7.5, -3.75, _cargoNodeZ },
                            { 0.5, 0, 0 },
                            3,
                        },

                        {
                            { 7.5, -1.25, _cargoNodeZ },
                            { -0.5, 0, 0 },
                            3,
                        },
                        {
                            { 7.00000, -1.25, _cargoNodeZ }, -- edge 6
                            { -0.5, 0, 0 },
                            3,
                        },
                        {
                            { 7.00000, -1.25, _cargoNodeZ },
                            { -14, 0, 0 },
                            3,
                        },
                        {
                            { -7.00000, -1.25, _cargoNodeZ }, -- edge 7
                            { -14, 0, 0 },
                            3,
                        },
                        {
                            { -7.00000, -1.25, _cargoNodeZ },
                            { -0.5, 0, 0 },
                            3,
                        },
                        {
                            { -7.5, -1.25, _cargoNodeZ }, -- edge 8
                            { -0.5, 0, 0 },
                            3,
                        },

                        {
                            { -7.5, 1.25, _cargoNodeZ }, -- edge 9
                            { 0.5, 0, 0 },
                            3,
                        },
                        {
                            { -7.00000, 1.25, _cargoNodeZ },
                            { 0.5, 0, 0 },
                            3,
                        },
                        {
                            { -7.00000, 1.25, _cargoNodeZ }, -- edge 10
                            { 14, 0, 0 },
                            3,
                        },
                        {
                            { 7.00000, 1.25, _cargoNodeZ },
                            { 14, 0, 0 },
                            3,
                        },
                        {
                            { 7.00000, 1.25, _cargoNodeZ }, -- edge 11
                            { 0.5, 0, 0 },
                            3,
                        },
                        {
                            { 7.5, 1.25, _cargoNodeZ },
                            { 0.5, 0, 0 },
                            3,
                        },


                        {
                            { 7.5, 3.75, _cargoNodeZ },
                            { -0.5, 0, 0 },
                            3,
                        },
                        {
                            { 7.00000, 3.75, _cargoNodeZ }, -- edge 12
                            { -0.5, 0, 0 },
                            3,
                        },
                        {
                            { 7.00000, 3.75, _cargoNodeZ },
                            { -14, 0, 0 },
                            3,
                        },
                        {
                            { -7.00000, 3.75, _cargoNodeZ }, -- edge 13
                            { -14, 0, 0 },
                            3,
                        },
                        {
                            { -7.00000, 3.75, _cargoNodeZ },
                            { -0.5, 0, 0 },
                            3,
                        },
                        {
                            { -7.5, 3.75, _cargoNodeZ }, -- edge 14
                            { -0.5, 0, 0 },
                            3,
                        },

                        {
                            { -7.5, 6.25, _cargoNodeZ }, -- edge 15
                            { 0.5, 0, 0 },
                            3,
                        },
                        {
                            { -7.00000, 6.25, _cargoNodeZ },
                            { 0.5, 0, 0 },
                            3,
                        },
                        {
                            { -7.00000, 6.25, _cargoNodeZ }, -- edge 16
                            { 14, 0, 0 },
                            3,
                        },
                        {
                            { 7.00000, 6.25, _cargoNodeZ },
                            { 14, 0, 0 },
                            3,
                        },
                        {
                            { 7.00000, 6.25, _cargoNodeZ }, -- edge 17
                            { 0.5, 0, 0 },
                            3,
                        },
                        {
                            { 7.5, 6.25, _cargoNodeZ },
                            { 0.5, 0, 0 },
                            3,
                        },
                        -- lanes across 1
                        {
                            { 7, 7.5, _cargoNodeZ }, -- edge 18
                            { 0, -1.25, 0 },
                            3,
                        },
                        {
                            { 7, 6.25, _cargoNodeZ },
                            { 0, -1.25, 0 },
                            3,
                        },
                        {
                            { 7, 6.25, _cargoNodeZ }, -- edge 19
                            { 0, -2.5, 0 },
                            3,
                        },
                        {
                            { 7, 3.75, _cargoNodeZ },
                            { 0, -2.5, 0 },
                            3,
                        },
                        {
                            { 7, 3.75, _cargoNodeZ }, -- edge 20
                            { 0, -2.5, 0 },
                            3,
                        },
                        {
                            { 7, 1.25, _cargoNodeZ },
                            { 0, -2.5, 0 },
                            3,
                        },
                        {
                            { 7, 1.25, _cargoNodeZ }, -- edge 22
                            { 0, -2.5, 0 },
                            3,
                        },
                        {
                            { 7, -1.25, _cargoNodeZ },
                            { 0, -2.5, 0 },
                            3,
                        },
                        {
                            { 7, -1.25, _cargoNodeZ }, -- edge 23
                            { 0, -2.5, 0 },
                            3,
                        },
                        {
                            { 7, -3.75, _cargoNodeZ },
                            { 0, -2.5, 0 },
                            3,
                        },
                        {
                            { 7, -3.75, _cargoNodeZ }, -- edge 24
                            { 0, -2.5, 0 },
                            3,
                        },
                        {
                            { 7, -6.25, _cargoNodeZ },
                            { 0, -2.5, 0 },
                            3,
                        },

                        {
                            { 7, -6.25, _cargoNodeZ }, -- edge 25
                            { 0, -1.25, 0 },
                            3,
                        },
                        {
                            { 7, -7.5, _cargoNodeZ },
                            { 0, -1.25, 0 },
                            3,
                        },
                        -- lanes across 2
                        {
                            { -7, -7.5, _cargoNodeZ }, -- edge 26
                            { 0, 1.25, 0 },
                            3,
                        },
                        {
                            { -7, -6.25, _cargoNodeZ },
                            { 0, 1.25, 0 },
                            3,
                        },
                        {
                            { -7, -6.25, _cargoNodeZ }, -- edge 27
                            { 0, 2.5, 0 },
                            3,
                        },
                        {
                            { -7, -3.75, _cargoNodeZ },
                            { 0, 2.5, 0 },
                            3,
                        },
                        {
                            { -7, -3.75, _cargoNodeZ }, -- edge 28
                            { 0, 2.5, 0 },
                            3,
                        },
                        {
                            { -7, -1.25, _cargoNodeZ },
                            { 0, 2.5, 0 },
                            3,
                        },
                        {
                            { -7, -1.25, _cargoNodeZ }, -- edge 29
                            { 0, 2.5, 0 },
                            3,
                        },
                        {
                            { -7, 1.25, _cargoNodeZ },
                            { 0, 2.5, 0 },
                            3,
                        },
                        {
                            { -7, 1.25, _cargoNodeZ }, -- edge 30
                            { 0, 2.5, 0 },
                            3,
                        },
                        {
                            { -7, 3.75, _cargoNodeZ },
                            { 0, 2.5, 0 },
                            3,
                        },
                        {
                            { -7, 3.75, _cargoNodeZ }, -- edge 31
                            { 0, 2.5, 0 },
                            3,
                        },
                        {
                            { -7, 6.25, _cargoNodeZ },
                            { 0, 2.5, 0 },
                            3,
                        },
                        {
                            { -7, 6.25, _cargoNodeZ }, -- edge 32
                            { 0, 1.25, 0 },
                            3,
                        },
                        {
                            { -7, 7.5, _cargoNodeZ },
                            { 0, 1.25, 0 },
                            3,
                        },
                        -- diagonal lanes to match small cargo area
                        {
                            { -2, -7.5, _cargoNodeZ }, -- edge 33
                            { -5, 1.25, 0 },
                            3,
                        },
                        {
                            { -7, -6.25, _cargoNodeZ },
                            { -5, 1.25, 0 },
                            3,
                        },
                        {
                            { 7, -6.25, _cargoNodeZ }, -- edge 34
                            { -5, -1.25, 0 },
                            3,
                        },
                        {
                            { 2, -7.5, _cargoNodeZ },
                            { -5, -1.25, 0 },
                            3,
                        },
                        {
                            { -7, 6.25, _cargoNodeZ }, -- edge 35
                            { 5, 1.25, 0 },
                            3,
                        },
                        {
                            { -2, 7.5, _cargoNodeZ },
                            { 5, 1.25, 0 },
                            3,
                        },
                        {
                            { 2, 7.5, _cargoNodeZ }, -- edge 36
                            { 5, -1.25, 0 },
                            3,
                        },
                        {
                            { 7, 6.25, _cargoNodeZ },
                            { 5, -1.25, 0 },
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
                    personEdges = { 1, 4, 7, 10, 13, 16 },
                    personNodes = { 2, 3, 8, 9, 14, 15, 20, 21, 26, 27, 32, 33 },
                    -- vehicleNode = -1, -- 0,
                },
            },
        },
    }
end

return helpers

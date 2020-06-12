local luadump = require('lollo_lorry_station/luadump')

local sampleNodes = {
    {
        {-2, -2, 0.00000},
        {4, 0.1, 0},
        3.0
    },
    {
        {2, 0, 0.00000},
        {0.1, 4, 0},
        3.0
    },
    {
        {2, 0, 0.00000},
        {-0.1, 4, 0},
        3.0
    },
    {
        {-2, 2, 0.00000},
        {-4, 0.1, 0},
        3.0
    },
}

if game.__lolloLorryStationData__ == nil then
    game.__lolloLorryStationData__ = {} -- LOLLO TODO add the construction id, we also need different models for different constructions
end
if game.__lolloLorryStationData__.nodeGroups == nil then
    game.__lolloLorryStationData__.nodeGroups = {}
end

local _getStringFromNumber = function(num)
    local str = tostring(num)
    if str:len() == 0 then
        return '00'
    elseif str:len() == 1 then
        return '0' .. str
    else
        return str
    end
end

local helper = {}

helper.getModelData = function(id)
    -- local debugInfo = debug.getinfo(1)
    -- print('LOLLO debugInfo(1) = ')
    -- luadump(true)(debugInfo)
    -- local debugInfo = debug.getinfo(2)
    -- print('LOLLO debugInfo(2) = ')
    -- luadump(true)(debugInfo)
    -- if debugInfo == nil then
    --     return {
    --         lods = {
    --             {
    --                 node = {
    --                     children = {
    --                         {
    --                             materials = { "asset/icon/asset_icon_mark.mtl", },
    --                             mesh = "asset/icon/lod_0_icon_question_mark.msh",
    --                             transf = { 10, 0, 0, 0, 0, 10, 0, 0, 0, 0, 10, 0, 0, 0, 0, 1, },
    --                         },
    --                     },
    --                     name = "RootNode",
    --                     transf = { 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, },
    --                 },
    --                 static = false,
    --                 visibleFrom = 0,
    --                 visibleTo = 9000,
    --             }
    --         },
    --         metadata = {},
    --         version = 1
    --     }
    -- end
    -- local currentFileName = debugInfo.source
    -- print('LOLLO roadConnectionHelpers.getModelData currentFileName = ', currentFileName)

    -- local fileNameEnd = string.sub(currentFileName, string.len(currentFileName) - 5)
    -- local id = fileNameEnd:sub(1, 2)
    print('LOLLO roadConnectionHelpers.getModelData id = ', id)

    local result = {
        -- boundingInfo = {
        --     bbMax = { 0, 0, 0, },
        --     bbMin = { 0, 0, 0, },
        -- },
        collider = {
            params = {
                halfExtents = { 0.0, 0.0, 0.0, },
            },
            transf = { 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, },
            type = "BOX",
        },
        lods = {
            {
                node = {
                    -- LOLLO TODO remove when done testing
                    children = {
                        -- {
                        --     materials = {'asset/icon/asset_icon_mark.mtl'},
                        --     mesh = 'asset/icon/lod_0_icon_exclamation_mark.msh',
                        --     transf = {5, 0, 0, 0, 0, 5, 0, 0, 0, 0, 5, 0, 0, 0, 0, 1}
                        -- },
                        {
                            materials = {'asset/icon/asset_icon_mark.mtl'},
                            mesh = 'asset/icon/lod_0_icon_exclamation_mark.msh',
                            transf = {5, 0, 0, 0, 0, 5, 0, 0, 0, 0, 5, 0, 0, 0, 0, 1}
                        }
                    },
                    name = "RootNode",
                    transf = { 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, },
                },
                static = false,
                visibleFrom = 0,
                visibleTo = 9000,
            },
        },
        metadata = {
            -- LOLLO added this to the stock small_cargo.mdl. It has no effect when plopping the Lollo truck unload stop,
            -- but it does when plopping the construction that contains it. By the way,.it is rotated 90^ wrong.
            transportNetworkProvider = {
                laneLists = {
                    {
                        linkable = false,
                        nodes = game.__lolloLorryStationData__.nodeGroups[tostring(id)] or {},
                        speedLimit = 100,
                        transportModes = {'TRUCK'},
                    },
                },
                runways = {},
                terminals = {}
            },
        },
        -- skipCollision = true,
        -- skipCollisionCheck = true,
        version = 1,
    }
    print('LOLLO game.__lolloLorryStationData__.nodeGroups[id] = ')
    luadump(true)(game.__lolloLorryStationData__.nodeGroups[tostring(id)])
    print('LOLLO game.__lolloLorryStationData__.nodeGroups = ')
    luadump(true)(game.__lolloLorryStationData__.nodeGroups)
    return result
end

helper.getNodeGroupFileName = function(integerId)
    return 'lollo_models/connectors/' .. _getStringFromNumber(integerId) .. '.mdl'
end

helper.setNodeGroup = function(integerId, nodes)
    local stringId = _getStringFromNumber(integerId)
    game.__lolloLorryStationData__.nodeGroups[stringId] = nodes
    game.__lolloLorryStationData__.nodeGroups[stringId][3] = 3 -- lane width
end

return helper
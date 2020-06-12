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

local _nodeGroups = {}

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

local nodeGroupHelper = {}

nodeGroupHelper.getModelData = function()
    -- local currentFileName = debug.getinfo(1).source
    -- print('LOLLO nodeGroupHelper.getModelData currentFileName = ', currentFileName)
    local debugInfo = debug.getinfo(2, 'S')
    print('LOLLO debugInfo = ')
    luadump(true)(debugInfo)
    if debugInfo == nil then
        return {
            lods = {
                {
                    node = {
                        children = {},
                        name = "RootNode",
                        transf = { 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, },
                    },
                    static = false,
                    visibleFrom = 0,
                    visibleTo = 0,
                }
            },
            metadata = {},
            version = 1
        }
    end
    local currentFileName = debugInfo.source
    print('LOLLO nodeGroupHelper.getModelData currentFileName = ', currentFileName)
    -- local currentFileName = debug.getinfo(3).source
    -- print('LOLLO nodeGroupHelper.getModelData currentFileName = ', currentFileName)

    local fileNameEnd = string.sub(currentFileName, string.len(currentFileName) - 5)
    local id = fileNameEnd:sub(1, 2)
    print('LOLLO nodeGroupHelper.getModelData id = ', id)

    return {
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
                            mesh = 'asset/icon/lod_0_icon_question_mark.msh',
                            transf = {5, 0, 0, 0, 0, 5, 0, 0, 0, 0, 5, 0, 0, 0, 0, 1}
                        }
                    },
                    name = "RootNode",
                    transf = { 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, },
                },
                static = false,
                visibleFrom = 0,
                visibleTo = 1000,
            },
        },
        metadata = {
            -- LOLLO added this to the stock small_cargo.mdl. It has no effect when plopping the Lollo truck unload stop,
            -- but it does when plopping the construction that contains it. By the way,.it is rotated 90^ wrong.
            transportNetworkProvider = {
                laneLists = {
                    {
                        linkable = false,
                        nodes = _nodeGroups[id] or {},
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

end

nodeGroupHelper.getNodeGroupFileName = function(integerId)
    return 'lollo_models/connectors/' .. _getStringFromNumber(integerId) .. '.mdl'
end

nodeGroupHelper.setNodeGroup = function(integerId, nodes)
    local stringId = _getStringFromNumber(integerId)
    _nodeGroups[stringId] = nodes
    _nodeGroups[stringId][3] = 3 -- lane width
end

return nodeGroupHelper
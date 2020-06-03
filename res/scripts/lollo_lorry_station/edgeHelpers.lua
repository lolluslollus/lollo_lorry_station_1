local vec3 = require "vec3"
local _modConstants = require('lollo_lorry_station/constants')
local debugger = require('debugger')
local luadump = require('lollo_lorry_station/luadump')

local helper = {}

helper.getNearbyStreetEdges = function(position, edgeSearchRadius)
    if type(position) ~= 'table' then return {} end
    
    -- local nearbyNodes = game.interface.getEntities(
    --     {pos = entity.position, radius = _constants.edgeSearchRadius},
    --     {type = "BASE_NODE", includeData = true}
    --     -- {type = "CONSTRUCTION", includeData = true, fileName = _constants.constructionFileName}
    -- )

    local nearbyEdges = game.interface.getEntities(
        {pos = position, radius = edgeSearchRadius},
        {type = "BASE_EDGE", includeData = true}
    )

    local results = {}
    for i, v in pairs(nearbyEdges) do
        if not v.track and v.streetType then
            table.insert(results, v)
        end
    end

    return results
end

helper.getStreetEdgesSquareBySquare = function(position)
    if type(position) ~= 'table' then return {} end

    -- local nearbyNodes = game.interface.getEntities(
    --     {pos = entity.position, radius = _constants.edgeSearchRadius},
    --     {type = "BASE_NODE", includeData = true}
    --     -- {type = "CONSTRUCTION", includeData = true, fileName = _constants.constructionFileName}
    -- )

    local results = {}
    -- LOLLO TODO 0.7071 looks until the edges (circle outside the square), 0.5 neglects them (circle inside the square): check this
    local searchRadius = math.max(_modConstants.xTransfFactor, _modConstants.yTransfFactor) * 0.7071
    for x = _modConstants.xMin, _modConstants.xMax do
        for y = _modConstants.yMin, _modConstants.yMax do
            -- LOLLO TODO maybe also consider z?
            local squarePosition = {
                position[1] + x * _modConstants.xTransfFactor,
                position[2] + y * _modConstants.yTransfFactor,
                position[3]
            }
            local nearbyStreetEdges = game.interface.getEntities(
                {pos = squarePosition, radius = searchRadius},
                {type = "BASE_EDGE", includeData = true}
            )
            -- LOLLO NOTE #nearbyStreetEdges always returns 0 coz the table is not numbered, so I must iterate.
            -- This is a major caveat of lua's.
            for _, v in pairs(nearbyStreetEdges) do
                local xKey = helper.getXKey(x)
                local yKey = helper.getYKey(y)
                if not(results[xKey]) then
                    results[xKey] = {}
                end
                results[xKey][yKey] = v
            end
        end
    end

    -- print('LOLLO results = ')
    -- luadump(true)(results)
    return results
end

helper.getXKey = function(x)
    return _modConstants.xPrefix .. tostring(x)
end

helper.getYKey = function(y)
    return _modConstants.yPrefix .. tostring(y)
end

return helper
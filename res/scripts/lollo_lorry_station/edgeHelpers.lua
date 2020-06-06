local vec3 = require "vec3"
local _constants = require('lollo_lorry_station/constants')
local slotUtils = require('lollo_lorry_station/slotHelpers')
local transfUtils = require('lollo_lorry_station/transfUtils')
local debugger = require('debugger')
local luadump = require('lollo_lorry_station/luadump')

local helper = {}

helper.getNearbyStreetEdges = function(position, edgeSearchRadius)
    -- if you want to use this, you may have to account for the transformation
    if type(position) ~= 'table' then return {} end
    
    -- local nearbyNodes = game.interface.getEntities(
    --     {pos = entity.position, radius = _constants.edgeSearchRadius},
    --     {type = "BASE_NODE", includeData = true}
    --     -- {type = "CONSTRUCTION", includeData = true, fileName = _constants.constructionFileName}
    -- )

    local nearbyEdges = game.interface.getEntities(
        {pos = position, radius = edgeSearchRadius},
        -- {type = "BASE_EDGE", includeData = true}
        {includeData = true}
    )

    debugger()

    local results = {}
    for i, v in pairs(nearbyEdges) do
        if not v.track and v.streetType then
            table.insert(results, v)
        end
    end

    return results
end

helper.getStreetEdgesSquareBySquare = function(transf)
    -- transf is an absolute transformation, which contains the absolute coordinates in 13, 14, 15
    if type(transf) ~= 'table' then return {} end

    local results = {}
    -- LOLLO NOTE 0.7071 looks until the edges (circle outside the square), 0.5 neglects them (circle inside the square):
    -- it turns out this is not critical, coz we can only find the base edges and those are rectangles with the road inside.
    -- They can extend quite a bit outside the road.
    -- As a consequence, instead of following the road closely, we have rectangles that start and end
    -- at lane switchers (ie edge ends).
    -- To mitigate this, we use a finer mesh. Best would be to use some different tech here.
    local searchRadius = math.max(_constants.xTransfFactor, _constants.yTransfFactor) * 0.7071 * 0.1 --0.5
    -- searchRadius = 0.0
    print('LOLLO getStreetEdgesSquareBySquare starting')
    print('LOLLO searchRadius =', searchRadius)
    print('LOLLO transf = ')
    luadump(true)(transf)

    for x = _constants.xMin, _constants.xMax do
        for y = _constants.yMin, _constants.yMax do
            local squarePosition = {
                x * _constants.xTransfFactor,
                y * _constants.yTransfFactor,
                0
            }
            squarePosition = transfUtils.getVec123Transformed(squarePosition, transf)
            squarePosition[3] = game.interface.getHeight({squarePosition[1], squarePosition[2]}) or transf[15]
            local nearbyStreetEdges = game.interface.getEntities(
                {pos = squarePosition, radius = searchRadius},
                {type = "BASE_EDGE", includeData = true}
            )
            -- LOLLO TODO make it discard paths and other unsuitable street types
            -- print('LOLLO x = ', x, ' y = ', y)
            -- print('LOLLO squarePosition =')
            -- luadump(true)(squarePosition)
            -- print('LOLLO nearbyStreetEdges =')
            -- luadump(true)(nearbyStreetEdges)
            -- LOLLO NOTE #nearbyStreetEdges always returns 0 coz the table is not numbered, so I must iterate.
            -- This is a major caveat of lua's.
            for _, v in pairs(nearbyStreetEdges) do
                slotUtils.setValueInNestedTable(results, v, x, y)

                -- -- returns -1 for a normal chunk of road in the countryside
                -- local con = api.engine.streetConnectorSystem.getConstructionEntityForEdge(v.id)
                -- -- returns -1 for a normal chunk of road in the countryside
                -- local edge = api.engine.streetSystem.getEdgeForEdgeObject(v.id)
            end
        end
    end

    -- print('LOLLO results = ')
    -- luadump(true)(results)
    return results
end

helper.getXKey = function(x)
    return tostring(x)
    -- return _constants.xPrefix .. tostring(x)
end

helper.getYKey = function(y)
    return tostring(y)
    -- return _constants.yPrefix .. tostring(y)
end

return helper
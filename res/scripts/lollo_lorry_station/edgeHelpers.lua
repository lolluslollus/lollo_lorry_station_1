local vec3 = require "vec3"
local _constants = require('lollo_lorry_station/constants')
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

helper.getStreetEdgesSquareBySquare = function(position)
    if type(position) ~= 'table' then return {} end

    -- local nearbyNodes = game.interface.getEntities(
    --     {pos = entity.position, radius = _constants.edgeSearchRadius},
    --     {type = "BASE_NODE", includeData = true}
    --     -- {type = "CONSTRUCTION", includeData = true, fileName = _constants.constructionFileName}
    -- )

    local results = {}
    -- LOLLO NOTE 0.7071 looks until the edges (circle outside the square), 0.5 neglects them (circle inside the square):
    -- it turns out this is not critical, coz we can only find the base edges and those are rectangles with the road inside.
    -- They can extend quite a bit outside the road.
    -- As a consequence, instead of following the road closely, we have rectangles that start and end
    -- at lane switchers (ie edge ends).
    -- To mitigate this, we use a finer mesh. Best would be to use some different tech here.
    local searchRadius = math.max(_constants.xTransfFactor, _constants.yTransfFactor) * 0.7071 * 0.5
    -- searchRadius = 0.0
    print('LOLLO searchRadius =', searchRadius)
    for x = _constants.xMin, _constants.xMax do
        for y = _constants.yMin, _constants.yMax do
            -- LOLLO TODO maybe also consider z?
            local squarePosition = {
                position[1] + x * _constants.xTransfFactor,
                position[2] + y * _constants.yTransfFactor,
                -- position[3]
           }
            squarePosition[3] = game.interface.getHeight({squarePosition[1], squarePosition[2]}) or position[3]
            print('LOLLO squarePosition[3] = ', squarePosition[3])
            local nearbyStreetEdges = game.interface.getEntities(
                {pos = squarePosition, radius = searchRadius},
                {type = "BASE_EDGE", includeData = true}
            )
            print('LOLLO x = ', x, ' y = ', y)
            print('LOLLO squarePosition =')
            luadump(true)(squarePosition)
            print('LOLLO nearbyStreetEdges =')
            luadump(true)(nearbyStreetEdges)
            -- LOLLO NOTE #nearbyStreetEdges always returns 0 coz the table is not numbered, so I must iterate.
            -- This is a major caveat of lua's.
            for _, v in pairs(nearbyStreetEdges) do
                local xKey = helper.getXKey(x)
                local yKey = helper.getYKey(y)
                if not(results[xKey]) then
                    results[xKey] = {}
                end
                results[xKey][yKey] = v

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